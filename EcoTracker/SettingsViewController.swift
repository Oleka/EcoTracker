//
//  SettingsViewController.swift
//  EcoTracker
//
//  Created by Oleka on 28/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var trackTypes : [Types] = []
    var myTrackTypes : [MyTypes] = []
    
    
    
    func getAccessoryType(for_type: String) -> UITableViewCellAccessoryType{
        
        for my in myTrackTypes {
            if my.name == for_type {
                return .checkmark
            }
        }
        
        return .none
    }
    
    func isSelected(for_type: String) -> Bool{
        
        for my in myTrackTypes {
            if my.name == for_type {
                return true
            }
        }
        
        return false
    }
    
    func getDataTypes(){
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            trackTypes = try _context.fetch(Types.fetchRequest())
        }
        catch{
            print("Fetching Error!")
        }
        do{
            myTrackTypes = try _context.fetch(MyTypes.fetchRequest())
        }
        catch{
            print("Fetching Error!")
        }
        
    }
    
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
                    
                    //Add into Types
                    let add_type = Types(context: _context)
                    add_type.name       = String(describing: tr_type.key)
                    add_type.full_name  = String(describing: tr_type.value)
                    
                    //Add into MyTypes
                    let add_my_type = MyTypes(context: _context)
                    add_my_type.name       = String(describing: tr_type.key)
                    add_my_type.full_name  = String(describing: tr_type.value)
                    
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
        
        tableView.dataSource = self
        tableView.delegate   = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataTypes()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TypeRow")
        {
            
            let viewController : TypeViewController = segue.destination as! TypeViewController
            let indexPath = tableView.indexPathForSelectedRow
            let pr = trackTypes[(indexPath?.row)!]
            viewController.detail_type = [pr]
            viewController.isSelected  = isSelected(for_type:trackTypes[(indexPath?.row)!].name!)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        let cellId: String = "MyCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId)! 
        
        let log = trackTypes[indexPath.row]
        let table_label = "\(log.full_name!)"
        cell.textLabel?.text = table_label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        cell.imageView?.image = UIImage.init(named: "\(log.name!).png")
        cell.accessoryType = getAccessoryType(for_type: log.name!)//.checkmark
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Delete stat row
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let log = trackTypes[indexPath.row]
            _context.delete(log)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //update data after deleting
            do{
                trackTypes = try _context.fetch(Types.fetchRequest())
            }
            catch{
                print("Fetching Error after deleting!")
            }
            tableView.reloadData()
        }
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
