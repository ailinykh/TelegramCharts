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
    
//    var canvas = CGRect()
    let scrollLayer = ScrollLayer()
    
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
        var f = scrollLayer.frame
        f.size.height = bounds.size.height
        f.size.width = max(f.size.width, bounds.size.width)
        scrollLayer.frame = f
        scrollLayer.updateSublayers()
    }
    
    private func internalInit() {
        scrollLayer.scrollMode = .horizontally
        layer.addSublayer(scrollLayer)
        // TODO: Theme
        backgroundColor = ChartView.debugColor
        scrollLayer.backgroundColor = ChartView.debugColor.cgColor
    }
    
    private func convertValueToPoint(value: Int) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func addChart(with color: UIColor, values: [Int]) {
        print(#function, color.hexString, "\(values[...3])... count:", values.count)
        
        scrollLayer.addLineLayer(with: color, values: values)
        scrollLayer.updateSublayers()
    }
    
    var prevRange = ChartRange(start: 0, end: 0, scale: 0)
    func set(range: ChartRange, animated: Bool = false) {
        let width = bounds.width/range.scale
        let x = width/100*CGFloat(range.start)
        
        var f = scrollLayer.frame
        f.origin.x = -x
        f.size.width = width
        scrollLayer.frame = f
        scrollLayer.updateSublayers()
//        print(#function, range, scrollLayer.frame)
    }
}

class ScrollLayer: CAScrollLayer {
    var maxValue = 0
    var lineLayers: [LineLayer] {
        return sublayers?.compactMap { $0 as? LineLayer } ?? []
    }
    
    func addLineLayer(with color: UIColor, values: [Int]) {
        maxValue = max(maxValue, values.max() ?? 0)
        
        let layer = LineLayer(color: color.cgColor, values: values, points: points(from: values))
        addSublayer(layer)
    }
    
    func updateSublayers() {
        lineLayers.forEach {
            $0.points = points(from: $0.values)
            $0.updatePath(animated: true)
            $0.backgroundColor = ChartView.debugColor.cgColor
        }
    }
    
    func points(from values: [Int]) -> [CGPoint] {
        let offsetX = frame.size.width/CGFloat(values.count)
        let ratio = frame.height/CGFloat(maxValue)
        return values.enumerated().map { (i, value) -> CGPoint in
            let x = offsetX * CGFloat(i)
            let y = frame.size.height - ratio * CGFloat(value)
            return CGPoint(x: x, y: y)
        }
    }
}

class LineLayer: CAShapeLayer {
    var color: CGColor
    var values: [Int]
    var points: [CGPoint]
    
    init(color: CGColor, values: [Int], points: [CGPoint]) {
        self.color = color
        self.values = values
        self.points = points
        super.init()
        lineWidth = 2
        strokeColor = color
        fillColor = UIColor.clear.cgColor
    }
    
    override init(layer: Any) {
        self.color = (layer as! LineLayer).color
        self.values = (layer as! LineLayer).values
        self.points = (layer as! LineLayer).points
        super.init(layer: layer)
    }
    
    func updatePath(animated: Bool = false) {
//        print(#function, frame, points[...3])
        let path = UIBezierPath()
        points.enumerated().forEach { i, point in
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.fromValue = self.path
            animation.toValue = path.cgPath
            animation.duration = 0.4
            animation.fillMode = CAMediaTimingFillMode.backwards
            add(animation, forKey: "path")
        }
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
