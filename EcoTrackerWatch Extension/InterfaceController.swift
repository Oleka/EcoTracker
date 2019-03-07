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
    case Watch38mm, Watch40mm, Watch42mm, Watch44mm, Unknown
}

extension WKInterfaceDevice {
    class func currentResolution() -> WatchResolution {
        let watch38mmRect = CGRect(x: 0, y: 0, width: 136, height: 170)
        let watch40mmRect = CGRect(x: 0, y: 0, width: 162, height: 197)
        let watch42mmRect = CGRect(x: 0, y: 0, width: 156, height: 195)
        let watch44mmRect = CGRect(x: 0, y: 0, width: 184, height: 224)
        
        let currentBounds = WKInterfaceDevice.current().screenBounds
        
        switch currentBounds {
        case watch38mmRect:
            return .Watch38mm
        case watch40mmRect:
            return .Watch40mm
        case watch42mmRect:
            return .Watch42mm
        case watch44mmRect:
            return .Watch44mm
        default:
            return .Unknown
        }
    }
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    //MARK: Vars
    //
    @IBOutlet var tableView: WKInterfaceTable!
    
    var _context: NSManagedObjectContext!
    
    var myTrackTypes : [MyTypes] = []
    var myTracker : [Tracker] = []

    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    //MARK: View Controller Methods
    //
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let session = watchSession {
            session.delegate = self
            session.activate()
        }
        // Configure interface objects here.
        _context = WatchCoreDataManager.managedObjectContext()
        
        WatchCoreDataManager.addTrackerTypes()
        
        deleteOldTracker()
        
        getDataTypes()
        reloadTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //loadDataFromDatastore()
        watchSession = WCSession.default
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: Session Delegate Methods
    //
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        watchSession?.activate()
        print("Session activation did complete")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            print("watch received app context: ", applicationContext)
            self.processApplicationContext(iPhoneContext: applicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
    }
    
    //MARK: Main Methods
    //
    func sendDataToMainDev(type: String, val: Any) {
        let session = WCSession.default
        if session.isReachable {
            
            let dataValues = ["type": type,"value": val]
            
            session.sendMessage(dataValues,
                                replyHandler: { reply in
                                    //self.statusLabel.setHidden(false)
                                    //self.statusLabel.setText(reply["status"] as? String)
            }, errorHandler: { error in
                //
            })
        }
    }
    
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
    
    func deleteOldMyTypes(){
        
        do{
            
            let request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
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
        
        if WKInterfaceDevice.currentResolution() == WatchResolution.Watch42mm  || WKInterfaceDevice.currentResolution() == WatchResolution.Watch44mm{
            name_by_size = name
        }
        else{
            name_by_size = name + "_38"
        }
        
        resImage = UIImage.init(named: name_by_size)!
        
        return resImage
    }
    
    func reloadTable(){
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
    
    //iPhone <--> Watch Connection
    func updateMyTypesFromPhone(data: [String]){
        
        let typesFromPhone: [String] = data
        
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
    

    func processApplicationContext(iPhoneContext: [String : Any]) {
        
        //Delete here old MyTypes and add sync MyTypes from iPhone
        updateMyTypesFromPhone(data: iPhoneContext["types"] as! [String])
            
    }
    
}
