//
//  CGFloat.swift
//  TelegramCharts
//
//  Created by Anthony Ilinykh on 26/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

extension CGFloat {
    func rounded02() -> CGFloat {
        return (self*100).rounded()/100
    }
}
