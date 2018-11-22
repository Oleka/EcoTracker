//
//  AwardsTableViewCell.swift
//  EcoTracker
//
//  Created by Olga Blinova on 18/01/2018.
//  Copyright © 2018 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class AwardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var awardImage: UIImageView!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var daysAllLabel: UILabel!
    @IBOutlet weak var periodAllLabel: UILabel!
    
    var typeName: String = ""
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
