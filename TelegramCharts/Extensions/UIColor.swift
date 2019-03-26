//
//  UIColor.swift
//  TelegramCharts
//
//  Created by Anthony Ilinykh on 26/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

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
    
    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#UNKNOWN"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
