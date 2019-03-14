//
//  ChartData.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 14/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

struct StrInt: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        if let int = try? Int(from: decoder) {
            value = int
            return
        }
        value = try String(from: decoder)
    }
}

struct ChartData: Decodable {
    let columns: [String: [Int]]
    let types: [String: String]
    let names: [String: String]
    let colors: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case columns
        case types
        case names
        case colors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        types = try container.decode([String: String].self, forKey: .types)
        names = try container.decode([String: String].self, forKey: .names)
        colors = try container.decode([String: String].self, forKey: .colors)
        
        var columnsArray = try container.nestedUnkeyedContainer(forKey: .columns)
        var columnsDict = [String: [Int]]()
        
        while !columnsArray.isAtEnd {
            var arr = try columnsArray.decode([StrInt].self)
            let key = arr.remove(at: 0).value as! String
            let value = arr.map { $0.value as! Int }
            columnsDict[key] = value
        }
        
        columns = columnsDict
    }
}


class DataLoader {
    static func getData() -> [ChartData] {
        let chartDataURL = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        
        let data = try? Data(contentsOf: chartDataURL!, options: [])
        return try! JSONDecoder().decode([ChartData].self, from: data!)
    }
}
