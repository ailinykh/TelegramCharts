//
//  ColorCell.swift
//  TeleChart
//
//  Created by Anthony Ilinykh on 24/03/2019.
//  Copyright © 2019 Anthony Ilinykh. All rights reserved.
//

import UIKit

class ColorCell: UITableViewCell {

    var color: UIColor? {
        didSet {
            colorView.layer.backgroundColor = color?.cgColor
        }
    }
    
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorView.layer.cornerRadius = 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
