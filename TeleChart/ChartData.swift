//
//  ChartData.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 14/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct ChartData: Decodable {
    let columns: [[Any]]
    let types: [String: String]
    let names: [String: String]
    let colors: [String: String]
}


class DataLoader {
    static func getData() -> [ChartData] {
        let chartDataURL = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        
        let data = try? Data(contentsOf: chartDataURL!, options: [])
        return try! JSONDecoder().decode([ChartData].self, from: data!)
    }
}

//struct ChartData {
//    var colors: [String: String]
//    var types: [String: String]
//    var columns: [[Any]]
//    var names: [String: String]
//
//    init(_ dict: [String: Any]) {
//        colors = dict["colors"] as! [String: String]
//        types = dict["types"] as! [String: String]
//        columns = dict["columns"] as! [[Any]]
//        names = dict["names"] as! [String: String]
//    }
//}
