//
//  SettingsViewController.swift
//  EcoTracker
//
//  Created by Oleka on 28/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    func addTrackerTypes(){
        
        //Types into new DB
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //If exist - check this!
        do {
            let _request = NSFetchRequest<Types>(entityName: "Types")
            let res = try _context.fetch(_request)
            if res.count>0 {
                //OK!
            }
            else{
                //Read from .Plist
                let path = Bundle.main.path(forResource: "TrackerTypes", ofType: "plist")
                let tr_types = NSDictionary(contentsOfFile: path!)
                
                for tr_type in tr_types! {
                    
                    //Add into StatLog
                    let add_type = Types(context: _context)
                    add_type.name       = String(describing: tr_type.key)
                    add_type.full_name  = String(describing: tr_type.value)
                    
                }
                //Save data to CoreData
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        } catch {
            print("There was an error fetching Types.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTrackerTypes()
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
