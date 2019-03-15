//
//  SashesControl.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

protocol SashesControlDelegate: AnyObject {
    func sashesControl(_ control: SashesControl, didChangeSelectionRange range: ClosedRange<Int>)
}

class SashButton: UIButton {
    var flipped = false
    
    convenience init(flipped: Bool) {
        self.init(type: .custom)
        self.flipped = flipped
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        if flipped {
            let transform = __CGAffineTransformMake(-1, 0, 0, 1, bounds.size.width, 0)
            ctx?.concatenate(transform)
        }
        ctx?.addPath(getBackgroundPath().cgPath)
        ctx?.addPath(getArrowPath().cgPath)
    }
    
    private func getBackgroundPath() -> UIBezierPath {
        let pathRect = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10))
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 5.0)
        UIColor.white.withAlphaComponent(0.3).set()
        path.addClip()
        path.fill()
        path.close()
        return path
    }
    
    private func getArrowPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX-3, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY-8))
        path.addLine(to: CGPoint(x: bounds.midX+3, y: bounds.midY-8))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX+3, y: bounds.midY+8))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY+8))
        path.close()
        path.addClip()
        UIColor.white.set()
        path.fill()
        return path
    }
}

class SashOverlay: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        UIColor.white.withAlphaComponent(0.1).set()
        path.fill()
    }
}

class SashesControl: UIControl {
    
    enum MovingPart {
        case none
        case left
        case center
        case right
    }
    
    weak var delegate: SashesControlDelegate?
    
    var selectionRange = 0...100
    
    var movingPart = MovingPart.none
    var lastMovedX = CGFloat(0.0)
    
    let leftOverlay = SashOverlay()
    let rightOverlay = SashOverlay()
    
    let leftSash = SashButton()
    let rightSash = SashButton(flipped: true)
    
    var leftSashConstraint: NSLayoutConstraint!
    var rightSashConstraint: NSLayoutConstraint!
    
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    func setSelection(range: ClosedRange<Int>) {
        
        let mini = max(range.min() ?? 0, 0)
        let maxi = min(range.max() ?? 100, 100)
        let delta = frame.size.width/100
        leftSashConstraint.constant = delta*CGFloat(mini)+leftSash.frame.width
        rightSashConstraint.constant = frame.size.width-delta*CGFloat(maxi)+rightSash.frame.width
        
        selectionRange = range
    }
    
    private func internalInit() {
        leftOverlay.frame = CGRect(x: 0, y: 0, width: 16, height: bounds.size.height)
        rightOverlay.frame = CGRect(x: bounds.size.width-16, y: 0, width: 16, height: bounds.size.height)
        leftSash.frame = leftOverlay.frame
        rightSash.frame = rightOverlay.frame
        
        addSubview(leftOverlay)
        addSubview(rightOverlay)
        leftOverlay.addSubview(leftSash)
        rightOverlay.addSubview(rightSash)
        
        let views = ["leftOverlay": leftOverlay, "rightOverlay": rightOverlay, "leftSash": leftSash, "rightSash": rightSash]
        
        views.forEach {
            $0.value.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftOverlay(30)]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightOverlay(30)]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftOverlay]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightOverlay]|", options: [], metrics: nil, views: views))
        
        leftOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[leftSash(16)]|", options: [], metrics: nil, views: views))
        leftOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftSash]|", options: [], metrics: nil, views: views))
        rightOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rightSash(16)]", options: [], metrics: nil, views: views))
        rightOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightSash]|", options: [], metrics: nil, views: views))
        
        constraints.forEach {
            guard let item = $0.firstItem as? SashOverlay else { return }
            if $0.firstAttribute == .width && item == leftOverlay {
                leftSashConstraint = $0
            }
            if $0.firstAttribute == .width && item == rightOverlay {
                rightSashConstraint = $0
            }
        }
        
        assert(leftSashConstraint != nil, "Left overlay width constraint not found!")
        assert(rightSashConstraint != nil, "Right overlay width constraint not found!")
        
        panGestureRecognizer.addTarget(self, action: #selector(panGestureHandler))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        let pointLeft = sender.location(in: leftSash)
        let pointRight = sender.location(in: rightSash)
        
        switch sender.state {
        case .began:
            if abs(pointLeft.x) < abs(pointRight.x) && abs(pointLeft.x) < leftSash.frame.size.width*2 {
                movingPart = .left
            }
            else if abs(pointLeft.x) > abs(pointRight.x) && abs(pointRight.x) < rightSash.frame.size.width*2 {
                movingPart = .right
            }
            else if pointLeft.x > 0 && pointRight.x < 0 {
                movingPart = .center
            } else {
                movingPart = .none
            }
        case .changed:
            switch movingPart {
            case .left:
                let minimum = leftSash.frame.size.width
                let maximum = bounds.size.width - rightSashConstraint.constant
                leftSashConstraint.constant = min(max(minimum, location.x + leftSash.frame.size.width/2), maximum)
            case .right:
                let minimum = rightSash.frame.size.width
                let maximum = bounds.size.width - leftSashConstraint.constant
                rightSashConstraint.constant = min(max(minimum, bounds.size.width - (location.x - rightSash.frame.size.width/2)), maximum)
            case .center:
                if lastMovedX == 0 {
                    break
                }
                let delta = lastMovedX - location.x
                if leftSashConstraint.constant - delta > leftSash.frame.size.width && rightSashConstraint.constant + delta > rightSash.frame.size.width {
                    leftSashConstraint.constant -= delta
                    rightSashConstraint.constant += delta
                }
            default:
                break
            }
            
            if movingPart != .none {
                let leftEdge = leftOverlay.frame.origin.x + leftOverlay.frame.size.width - leftSash.frame.size.width
                let rightEdge = rightOverlay.frame.origin.x + rightSash.frame.size.width
                let from = Int(100*leftEdge/bounds.size.width)
                let to = Int(100*rightEdge/bounds.size.width)
                selectionRange = from...to
                
                delegate?.sashesControl(self, didChangeSelectionRange: selectionRange)
            }
        case .cancelled, .ended:
            movingPart = .none
        default:
            print(sender.state.rawValue)
            break
        }
        lastMovedX = location.x
    }
}
