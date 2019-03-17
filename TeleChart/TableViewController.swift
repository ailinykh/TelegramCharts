//
//  TableViewController.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, SashesControlDelegate {

    @IBOutlet var chartView: ChartView!
    @IBOutlet var sashesControl: SashesControl!
    
    var observation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        
        sashesControl.delegate = self
        sashesControl.setSelection(range: 0...100)
    }
    
    func sashesControl(_ control: SashesControl, didChangeSelectionRange range: ClosedRange<Int>) {
//        let leftEdge = control.leftOverlay.frame.origin.x + control.leftOverlay.frame.size.width - control.leftSash.frame.size.width
//        let rightEdge = control.rightOverlay.frame.origin.x + control.rightSash.frame.size.width
//        let mini = range.min() ?? 0
//        let maxi = range.max() ?? 100
//        let delta = control.frame.size.width/100
//        print("range:", range, "constraints:", control.leftSashConstraint.constant, control.rightSashConstraint.constant, "edges:", leftEdge+16.0, rightEdge-16.0, "delta:", delta*CGFloat(mini)+16.0, control.frame.size.width-delta*CGFloat(maxi)+16.0)
        
        chartView.fit(range: range)
        return
        
        let mini = range.min() ?? 0
        let maxi = range.max() ?? 100
        var f = chartView.scrollLayer.frame
        f.size.width = 5000-5000/100*CGFloat(maxi-mini)
        chartView.scrollLayer.frame = f
        chartView.scrollLayer.updateSublayers()
        print("range:", range, "scrollLayer.frame:", chartView.scrollLayer.frame)
    }

    private func reloadData() {
        for (i, chartData) in DataLoader.getData().enumerated() {
            print(#function, "Drawing chart:", i, chartData.names, chartData.types)
            chartData.columns.forEach {
                if $0.key.starts(with: "y") {
                    let hex = chartData.colors[$0.key]!
                    let color = UIColor(hexString: hex)
                    chartView.addChart(with: color, values: $0.value)
                }
            }
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableView.frame.size.width
        }
        return UITableView.automaticDimension
    }
}
