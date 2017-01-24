//
//  TypeNameViewController.swift
//  EcoTracker
//
//  Created by Oleka on 24/01/17.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit

class TypeNameViewController: UIViewController {
    
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeNameLabel: UILabel!
    
    var detail_type : [Types] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
