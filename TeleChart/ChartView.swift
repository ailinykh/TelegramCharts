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
    
    var maxValue = 0
    var lineLayers: [LineLayer] {
        return layer.sublayers?.compactMap { $0 as? LineLayer } ?? []
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
        print(#function, color.hexString, "\(values[...3])... count:", values.count)
        
        maxValue = max(maxValue, values.max() ?? 0)
        
        let line = LineLayer(color: color.cgColor, values: values, points: points(from: values, for: frame))
        layer.addSublayer(line)
    }
    
    func set(range: ChartRange, animated: Bool = false) {
//        print(#function, range)
        let width = bounds.width/range.scale
        var f = frame
        f.size.width = width
        let start = width/100*CGFloat(range.start)
//        let end = width/100*CGFloat(range.end)
//        let visibleRect = CGRect(x: start, y: 0, width: end-start, height: frame.height)
        
        lineLayers.forEach {
            $0.points = points(from: $0.values, for: f).map { CGPoint(x: $0.x-start, y: $0.y) }
            $0.updatePath(animated: animated)
        }
    }
    
    private func points(from values: [Int], for frame: CGRect) -> [CGPoint] {
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
        lineJoin = .bevel
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
        let path = CGMutablePath()
        points.enumerated().forEach { i, point in
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        if animated {
            let key = "path"
//            if let ak = animationKeys(), ak.contains(key) {
//                // animation already in progress
//                deferAnimation = true
//                return
//            }
            
            CATransaction.begin()
            
            let animation = CABasicAnimation(keyPath: key)
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fromValue = self.path
            animation.toValue = path
            animation.duration = 0.4
            animation.fillMode = CAMediaTimingFillMode.backwards
            add(animation, forKey: key)
            
            CATransaction.setCompletionBlock { [weak self] in
                if self?.deferAnimation == true {
                    self?.deferAnimation = false
                    self?.updatePath(animated: true)
                }
            }
            CATransaction.commit()
        }
        self.path = path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
