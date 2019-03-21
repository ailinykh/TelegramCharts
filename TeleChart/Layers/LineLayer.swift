//
//  LineLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class LineLayer: CAShapeLayer, Chartable {
    var color: CGColor
    var values: [Int]
    
    var deferAnimation = false
    
    init(color: CGColor, values: [Int]) {
        self.color = color
        self.values = values
        super.init()
        lineWidth = 2
        lineJoin = .bevel
        strokeColor = color
        fillColor = UIColor.clear.cgColor
    }
    
    override init(layer: Any) {
        self.color = (layer as! LineLayer).color
        self.values = (layer as! LineLayer).values
        super.init(layer: layer)
    }
    
    func fit(theFrame: CGRect, theBounds: CGRect) {
        // calculate X
        let offsetX = theFrame.size.width/CGFloat(values.count)
        var visible = [Int]()
        var points = values.enumerated().map { (i, value) -> CGPoint in
            let p = CGPoint(x: offsetX * CGFloat(i), y: theBounds.minY)
            if theBounds.contains(p) {
                visible.append(value)
            }
            return p
        }
        // calculate Y
        let minV = visible.min() ?? 0
        let maxV = visible.max() ?? 1
        let ratio = theFrame.height/CGFloat(maxV-minV)
        
        points = points.enumerated().map {(i, point) -> CGPoint in
            let x = point.x
            let y = bounds.minY + theFrame.size.height - ratio * CGFloat(values[i]-minV)
            return CGPoint(x: x, y: y)
        }
        if frame.height == 48.0 {
            print(visible[...3], points[...10], frame)
        }
        updatePath(points: points)
    }
    
    private func updatePath(points: [CGPoint], animated: Bool = false) {
//        print(#function, self, frame, points[...3])
        let path = CGMutablePath()
        points.enumerated().forEach { i, point in
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        if animated {
            let key = "path"
            //            if let ak = animationKeys(), ak.contains(key) {
            //                // animation already in progress
            //                deferAnimation = true
            //                return
            //            }
            
            CATransaction.begin()
            
            let animation = CABasicAnimation(keyPath: key)
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fromValue = self.path
            animation.toValue = path
            animation.duration = 0.4
            animation.fillMode = CAMediaTimingFillMode.backwards
            add(animation, forKey: key)
            
            CATransaction.setCompletionBlock { [weak self] in
                if self?.deferAnimation == true {
                    self?.deferAnimation = false
                    self?.updatePath(points: points, animated: true)
                }
            }
            CATransaction.commit()
        }
        self.path = path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
