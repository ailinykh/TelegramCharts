//
//  AxisXLayer.swift
//  TeleChart
//
//  Created by Anton Ilinykh on 20/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct XLabelData {
    var frame: CGRect
    let value: Int
}

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
    
    class func data(from values: [Int]) -> [XLabel] {
        return values.map {
            let label = XLabel(value: $0)
            label.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 15)
            label.fontSize = UIFont.smallSystemFontSize
            label.backgroundColor = UIColor.black.cgColor
            label.foregroundColor = UIColor.gray.cgColor
            label.alignmentMode = .center
            return label
        }
    }

    var data: [XLabelData]
    
    var visibleLabels: [XLabel] {
        return sublayers?.compactMap { $0 as? XLabel } ?? []
    }
    
    init(values: [Int]) {
        self.data = values.map { XLabelData(frame: CGRect(x: 0, y: 0, width: 60, height: 15), value: $0) }
        super.init()
    }
    
    override init(layer: Any) {
        self.data = (layer as! AxisXLayer).data
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fit(theFrame: CGRect, theBounds: CGRect) {
        assert(data.count > 0, "values missed!")
        assert(Thread.current.isMainThread, "main thread only!")
        
        let deltaX = theFrame.width / CGFloat(data.count)
        data = data.enumerated().map {
            var d = $0.element
            let x = (CGFloat($0.offset) * deltaX) - theBounds.minX
            d.frame.origin = CGPoint(x: x, y: theBounds.minY)
            return d
        }
        
        let final = data.reduce(into: [data.first!]) {
            if !visibleLabels.containsLabel(with: $1.value) {
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
        
        let appeared = final.compactMap { data -> XLabel? in
            if !visibleLabels.containsLabel(with: data.value) {
                let label = XLabel(value: data.value)
                label.anchorPoint = CGPoint(x: 0.0, y: 0.0)
                label.frame = data.frame
                label.fontSize = UIFont.smallSystemFontSize
                label.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
                label.foregroundColor = UIColor.gray.cgColor
                label.alignmentMode = .center
                return label
            }
            return nil
        }
        
        let moved = visibleLabels.filter { final.contains(value: $0.value) }
        let disappeared = visibleLabels.filter { !final.contains(value: $0.value) }
        
        print(#function, "final:", final.count, "appeared:", appeared.count, "moved:", moved.count, "disappeared:", disappeared.count)
        
        appeared.forEach {
            $0.opacity = 0.0
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 0.4
            animation.fillMode = .backwards
            $0.add(animation, forKey: "appear")
            $0.opacity = 1.0
            
            addSublayer($0)
        }
        
        
        moved.forEach {
            let f = final.find(value: $0.value)!
            
            if let _ = $0.animation(forKey: "move"), let presentation = $0.presentation() {
                $0.removeAnimation(forKey: "move")
                $0.position = presentation.position
            }
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = NSValue(cgPoint: $0.position)
            animation.toValue = NSValue(cgPoint: f.frame.origin)
            animation.duration = 0.1
            animation.fillMode = .backwards
            $0.add(animation, forKey: "move")
            $0.position = f.frame.origin
        }
        
        disappeared.forEach {
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.4
            animation.fillMode = .backwards
            $0.add(animation, forKey: "disappear")
            $0.opacity = 0.0
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                $0.removeFromSuperlayer()
//            }
        }
    }
}

private extension Array where Element == XLabelData {
    func contains(value: Int) -> Bool {
        for v in self {
            if v.value == value {
                return true
            }
        }
        return false
    }
    
    func find(value: Int) -> XLabelData? {
        for v in self {
            if v.value == value {
                return v
            }
        }
        return nil
    }
}

private extension Array where Element == XLabel {
    func containsLabel(with value: Int) -> Bool {
        for l in self {
            if l.value == value {
                return true
            }
        }
        return false
    }
}
