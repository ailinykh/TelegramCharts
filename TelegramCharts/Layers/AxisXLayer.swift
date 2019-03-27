//
//  AxisXLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class XLabel: CATextLayer {
    
    static let space = CGFloat(20.0)
    
    let value: Int
    
    override var string: Any? {
        set {}
        get {
            let df = DateFormatter()
            df.dateFormat = "MMM dd"
            let date = Date(timeIntervalSince1970: TimeInterval(value)/1000.0)
            return df.string(from: date)
        }
    }
    
    init(value: Int) {
        self.value = value
        super.init()
    }
    
    override init(layer: Any) {
        self.value = (layer as! XLabel).value
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func ==(rhs: XLabel, lhs: XLabel) -> Bool {
        return rhs.value == lhs.value
    }
}

class AxisXLayer: CAShapeLayer, Chartable {

    var values: [Int]
    
    var labels: [XLabel] {
        return sublayers?.compactMap { $0 as? XLabel } ?? []
    }
    
    init(values: [Int]) {
        self.values = values
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fit(theFrame: CGRect, theBounds: CGRect) {
        guard values.count > 0 else {
            print(#function, self, "no values")
            return
        }
        
        let deltaX = theFrame.width / CGFloat(values.count)
        let allLabels = values.enumerated().map { (offset, element) -> XLabel in
            let label = XLabel(value: element)
            let x = CGFloat(offset) * deltaX - theBounds.minX
            label.frame = CGRect(x: x.rounded02(), y: 0, width: 50, height: 15)
            label.fontSize = UIFont.smallSystemFontSize
            label.backgroundColor = UIColor.black.cgColor
            label.alignmentMode = .center
            return label
        }
        
        let candidates = allLabels.reduce(into: [allLabels.first!]) {
            if $1.frame.minX > $0.last!.frame.maxX + XLabel.space {
                $0.append($1)
            }
        }
        
        let appeared = candidates.filter { !labels.contains(label: $0) }
        let moved = labels.filter { candidates.contains(label: $0) }
        let disappeared = labels.filter { !candidates.contains(label: $0) }
        
        print(#function, "candidates:", candidates.count, "appeared:", appeared.count, "moved:", moved.count, "disappeared:", disappeared.count)
        
        appeared.forEach {
            $0.opacity = 0.0
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 3.0
            animation.fillMode = CAMediaTimingFillMode.backwards
            $0.add(animation, forKey: "appear")
            $0.opacity = 1.0
            addSublayer($0)
        }
        
        moved.forEach {
            if let candidate = candidates.find(label: $0) {
                if let _ = $0.animation(forKey: "move"), let presentation = $0.presentation() {
                    $0.removeAnimation(forKey: "move")
                    $0.frame = presentation.frame
                }
                
                let animation = CABasicAnimation(keyPath: "frame")
                animation.fromValue = $0.frame
                animation.toValue = candidate.frame
                animation.duration = 0.1
                animation.fillMode = CAMediaTimingFillMode.backwards
                $0.add(animation, forKey: "move")
                $0.frame = candidate.frame
            }
        }
        
        disappeared.forEach {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 3.0
            animation.fillMode = CAMediaTimingFillMode.backwards
            $0.add(animation, forKey: "disappear")
            $0.opacity = 0.0
            $0.removeFromSuperlayer()
        }
    }
}

private extension Array where Element == XLabel {
    func contains(label: XLabel) -> Bool {
        for l in self {
            if l == label {
                return true
            }
        }
        return false
    }
    
    func find(label: XLabel) -> XLabel? {
        for l in self {
            if l == label {
                return l
            }
        }
        return nil
    }
}
