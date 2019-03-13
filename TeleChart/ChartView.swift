//
//  ChartView.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class ChartView: UIView {
    
    static let debug = true
    static let debugColorBlack = UIColor.black.withAlphaComponent(0.3)
    static var debugColor: UIColor {
        let colors:[UIColor] = [.red, .green, .blue, .cyan, .yellow, .magenta, .orange, .purple]
        return colors.randomElement()!.withAlphaComponent(0.05)
    }
    
    var canvas = CGRect()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    private func internalInit() {
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: -20, right: -20)
        canvas = bounds.inset(by: insets)
        
        if ChartView.debug {
            let rectLayer = CAShapeLayer()
            rectLayer.fillColor = ChartView.debugColor.cgColor
            rectLayer.strokeColor = ChartView.debugColorBlack.cgColor
            rectLayer.path = UIBezierPath(rect: canvas).cgPath
            layer.addSublayer(rectLayer)
        }
        // TODO: Theme
        backgroundColor = UIColor.white
    }
    
    private func convertValueToPoint(value: Int) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func addChart(with color: UIColor, values: [Int]) {
        let maxValue = values.max() ?? 1
        let offsetX = canvas.size.width/CGFloat(values.count)
        let ratio = canvas.size.height/CGFloat(maxValue)
        let points = values.enumerated().map { (i, value) -> CGPoint in
            let x = canvas.origin.x + offsetX * CGFloat(i)
            let y = canvas.origin.y + canvas.size.height - ratio * CGFloat(value)
            return CGPoint(x: x, y: y)
        }
        layer.addSublayer(LineLayer(color: color.cgColor, points: points))
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

class LineLayer: CAShapeLayer {
    var color: CGColor
    var points: [CGPoint]
    
    init(color: CGColor, points: [CGPoint]) {
        self.color = color
        self.points = points
        super.init()
        lineWidth = 2
        strokeColor = color
        fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        points.enumerated().forEach { i, point in
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        //        path.close()
        self.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
