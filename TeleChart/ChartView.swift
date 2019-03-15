//
//  ChartView.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

func points(from values: [Int], for frame: CGRect) -> [CGPoint] {
    let maxValue = values.max() ?? 1
    let offsetX = frame.size.width/CGFloat(values.count)
    let ratio = frame.height/CGFloat(maxValue)
    return values.enumerated().map { (i, value) -> CGPoint in
        let x = frame.origin.x + offsetX * CGFloat(i)
        let y = frame.origin.y + frame.size.height - ratio * CGFloat(value)
        return CGPoint(x: x, y: y)
    }
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
    
    private func internalInit() {
        scrollLayer.scrollMode = .horizontally
        var f = frame
        f.size.width = 5000.0
        scrollLayer.frame = f
        
        layer.addSublayer(scrollLayer)
        
        print(frame, scrollLayer.frame)
//        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        canvas = frame.inset(by: insets)
//        canvas = frame
//        print(frame, canvas)
        
        if ChartView.debug {
            let rectLayer = CAShapeLayer()
            rectLayer.fillColor = ChartView.debugColor.cgColor
            rectLayer.strokeColor = ChartView.debugColorBlack.cgColor
            rectLayer.path = UIBezierPath(rect: scrollLayer.frame).cgPath
            scrollLayer.addSublayer(rectLayer)
        }
        print(frame, scrollLayer.frame)
        // TODO: Theme
        backgroundColor = UIColor.white
    }
    
    private func convertValueToPoint(value: Int) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func addChart(with color: UIColor, values: [Int]) {
        scrollLayer.addSublayer(LineLayer(color: color.cgColor, values: values, points: points(from: values, for: scrollLayer.frame)))
        scrollLayer.updateSublayers()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //        let lineLayer = CALayer()
        //        lineLayer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 30)
        //        lineLayer.backgroundColor = UIColor.red.cgColor
        //
        //        let replicatorYLayer = CAReplicatorLayer()
        //        replicatorYLayer.instanceCount = 3
        //        replicatorYLayer.instanceTransform = CATransform3DMakeTranslation(0, 100, 0)
        //        replicatorYLayer.addSublayer(lineLayer)
        //        layer.addSublayer(replicatorYLayer)
        //        layer.addSublayer(lineLayer)
    }
    
    
}

class ScrollLayer: CAScrollLayer {
    func updateSublayers() {
        guard let sublayers = sublayers as? [CALayer] else { return }
        for layer in sublayers {
            if let layer = layer as? LineLayer {
                layer.points = points(from: layer.values, for: frame)
            }
        }
    }
}

class LineLayer: CAShapeLayer {
    var color: CGColor
    var values: [Int]
    var points: [CGPoint] {
        didSet {
            updatePath()
        }
    }
    
    init(color: CGColor, values: [Int], points: [CGPoint]) {
        self.color = color
        self.values = values
        self.points = points
        super.init()
        lineWidth = 2
        strokeColor = color
        fillColor = UIColor.clear.cgColor
        
        updatePath()
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        points.enumerated().forEach { i, point in
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        //        path.close()
        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = self.path
        animation.toValue = path.cgPath
        animation.duration = 0.4
        animation.fillMode = CAMediaTimingFillMode.backwards
//        animation.isRemovedOnCompletion = false
        add(animation, forKey: "path")
        
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
