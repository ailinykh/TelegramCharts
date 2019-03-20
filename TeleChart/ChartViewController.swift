//
//  ChartViewController.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class ChartViewController: UITableViewController, SashesControlDelegate {

    @IBOutlet var chartCell: UITableViewCell!
    @IBOutlet var chartView: ChartView!
    @IBOutlet var miniChartView: ChartView!
    @IBOutlet var sashesControl: SashesControl!
    
    var chartData: ChartData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        chartCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        sashesControl.delegate = self
        
        if let chartData = chartData {
            chartData.columns.forEach {
                if $0.key == "x" {
                    chartView.addX(values: $0.value)
                }
                else if $0.key.starts(with: "y") {
                    let hex = chartData.colors[$0.key]!
                    let color = UIColor(hexString: hex)
                    
                    chartView.addChart(with: color, values: $0.value)
                    miniChartView.addChart(with: color, values: $0.value)
                }
            }
        }
        return
        let color = UIColor.blue
        let fake = [1, 2, 4, 7, 10, 15, 22, 50, 70, 100, 150, 76, 50, 90, 40, 20, 10, 5, 4, 3, 2, 1, 10, 20, 30, 40, 50, 60, 70, 80, 110, 500, 440, 300, 100, 0]
        chartView.addChart(with: color, values: fake)
        miniChartView.addChart(with: color, values: fake)
    }
    
    func sashesControlDidChangeRange(_ control: SashesControl) {
        chartView.set(range: control.range)
//        chartView.set(range: control.range, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableView.frame.size.width
        }
        return UITableView.automaticDimension
    }
}
