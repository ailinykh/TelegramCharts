//
//  AxisXLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

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
        
        let points = values.points(for: theFrame)
        let offset = CGFloat(80.0)
        
        var visible = [0]
        points.enumerated().forEach {
            let last = points[visible.last!]
            if $0.element.x > last.x + offset {
                visible.append($0.offset)
            }
        }
        
        sublayers?.forEach { $0.removeFromSuperlayer() }
        var f = CGRect(x: 0, y: 0, width: 50, height: 15)
        
        visible.forEach {
            let textLayer = CATextLayer()
            textLayer.frame = f
            textLayer.backgroundColor = UIColor.black.cgColor
//            textLayer.foregroundColor = UIColor.gray.cgColor
            textLayer.fontSize = UIFont.smallSystemFontSize
            textLayer.string = values[$0].date()
            textLayer.alignmentMode = .center
            addSublayer(textLayer)
            f.origin.x += offset
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
