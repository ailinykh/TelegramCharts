import UIKit
import PlaygroundSupport

class ChartView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    private func internalInit() {
        backgroundColor = UIColor.white
        
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print(#function)
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 30)
        lineLayer.backgroundColor = UIColor.red.cgColor
        
        let replicatorYLayer = CAReplicatorLayer()
        replicatorYLayer.instanceCount = 3
        replicatorYLayer.instanceTransform = CATransform3DMakeTranslation(0, 100, 0)
        replicatorYLayer.addSublayer(lineLayer)
        layer.addSublayer(replicatorYLayer)
//        layer.addSublayer(lineLayer)
    }
    
    
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
//view.backgroundColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
PlaygroundPage.current.liveView = view

let chartView = ChartView(frame: CGRect(x: 0, y: 30, width: 320, height: 320))
view.addSubview(chartView)


let chartData = DataLoader.getData()

print(chartData.first)
