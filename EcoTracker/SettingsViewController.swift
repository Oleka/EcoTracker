//
//  SettingsViewController.swift
//  EcoTracker
//
//  Created by Oleka on 28/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import EcoTrackerKit

class SettingsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var _context: NSManagedObjectContext!
    var trackTypes = [Types]()
    var myTrackTypes = [MyTypes]()
    
    //Notifications
    var isGrantedNotificationAccess:Bool = false
    
    @IBAction func sendNotification(_ sender: UIButton) {
        
        //
        //Notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
        
        if isGrantedNotificationAccess{
            
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Ежедневное напоминание"
            content.body = "Пожалуйста, заполните Check-list!"
            content.sound = UNNotificationSound.default()
            
            //Set the trigger of the notification - daily
            let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "Daily.EcoTracker",
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler:nil)
            
            let okAlert = UIAlertController(title: "Эко-Трекер", message: "Успешно включены ежедневные напоминания!", preferredStyle: UIAlertControllerStyle.alert)
            
            okAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            present(okAlert, animated: true, completion: nil)
            
        }
        else{
            let errAlert = UIAlertController(title: "Напоминания выключены!", message: "Для включения, пожалуйста, перейдите в Настройки - Уведомления - Эко-Трекер: Допуск уведомлений - Включить", preferredStyle: UIAlertControllerStyle.alert)
            
            errAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic here")
            }))
            present(errAlert, animated: true, completion: nil)
        }
        
    }
    
    
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
        
        do{
            trackTypes = try _context.fetch(Types.fetchRequest())
        }
        catch{
            print("Types Fetching Error!")
        }
        do{
            myTrackTypes = try _context.fetch(MyTypes.fetchRequest())
        }
        catch{
            print("MyTypes Fetching Error!")
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _context = CoreDataManager.managedObjectContext()
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        //Notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
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
            let pr = trackTypes[indexPath!.row]
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
       
        let cellId: String = "MyCell"
        let cell: SettingsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsTableViewCell
        
        let log = trackTypes[indexPath.row]
        let table_label = "\(String(describing: log.full_name!))"
        cell.settingsLabel.text = table_label
        cell.settingsLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        cell.settingsLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        cell.settingsImage.image = UIImage.init(named: "\(String(describing: log.name!)).png")
        
        cell.accessoryType = getAccessoryType(for_type: log.name!)//.checkmark
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Delete stat row
        
        if editingStyle == .delete {
            
            let log = trackTypes[indexPath.row]
            
            //Delete type from MyTypes
            do {
                let request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
                request.predicate = NSPredicate(format: "name=%@",log.name!)
                let for_del = try _context.fetch(request)
                for del in for_del {
                    _context.delete(del)
                }
                
                if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
                    print("Error delete MyTypes!")
                }
            } catch {
                print("There was an error fetching Plus Operations.")
            }
            
            //Delete in Types
            _context.delete(log)
            if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
                print("Error delete Types!")
            }
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
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
