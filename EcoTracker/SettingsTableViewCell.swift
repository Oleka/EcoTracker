//
//  SettingsTableViewCell.swift
//  EcoTracker
//
//  Created by Olga Blinova on 19/01/2018.
//  Copyright © 2018 Olga Blinova. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
