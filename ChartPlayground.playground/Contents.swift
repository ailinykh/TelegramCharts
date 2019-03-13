import UIKit
import PlaygroundSupport

extension UIColor {
    convenience init(hexString: String) {
        var hex: UInt32 = 0
        let str = String(hexString[hexString.index(hexString.startIndex, offsetBy: 1)...])
        guard Scanner(string: str).scanHexInt32(&hex) else {
            self.init(white: 0.8, alpha: 1.0)
            return
        }
        
        let red     = CGFloat((hex & 0xFF0000) >> 16) / CGFloat(255)
        let green   = CGFloat((hex & 0x00FF00) >> 8) / CGFloat(255)
        let blue    = CGFloat( hex & 0x0000FF      ) / CGFloat(255)
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// Telegram Data
struct ChartData {
    var colors: [String: String]
    var types: [String: String]
    var columns: [[Any]]
    var names: [String: String]
    
    init(_ dict: [String: Any]) {
        colors = dict["colors"] as! [String: String]
        types = dict["types"] as! [String: String]
        columns = dict["columns"] as! [[Any]]
        names = dict["names"] as! [String: String]
    }
}

class DataLoader {
    static func getData() -> [ChartData] {
        let chartDataURL = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        
        let data = try? Data(contentsOf: chartDataURL!, options: [])
        let json = try? JSONSerialization.jsonObject(with: data!, options: [])
        let jsonArray = json as! [[String: Any]]
        
        return jsonArray.map { ChartData($0) }
    }
}


class SashButton: UIButton {
    var flipped = false
    
    convenience init(flipped: Bool) {
        self.init(type: .custom)
        self.flipped = flipped
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        if flipped {
            let transform = __CGAffineTransformMake(-1, 0, 0, 1, bounds.size.width, 0)
            ctx?.concatenate(transform)
        }
        ctx?.addPath(getBackgroundPath().cgPath)
        ctx?.addPath(getArrowPath().cgPath)
    }
    
    private func getBackgroundPath() -> UIBezierPath {
        let pathRect = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10))
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 5.0)
        UIColor.white.withAlphaComponent(0.3).set()
        path.addClip()
        path.fill()
        path.close()
        return path
    }
    
    private func getArrowPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX-3, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY-8))
        path.addLine(to: CGPoint(x: bounds.midX+3, y: bounds.midY-8))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.midX+3, y: bounds.midY+8))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY+8))
        path.close()
        path.addClip()
        UIColor.white.set()
        path.fill()
        return path
    }
}

class SashOverlay: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(rect: rect)
        UIColor.white.withAlphaComponent(0.1).set()
        path.fill()
    }
}

class SashesControl: UIControl {
    
    enum MovingPart {
        case none
        case left
        case center
        case right
    }
    
    var movingPart = MovingPart.none
    var lastMovedX = CGFloat(0.0)
    
    let leftOverlay = SashOverlay()
    let rightOverlay = SashOverlay()
    
    let leftSash = SashButton()
    let rightSash = SashButton(flipped: true)
    
    var leftSashConstraint: NSLayoutConstraint!
    var rightSashConstraint: NSLayoutConstraint!
    
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    private func internalInit() {
        leftOverlay.frame = CGRect(x: 0, y: 0, width: 16, height: bounds.size.height)
        rightOverlay.frame = CGRect(x: bounds.size.width-16, y: 0, width: 16, height: bounds.size.height)
        leftSash.frame = leftOverlay.frame
        rightSash.frame = rightOverlay.frame
        
        addSubview(leftOverlay)
        addSubview(rightOverlay)
        leftOverlay.addSubview(leftSash)
        rightOverlay.addSubview(rightSash)
        
        let views = ["leftOverlay": leftOverlay, "rightOverlay": rightOverlay, "leftSash": leftSash, "rightSash": rightSash]
        
        views.forEach {
            $0.value.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftOverlay(30)]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightOverlay(30)]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftOverlay]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightOverlay]|", options: [], metrics: nil, views: views))
        
        leftOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[leftSash(16)]|", options: [], metrics: nil, views: views))
        leftOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftSash]|", options: [], metrics: nil, views: views))
        rightOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rightSash(16)]", options: [], metrics: nil, views: views))
        rightOverlay.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rightSash]|", options: [], metrics: nil, views: views))
        
        constraints.forEach {
            guard let item = $0.firstItem as? SashOverlay else { return }
            if $0.firstAttribute == .width && item == leftOverlay {
                leftSashConstraint = $0
            }
            if $0.firstAttribute == .width && item == rightOverlay {
                rightSashConstraint = $0
            }
        }
        
