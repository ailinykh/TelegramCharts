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
    
    var labels: [XLabel] {
        return sublayers?.compactMap { $0 as? XLabel } ?? []
    }
    
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
        let allLabels = values.enumerated().map { (offset, element) -> XLabel in
            let label = XLabel(value: element)
            let x = CGFloat(offset) * deltaX - theBounds.minX
            label.frame = CGRect(x: x.rounded02(), y: 0, width: 50, height: 15)
            label.fontSize = UIFont.smallSystemFontSize
            label.backgroundColor = UIColor.black.cgColor
            label.alignmentMode = .center
            return label
        }
        
        let candidates = allLabels.reduce(into: [allLabels.first!]) {
            if $1.frame.minX > $0.last!.frame.maxX + XLabel.space {
                $0.append($1)
            }
        }
        
        let appeared = candidates.filter { !labels.contains(label: $0) }
        let moved = labels.filter { candidates.contains(label: $0) }
        let disappeared = labels.filter { !candidates.contains(label: $0) }
        
        print(#function, "candidates:", candidates.count, "appeared:", appeared.count, "moved:", moved.count, "disappeared:", disappeared.count)
        
        appeared.forEach { addSublayer($0) }
        
        moved.forEach {
            if let candidate = candidates.find(label: $0) {
                $0.frame = candidate.frame
            }
        }
        
        disappeared.forEach { $0.removeFromSuperlayer() }
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
