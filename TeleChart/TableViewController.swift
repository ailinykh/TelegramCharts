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
//        reloadData()
        
        sashesControl.delegate = self
    }
    
    func sashesControl(_ control: SashesControl, didChangeSelectionRange range: ClosedRange<Int>) {
        print(range)
    }

    private func reloadData() {
        let chartData = DataLoader.getData().first!
        chartData.columns.forEach {
            if $0.key.starts(with: "y") {
                let color = UIColor(hexString: chartData.colors[$0.key]!)
                chartView.addChart(with: color, values: $0.value)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableView.frame.size.width
        }
        return UITableView.automaticDimension
    }
}
