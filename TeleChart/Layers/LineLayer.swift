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
            let x = point.x - theBounds.minX
            let y = bounds.minY + theFrame.size.height - ratio * CGFloat(values[i]-minV)
            return CGPoint(x: x.rounded02(), y: y.rounded02())
        }
        updatePath(points: points, animated: true)
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
            if let _ = self.animation(forKey: "line"), let presentation = presentation() {
                removeAnimation(forKey: "line")
                self.path = presentation.path
            }
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = self.path
            animation.toValue = path
            animation.duration = 0.1
            animation.fillMode = CAMediaTimingFillMode.backwards
            add(animation, forKey: "line")
        }
        self.path = path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
