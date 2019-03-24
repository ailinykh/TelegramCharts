//
//  ChartViewController.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 13/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class ChartViewController: UITableViewController, SashesControlDelegate {

    var chartData: ChartData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 50.0, bottom: 0, right: 0)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        tableView.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
        tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
    }
    
    func sashesControlDidChangeRange(_ control: SashesControl) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChartCell {
            cell.chartView.set(range: control.range)
        }
    }
    
    func sashesControlDidStartDragging(_ control: SashesControl) {
        tableView.isScrollEnabled = false
    }
    
    func sashesControlDidEndDragging(_ control: SashesControl) {
        tableView.isScrollEnabled = true
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let chartData = chartData else {
            print(#function, "empty chart data");
            return 0
        }
        
        return chartData.names.count+1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableView.frame.size.width
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chartData = chartData else {
            print(#function, "empty chart data");
            return UITableViewCell()
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCellReuseIdentifier", for: indexPath) as! ChartCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            
            for column in chartData.columns {
                if column.key == "x" {
                    cell.chartView.addX(values: column.value)
                }
                else if column.key.starts(with: "y") {
                    let hex = chartData.colors[column.key]!
                    let color = UIColor(hexString: hex)
                    cell.chartView.addChart(with: color, values: column.value)
                    cell.miniChartView.addChart(with: color, values: column.value)
                }
            }
            cell.sashesControl.delegate = self
            
            return cell
        }
        
        let name = Array(chartData.names.keys)[indexPath.row-1]
        let hex = chartData.colors[name]!
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCellReuseIdentifier", for: indexPath) as! ColorCell
        cell.textLabel?.text = chartData.names[name]
        cell.color = UIColor(hexString: hex)
        return cell
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let colorCell = tableView.cellForRow(at: indexPath) as? ColorCell,
            let chartCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChartCell
        {
            colorCell.accessoryType = .checkmark
            
            let name = chartData?.colors.filter {
                $0.value == colorCell.color?.hexString
            }.first!.key
            
            chartCell.chartView.addChart(with: colorCell.color!, values: (chartData?.columns[name!])!)
            chartCell.miniChartView.addChart(with: colorCell.color!, values: (chartData?.columns[name!])!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if
            let colorCell = tableView.cellForRow(at: indexPath) as? ColorCell,
            let chartCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChartCell
        {
            colorCell.accessoryType = .none
            
            chartCell.chartView.removeChart(with: colorCell.color!)
            chartCell.miniChartView.removeChart(with: colorCell.color!)
        }
    }
}
