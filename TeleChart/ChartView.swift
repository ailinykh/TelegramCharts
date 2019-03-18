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
    
    let scrollLayer = ScrollLayer()
    let defaultRange = ChartRange(start: 0, end: 100, scale: 1.0)
    
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
        scrollLayer.displayPoints(in: defaultRange)
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
    }
    
    func set(range: ChartRange, animated: Bool = false) {
        scrollLayer.displayPoints(in: range, animated: animated)
    }
}

class ScrollLayer: CAScrollLayer {
    var maxValue = 0
    var lineLayers: [LineLayer] {
        return sublayers?.compactMap { $0 as? LineLayer } ?? []
    }
    
    func addLineLayer(with color: UIColor, values: [Int]) {
        maxValue = max(maxValue, values.max() ?? 0)
        
        let layer = LineLayer(color: color.cgColor, values: values, points: points(from: values, for: frame))
        addSublayer(layer)
    }
    
    func displayPoints(in range: ChartRange, animated: Bool = false) {
        let width = bounds.width/range.scale
        var f = frame
        f.size.width = width
        let start = width/100*CGFloat(range.start)
        let end = width/100*CGFloat(range.end)
        let visibleRect = CGRect(x: start, y: frame.minY, width: end-start, height: frame.height)
        
        lineLayers.forEach {
            $0.points = points(from: $0.values, for: f).compactMap {
                visibleRect.contains($0) ? CGPoint(x: $0.x-start, y: $0.y) : nil
            }
            $0.updatePath(animated: animated)
        }
    }
    
    func updateSublayers() {
        lineLayers.forEach {
            $0.points = points(from: $0.values, for: frame)
            $0.updatePath(animated: true)
            $0.backgroundColor = ChartView.debugColor.cgColor
        }
    }
    
    func points(from values: [Int], for frame: CGRect) -> [CGPoint] {
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
    
    var deferAnimation = false
    
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
            if let ak = animationKeys(), ak.contains("path") {
                // animation already in progress
                deferAnimation = true
                return
            }
            
            CATransaction.begin()
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.fromValue = self.path
            animation.toValue = path.cgPath
            animation.duration = 0.4
            animation.fillMode = CAMediaTimingFillMode.backwards
            add(animation, forKey: "path")
            
            CATransaction.setCompletionBlock { [weak self] in
                if self?.deferAnimation == true {
                    self?.deferAnimation = false
                    self?.updatePath(animated: true)
                }
            }
            CATransaction.commit()
        }
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
