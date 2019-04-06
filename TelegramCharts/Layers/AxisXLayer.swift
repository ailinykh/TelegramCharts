//
//  AxisXLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class XLabel: CATextLayer {
    
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
    
    var allLabels: [XLabel]
    
    var visibleLabels: [XLabel] {
        return sublayers?.compactMap { $0 as? XLabel } ?? []
    }
    
    init(values: [Int]) {
        self.values = values
        self.allLabels = values.enumerated().map { (offset, element) -> XLabel in
            let label = XLabel(value: element)
            label.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 15)
            label.fontSize = UIFont.smallSystemFontSize
//            label.backgroundColor = UIColor.black.cgColor
            label.foregroundColor = UIColor.gray.cgColor
            label.alignmentMode = .center
            return label
        }
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fit(theFrame: CGRect, theBounds: CGRect) {
        assert(values.count > 0, "values missed!")
        
        let deltaX = theFrame.width / CGFloat(values.count)
        allLabels.enumerated().forEach {
            let x = (CGFloat($0.offset) * deltaX) - theBounds.minX
            $0.element.position = CGPoint(x: x, y: theBounds.minY)
        }
        
        let final = allLabels.reduce(into: [allLabels.first!]) {
            if !visibleLabels.contains(label: $1) {
                // check intersection
                for l in visibleLabels {
                    if l.frame.intersects($1.frame) {
                        return
                    }
                }
            }
            if !$0.last!.frame.intersects($1.frame) {
                $0.append($1)
            }
        }
        
        let appeared = final.filter { !visibleLabels.contains(label: $0) }
        let moved = visibleLabels.filter { final.contains(label: $0) }
        let disappeared = visibleLabels.filter { !final.contains(label: $0) }
        
//        print(#function, "final:", final.count, "appeared:", appeared.count, "moved:", moved.count, "disappeared:", disappeared.count)
        
        appeared    .forEach { addSublayer($0) }
        moved       .forEach { $0.position = final.find(label: $0)!.position }
        disappeared .forEach { $0.removeFromSuperlayer() }
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
