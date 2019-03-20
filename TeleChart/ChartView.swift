//
//  ChartView.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct ChartRange {
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
    
    var xLayer: AxisXLayer {
        return layer.sublayers?.compactMap { $0 as? AxisXLayer }.first ?? AxisXLayer(values: [])
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
        let pts = points(from: values, for: frame, fit: frame)
        let line = LineLayer(color: color.cgColor, values: values, points: pts)
        layer.addSublayer(line)
    }
    
    func addX(values: [Int]) {
        let xLayer = AxisXLayer(values: values)
        layer.addSublayer(xLayer)
    }
    
    func set(range: ChartRange, animated: Bool = false) {
//        print(#function, range)
        let width = bounds.width/range.scale
        var f = frame
        f.size.width = width
        let start = width/100*CGFloat(range.start)
        let end = width/100*CGFloat(range.end)
        let visibleRect = CGRect(x: start, y: 0, width: end-start, height: f.height)
        
        lineLayers.forEach {
            $0.points = points(from: $0.values, for: f, fit: visibleRect).map {
                CGPoint(x: $0.x-start, y: $0.y)
            }
            $0.updatePath(animated: animated)
        }
        
        xLayer.set(frame: f, fit: visibleRect)
    }
    
    private func points(from values: [Int], for frame: CGRect, fit: CGRect) -> [CGPoint] {
        // calculate X
        let offsetX = frame.size.width/CGFloat(values.count)
        var visible = [Int]()
        let points = values.enumerated().map { (i, value) -> CGPoint in
            let p = CGPoint(x: offsetX * CGFloat(i), y: 0)
            if fit.contains(p) {
                visible.append(value)
            }
            return p
        }
        // calculate Y
        let minV = visible.min() ?? 0
        let maxV = visible.max() ?? 0
        let ratio = frame.height/CGFloat(maxV-minV)
        
        return points.enumerated().map {(i, point) -> CGPoint in
            let x = point.x
            let y = frame.size.height - ratio * CGFloat(values[i]-minV)
            return CGPoint(x: x, y: y)
        }
    }
}
