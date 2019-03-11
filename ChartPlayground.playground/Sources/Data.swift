import Foundation

public struct ChartData {
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

public class DataLoader {
    static public func getData() -> [ChartData] {
        let chartDataURL = Bundle.main.url(forResource: "chart_data", withExtension: "json")
        
        let data = try? Data(contentsOf: chartDataURL!, options: [])
        let json = try? JSONSerialization.jsonObject(with: data!, options: [])
        let jsonArray = json as! [[String: Any]]
        
        return jsonArray.map { ChartData($0) }
    }
}


