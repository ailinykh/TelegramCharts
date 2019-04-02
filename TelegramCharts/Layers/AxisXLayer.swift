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
    
    var allLabels: [XLabel]
    
    var visibleLabels: [XLabel] {
        return sublayers?.compactMap { $0 as? XLabel } ?? []
    }
    
    init(values: [Int]) {
        self.values = values
        self.allLabels = values.enumerated().map { (offset, element) -> XLabel in
            let label = XLabel(value: element)
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 15)
            label.fontSize = UIFont.smallSystemFontSize
            label.backgroundColor = UIColor.black.cgColor
            label.alignmentMode = .center
            return label
        }
        
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
        allLabels.enumerated().forEach {
            let x = (CGFloat($0.offset) * deltaX) - theBounds.minX
            $0.element.position = CGPoint(x: x, y: theBounds.minY)
        }
        
        let candidates = allLabels.reduce(into: [allLabels.first!]) {
            if $1.frame.minX > $0.last!.frame.maxX + XLabel.space {
                for l in visibleLabels {
                    if l.frame.intersects($1.frame) {
                        return
                    }
                }
                $0.append($1)
            }
        }
        
        let appeared = candidates.filter { !visibleLabels.contains(label: $0) }
        let moved = visibleLabels.filter { candidates.contains(label: $0) }
//        let disappeared = visibleLabels.filter { !candidates.contains(label: $0) }
        
//        print(#function, "candidates:", candidates.count, "appeared:", appeared.count, "moved:", moved.count, "disappeared:", disappeared.count)
        
        appeared    .forEach { addSublayer($0) }
        moved       .forEach {
            let final = candidates.find(label: $0)!
//            if let _ = $0.animation(forKey: "move"), let presentation = $0.presentation() {
//                $0.removeAnimation(forKey: "move")
//                $0.position = presentation.position
//            }
//
//            let animation = CABasicAnimation(keyPath: "position")
//            animation.timingFunction = CAMediaTimingFunction(name: .linear)
//            animation.fromValue = $0.position
//            animation.toValue = final.position
//            animation.duration = 0.1
//            animation.fillMode = CAMediaTimingFillMode.backwards
//            $0.add(animation, forKey: "move")
            $0.position = final.position
        }
//        disappeared .forEach { $0.removeFromSuperlayer() }
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
