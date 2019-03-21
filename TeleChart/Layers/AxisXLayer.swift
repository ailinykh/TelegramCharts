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
        let strings = values.map { time -> String in
            let date = Date(timeIntervalSince1970: Double(time/1000))
            let df = DateFormatter()
            df.dateFormat = "MMM dd"
            return df.string(from: date)
        }
        let offsetX = theFrame.size.width/CGFloat(values.count)
        
        guard values.count > 0 else {
            return
        }
        let startIdx = (theBounds.minX/offsetX).rounded()
        let endIdx = (theBounds.maxX/offsetX).rounded()
        let some = Array(strings[Int(startIdx)..<Int(endIdx)]).someOf()
        
        // TODO: Consider using CAReplicatorLayer here
        
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        var f = CGRect(x: 0, y: 0, width: 50, height: 15)
        f.origin = theBounds.origin
        
        some.forEach {
            let textLayer = CATextLayer()
            textLayer.frame = f
            textLayer.backgroundColor = UIColor.black.cgColor
            textLayer.fontSize = UIFont.smallSystemFontSize
            textLayer.string = $0
            textLayer.alignmentMode = .center
            addSublayer(textLayer)
            f.origin.x += 80.0
        }
    }
}

extension Array where Element == String {
    func someOf() -> [Element] {
        if count <= 6 {
            return self
        }
        
        let delta = count / 4
        var rv = enumerated().filter { $0.0 % delta == 0 }.map { $1 }
        rv.append(last!)
        return rv
    }
}
