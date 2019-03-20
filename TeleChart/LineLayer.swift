//
//  LineLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class LineLayer: CAShapeLayer {
    var color: CGColor
    var values: [Int]
    var points: [CGPoint]
    
    var deferAnimation = false
    
    init(color: CGColor, values: [Int], points: [CGPoint]) {
        self.color = color
        self.values = values
        self.points = points
        super.init()
        lineWidth = 2
        lineJoin = .bevel
        strokeColor = color
        fillColor = UIColor.clear.cgColor
    }
    
    override init(layer: Any) {
        self.color = (layer as! LineLayer).color
        self.values = (layer as! LineLayer).values
        self.points = (layer as! LineLayer).points
        super.init(layer: layer)
    }
    
    func updatePath(animated: Bool = false) {
        //        print(#function, frame, points[...3])
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
                    self?.updatePath(animated: true)
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
