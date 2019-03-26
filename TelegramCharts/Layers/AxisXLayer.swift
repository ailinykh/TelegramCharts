//
//  AxisXLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct XPoint {
    let x: CGFloat
    let y: CGFloat
    let value: Int
}

class AxisXLayer: CAShapeLayer, Chartable {

    var values: [Int]
    
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
        let points = values.enumerated().map {
            CGPoint(x: CGFloat($0.offset) * deltaX - theBounds.minX, y: 0)
        }
        let offset = CGFloat(80.0)
        
        var sievedPoints = [points.first!]
        points.forEach {
            let last = sievedPoints.last!
            if $0.x > last.x + offset {
                sievedPoints.append($0)
            }
        }
        
        let visible = sievedPoints.filter {
            $0.x + 50 > theBounds.minX && $0.x < theBounds.maxX
        }
        
        print(#function, visible)
        sublayers?.forEach { $0.removeFromSuperlayer() }
//        var f = CGRect(x: 0, y: 0, width: 50, height: 15)
        
        sievedPoints.forEach {
            let textLayer = CATextLayer()
            textLayer.frame = CGRect(x: $0.x, y: 0, width: 50, height: 15)
            textLayer.backgroundColor = UIColor.black.cgColor
//            textLayer.foregroundColor = UIColor.gray.cgColor
            textLayer.fontSize = UIFont.smallSystemFontSize
//            textLayer.string = $0.date()
            textLayer.string = "\($0)"
            textLayer.alignmentMode = .center
            addSublayer(textLayer)
        }
    }
}

private extension Int {
    func date() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self)/1000.0)
        let df = DateFormatter()
        df.dateFormat = "MMM dd"
        return df.string(from: date)
    }
}
