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
        let (minV, maxV) = superlayer!.globalMinMax(for: theFrame, bounds: theBounds)
        let ratioX = theFrame.width/CGFloat(values.count)
        let ratioY = theFrame.height/CGFloat(maxV-minV)
        
        let points = values.enumerated().map {(i, value) -> CGPoint in
            let x = ratioX * CGFloat(i) - theBounds.minX
            let y = theBounds.maxY - theBounds.minY - ratioY * CGFloat(value-minV)
//            return CGPoint(x: x.rounded02(), y: y.rounded02())
            return CGPoint(x: x, y: y)
        }
        
        updatePath(points: points, animated: true)
    }
    
    func visibleValues(for theFrame: CGRect, bounds theBounds: CGRect) -> [Int] {
        let ratio = theFrame.width / CGFloat(values.count)
        return values.enumerated().compactMap {
            let x = ratio * CGFloat($0.offset)
            if x >= theBounds.minX && x <= theBounds.maxX {
                return $0.element
            }
            return nil
        }
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
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
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

extension CALayer {
    func globalMinMax(for theFrame: CGRect, bounds theBounds: CGRect) -> (Int, Int) {
        var mi = Int.max;
        var ma = Int.min;
        
        let layers = sublayers?.compactMap { $0 as? LineLayer } ?? []
        for layer in layers {
            if
                let lmi = layer.visibleValues(for: theFrame, bounds: theBounds).min(),
                let lma = layer.visibleValues(for: theFrame, bounds: theBounds).max()
            {
                mi = min(mi, lmi)
                ma = max(ma, lma)
            }
        }
        
        return (mi, ma)
    }
}