//        assert(leftSashConstraint != nil, "Left overlay width constraint not found!")
//        assert(rightSashConstraint != nil, "Right overlay width constraint not found!")
        
        panGestureRecognizer.addTarget(self, action: #selector(panGestureHandler))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        let pointLeft = sender.location(in: leftSash)
        let pointRight = sender.location(in: rightSash)
        
        switch sender.state {
        case .began:
            if abs(pointLeft.x) < abs(pointRight.x) && abs(pointLeft.x) < leftSash.frame.size.width*2 {
                movingPart = .left
            }
            else if abs(pointLeft.x) > abs(pointRight.x) && abs(pointRight.x) < rightSash.frame.size.width*2 {
                movingPart = .right
            }
            else if pointLeft.x > 0 && pointRight.x < 0 {
                movingPart = .center
            } else {
                movingPart = .none
            }
        case .changed:
            switch movingPart {
            case .left:
                let minimum = leftSash.frame.size.width
                let maximum = bounds.size.width - rightSashConstraint.constant
                leftSashConstraint.constant = min(max(minimum, location.x + leftSash.frame.size.width/2), maximum)
            case .right:
                let minimum = rightSash.frame.size.width
                let maximum = bounds.size.width - leftSashConstraint.constant
                rightSashConstraint.constant = min(max(minimum, bounds.size.width - (location.x - rightSash.frame.size.width/2)), maximum)
            case .center:
                if lastMovedX == 0 {
                    break
                }
                let delta = lastMovedX - location.x
                if leftSashConstraint.constant - delta > leftSash.frame.size.width && rightSashConstraint.constant + delta > rightSash.frame.size.width {
                    leftSashConstraint.constant -= delta
                    rightSashConstraint.constant += delta
                }
            default:
                break
            }
        case .cancelled, .ended:
            movingPart = .none
        default:
            print(sender.state.rawValue)
            break
        }
        lastMovedX = location.x
    }
}


// Chart
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
        fatalError("init(coder:) has not been implemented")
    }
    
    private func internalInit() {
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 80, right: 20)
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
        var f = bounds
        f.size.height = 64
        f.origin.y = bounds.size.height - f.size.height
        let sashes = SashesControl(frame: f)
        addSubview(sashes)
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

let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
//view.backgroundColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
PlaygroundPage.current.liveView = view

let chartView = ChartView(frame: CGRect(x: 0, y: 30, width: 320, height: 380))
view.addSubview(chartView)


let chartDataArray = DataLoader.getData()
let chartData = chartDataArray.first!

print(chartData.colors)

let charts = chartData.columns.compactMap { (data) -> [Int]? in
    var data = data
    if let axis = data.removeFirst() as? String, axis.starts(with: "y") {
        return data as? [Int]
    }
    return nil
}

let colors = Array(chartData.colors.values)

//chartView.addChart(with: UIColor(hexString: colors[0]), values: [10, 20, 35, 40, 90, 150, 4])
//chartView.addChart(with: UIColor(hexString: colors[0]), values: charts[0])
charts.enumerated().forEach { i, chart in
    chartView.addChart(with: UIColor(hexString: colors[i]), values: chart)
}
