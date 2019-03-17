//
//  TableViewController.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, SashesControlDelegate {

    @IBOutlet var chartCell: UITableViewCell!
    @IBOutlet var chartView: ChartView!
    @IBOutlet var miniChartView: ChartView!
    @IBOutlet var sashesControl: SashesControl!
    
    var observation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        
        chartCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        
        sashesControl.delegate = self
    }
    
    func sashesControl(_ control: SashesControl, didChangeChartRange range: ChartRange) {
        chartView.set(range: range)
    }

    private func reloadData() {
        for (i, chartData) in DataLoader.getData().enumerated() {
            print(#function, "Drawing chart:", i, chartData.names, chartData.types)
            for column in chartData.columns {
                if column.key.starts(with: "y") {
                    let hex = chartData.colors[column.key]!
                    let color = UIColor(hexString: hex)
                    
                    chartView.addChart(with: color, values: column.value)
                    miniChartView.addChart(with: color, values: column.value)
                }
            }
            let color = UIColor.blue
            let fake = [1, 2, 4, 7, 10, 15, 22, 50, 70, 100, 150, 76, 50, 90, 40, 20, 10]
            chartView.addChart(with: color, values: fake)
            miniChartView.addChart(with: color, values: fake)
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
