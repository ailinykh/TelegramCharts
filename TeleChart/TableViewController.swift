//
//  TableViewController.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 19/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    let chartData = DataLoader.getData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show first chart immediately on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            self.performSegue(withIdentifier: "ChartViewControllerSegueIdentifier", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let vc = segue.destination as? ChartViewController,
            let index = tableView.indexPathForSelectedRow?.row
        else { return }
        vc.chartData = chartData[index]
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "Chart #\(indexPath.row)"
        return cell
    }
}
