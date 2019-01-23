//
//  InterfaceController.swift
//  EcoTrackerWatch Extension
//
//  Created by Olga Blinova on 22/05/2017.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
import EcoTrackerWatchKit
import WatchConnectivity

enum WatchResolution {
    case Watch38mm, Watch42mm, Unknown
}

extension WKInterfaceDevice {
    class func currentResolution() -> WatchResolution {
        let watch38mmRect = CGRect(x: 0, y: 0, width: 136, height: 170)
        let watch42mmRect = CGRect(x: 0, y: 0, width: 156, height: 195)
        
        let currentBounds = WKInterfaceDevice.current().screenBounds
        
        switch currentBounds {
        case watch38mmRect:
            return .Watch38mm
        case watch42mmRect:
            return .Watch42mm
        default:
            return .Unknown
        }
    }
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var _context: NSManagedObjectContext!
    
    var myTrackTypes : [MyTypes] = []
    var myTracker : [Tracker] = []
    
    var session: WCSession?
    
    func getDataTypes(){
        
        do{
        myTrackTypes = WatchCoreDataManager.fetchEntities(className: NSStringFromClass(MyTypes.self) as NSString, withPredicate: nil, andSortDescriptor: nil, managedObjectContext: _context) as! [MyTypes]
            //myTrackTypes = try _context.fetch(MyTypes.fetchRequest())
            
            let startDate = Calendar.current.startOfDay(for: NSDate() as Date)
            
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format: "dt>=%@ AND dt<=%@",startDate as CVarArg, NSDate() as CVarArg)
            myTracker = try _context.fetch(request)
        }
        catch{
            print("Fetching Error!")
        }
        
    }
    
    func deleteOldTracker(){
        
        do{
            
            let startDate = Calendar.current.startOfDay(for: NSDate() as Date)
            
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format: "dt<%@",startDate as CVarArg)
            let for_del = try _context.fetch(request)
            print("Old data count=\(for_del.count)")
            if for_del.count > 0 {
                for del in for_del {
                    _context.delete(del)
                }
                //Save data to CoreData
                if WatchCoreDataManager.saveManagedObjectContext(managedObjectContext: _context) == false{
                    print("Error saving delete old tracker data")
                }
            }
        }
        catch{
            print("Fetching Error!")
        }
        
    }

    
    func getImageBySize(name: String) -> UIImage {
        
        var resImage: UIImage
        var name_by_size : String = ""
        
        if WKInterfaceDevice.currentResolution() == WatchResolution.Watch42mm {
            name_by_size = name
        }
        else{
            name_by_size = name + "_38"
        }
        
        resImage = UIImage.init(named: name_by_size)!
        
        return resImage
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        _context = WatchCoreDataManager.managedObjectContext()
        
        WatchCoreDataManager.addTrackerTypes()
        
        deleteOldTracker()
        getDataTypes()
        
        // Configure interface objects here.
        
        tableView.setNumberOfRows(myTrackTypes.count, withRowType: "watchRow")
        
        for (index, member) in myTrackTypes.enumerated() {
            
            let controller = tableView.rowController(at: index) as! WatchRowController
            
            controller.typeImage.setImage(UIImage.init(named: "\(String(describing: member.name!)).png"))
            controller.typeName = member.name!
            
            let namePredicate = NSPredicate(format: "type like %@",member.name!);
            let filteredArray = myTracker.filter { namePredicate.evaluate(with: $0) };
            
            if(filteredArray.count>0){
                controller.typeValue = filteredArray[0].value
                //Check by data value
                if (filteredArray[0].value == 10){
                    controller.greenButton.setBackgroundImage(getImageBySize(name: "green_on_button"))
                    controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
                    controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
                }
                else if(filteredArray[0].value == 5){
                    controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_on_button"))
                    controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
                    controller.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
                }
            }
            else{
                controller.typeValue = 0
                controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_on_button"))
                controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
                controller.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
            }
            
        }
        setupConnectivity()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //iPhone <--> Watch Connection
    func updateMyTypesFromPhone(data: [String : Any]){
        
        let typesFromPhone: [String] = data["types"] as! [String]
        
        if (typesFromPhone.count>0){
            
            //Delete old MyTypes
            do {
                let request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
                let for_del = try _context.fetch(request)
                for del in for_del {
                    _context.delete(del)
                }
            } catch {
                print("Delete old MyTypes Error!")
            }
            
            //Add into MyTypes
            for typesFromPhoneItem in typesFromPhone {
                let addMyTypeObject = WatchCoreDataManager.insertManagedObject(className: NSStringFromClass(MyTypes.self) as NSString, managedObjectContext: _context) as! MyTypes
                addMyTypeObject.name = typesFromPhoneItem
            }
            
            //Save data to CoreData
            if WatchCoreDataManager.saveManagedObjectContext(managedObjectContext: _context) == false{
                print("Error saving MyTypes from iPhone!")
            }
            
            //Reload table
            getDataTypes()
            
            tableView.setNumberOfRows(myTrackTypes.count, withRowType: "watchRow")
            
            for (index, member) in myTrackTypes.enumerated() {
                
                let controller = tableView.rowController(at: index) as! WatchRowController
                
                controller.typeImage.setImage(UIImage.init(named: "\(String(describing: member.name!)).png"))
                controller.typeName = member.name!
                
                let namePredicate = NSPredicate(format: "type like %@",member.name!);
                let filteredArray = myTracker.filter { namePredicate.evaluate(with: $0) };
                
                if(filteredArray.count>0){
                    controller.typeValue = filteredArray[0].value
                    //Check by data value
                    if (filteredArray[0].value == 10){
                        controller.greenButton.setBackgroundImage(getImageBySize(name: "green_on_button"))
                        controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
                        controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
                    }
                    else if(filteredArray[0].value == 5){
                        controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_on_button"))
                        controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
                        controller.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
                    }
                }
                else{
                    controller.typeValue = 0
                    controller.greyButton.setBackgroundImage(getImageBySize(name: "grey_on_button"))
                    controller.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
                    controller.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
                }
                
            }

            
        }
    }
    
    fileprivate func setupConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            
        }
        else{
            print("No connection with iPhone :(")
        }
    }
    
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async(execute:  {
            //Update MyTypes from iPhone
            self.updateMyTypesFromPhone(data: applicationContext)
        })
        
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation failed with error: \(error.localizedDescription)")
            return
        }
        print("Watch activated with activation state: \(activationState.rawValue) ")
    }


}
