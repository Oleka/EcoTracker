//
//  TrIntroViewController.swift
//  EcoTracker
//
//  Created by Olga Blinova on 24/01/2018.
//  Copyright © 2018 Olga Blinova. All rights reserved.
//

import UIKit

class TrIntroViewController: UIViewController {

    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
        //Status bar color
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        
    }
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
