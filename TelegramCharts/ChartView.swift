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
    
    var currentRange = ChartRange(start: 0, end: 100, scale: 1.0)
    
    var lineLayers: [LineLayer] {
        return layer.sublayers?.compactMap { $0 as? LineLayer } ?? []
    }
    
    var canvas: CGRect {
        if xLayer != nil {
            return CGRect(x: bounds.minX, y: bounds.minY+5.0, width: bounds.width, height: bounds.height-25.0)
        }
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
        
        lineLayers.forEach { $0.frame = canvas }
        
        set(range: currentRange, true)
    }
    
    private func internalInit() {
        // TODO: Theme
//        backgroundColor = ChartView.debugColor
    }
    
    private func convertValueToPoint(value: Int) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func addChart(with color: UIColor, values: [Int]) {
//        print(#function, color.hexString, "\(values[...3])... count:", values.count)
        let line = LineLayer(color: color.cgColor, values: values)
        let (f, b) = frameAndBounds(for: currentRange)
//        line.frame = canvas
//        line.fit(theFrame: f, theBounds: b)
//        
//        let animation = CABasicAnimation(keyPath: "frame")
//        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
//        animation.fromValue = CGRect(x: canvas.minX, y: canvas.minY-canvas.height, width: canvas.width, height: canvas.height)
//        animation.toValue = canvas
//        animation.duration = 0.1
//        animation.fillMode = CAMediaTimingFillMode.backwards
//        line.add(animation, forKey: nil)
        
        layer.addSublayer(line)
    }
    
    func removeChart(with color: UIColor) {
        lineLayers.filter{ $0.color == color.cgColor }.forEach{ $0.removeFromSuperlayer() }
    }
    
    func addX(values: [Int]) {
        let xLayer = AxisXLayer(values: values)
        layer.addSublayer(xLayer)
    }
    
    
    func set(range: ChartRange, _ forced: Bool = false) {
        
        if range == currentRange && !forced {
//            print("range duplicated. skipping...")
            return
        }
        
        currentRange = range
        let (f, b) = frameAndBounds(for: range)
        
        layer.sublayers?.forEach {
            if let layer = $0 as? Chartable {
//                print(#function, layer, f, b)
                layer.fit(theFrame: f, theBounds: b)
            }
        }
    }
    
    private func frameAndBounds(for range: ChartRange) -> (CGRect, CGRect) {
        var f = canvas
        f.size.width = (f.width/range.scale).rounded02()
        let start = f.width/100*CGFloat(range.start)
        let end = f.width/100*CGFloat(range.end)
        let width = end-start
        let b = CGRect(x: start.rounded02(), y: f.minY, width: width.rounded02(), height: f.height)
        
        return (f, b)
    }
}
