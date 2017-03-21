//
//  TrackerBlock.swift
//  EcoTracker
//
//  Created by Oleka on 26/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit

class TrackerBlock: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func draw(_ rect: CGRect){
        
        let color = UIColor.clear
        
        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        
        color.set()
        bpath.stroke()
        
    }


}
