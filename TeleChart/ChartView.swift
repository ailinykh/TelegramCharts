//
//  ChartView.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct ChartRange: Equatable {
    let start: Int
    let end: Int
    let scale: CGFloat
}

class ChartView: UIView {
    
    static let debug = true
    static let debugColorBlack = UIColor.black.withAlphaComponent(0.3)
    static var debugColor: UIColor {
        let colors:[UIColor] = [.red, .green, .blue, .cyan, .yellow, .magenta, .orange, .purple]
        return colors.randomElement()!.withAlphaComponent(0.05)
    }
    
    let defaultRange = ChartRange(start: 0, end: 100, scale: 1.0)
    
    var lineLayers: [LineLayer] {
        return layer.sublayers?.compactMap { $0 as? LineLayer } ?? []
    }
    
    var lineLayerFrame: CGRect {
        return bounds
//        return CGRect(x: frame.minX, y: frame.minY+15, width: frame.width, height: frame.height+100)
    }
    
    var xLayer: AxisXLayer? {
        return layer.sublayers?.compactMap { $0 as? AxisXLayer }.first
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var f = frame
        f.origin.y = f.maxY - 15.0
        f.size.height = 15.0
        xLayer?.frame = f
        
        lineLayers.forEach { $0.frame = lineLayerFrame }
        
        set(range: defaultRange)
    }
    
    private func internalInit() {
        // TODO: Theme
        backgroundColor = ChartView.debugColor
    }
    
    private func convertValueToPoint(value: Int) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func addChart(with color: UIColor, values: [Int]) {
//        print(#function, color.hexString, "\(values[...3])... count:", values.count)
        let line = LineLayer(color: color.cgColor, values: values)
        layer.addSublayer(line)
    }
    
    func addX(values: [Int]) {
        let xLayer = AxisXLayer(values: values)
        layer.addSublayer(xLayer)
    }
    
    
    func set(range: ChartRange, animated: Bool = false) {
        var f = lineLayerFrame
        f.size.width = (f.width/range.scale).rounded02()
        let start = f.width/100*CGFloat(range.start)
        let end = f.width/100*CGFloat(range.end)
        let width = end-start
        let visibleRect = CGRect(x: start.rounded02(), y: f.minY, width: width.rounded02(), height: f.height)
        
        layer.sublayers?.forEach {
            if let layer = $0 as? Chartable {
//                print(#function, layer, f, visibleRect)
                layer.fit(theFrame: f, theBounds: visibleRect)
            }
        }
    }
    
    
}
