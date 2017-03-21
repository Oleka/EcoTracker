//
//  TrackerTableViewCell.swift
//  EcoTracker
//
//  Created by Oleka on 11/01/17.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class TrackerTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var dataView: UIView!
    var typeName: String!
    var parentController : TrackerViewController?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
                
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
