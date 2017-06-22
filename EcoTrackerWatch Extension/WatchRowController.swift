//
//  WatchRowController.swift
//  EcoTracker
//
//  Created by Olga Blinova on 22/05/2017.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity
import CoreData
import EcoTrackerWatchKit

class WatchRowController: NSObject {
    
    @IBOutlet var typeImage: WKInterfaceImage!
    @IBOutlet var greenButton: WKInterfaceButton!
    @IBOutlet var yellowButton: WKInterfaceButton!
    @IBOutlet var greyButton: WKInterfaceButton!
    
    var _context: NSManagedObjectContext!
    //var parentController : AddViewController?
    var typeName: String!
    var fullName: String!
    var typeValue: Int16 = 0
    let valueDone: Int16 = 10
    let valuePersent: Int16 = 5
    
    override init() {
        _context = WatchCoreDataManager.managedObjectContext()
    }
    
    func getToday(dt: NSDate) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dt as Date)
        
        return dateString
    }
    //Check func is done the Type
    func isDoneThisType(name: String, for_days: Int) -> Bool {
        
        //At first - check this in DoneTypes
        let _request = NSFetchRequest<DoneTypes>(entityName: "DoneTypes")
        _request.predicate = NSPredicate(format: "type=%@",name)
        do{
            let _result = try _context.fetch(_request)
            if _result.count > 0 {
                return false
            }
        }
        catch{
            print("Error check is Done Type!")
            return false
        }
        
        //Get date from today-for_days
        let today = Date()
        var query_date_components = DateComponents()
        query_date_components.day = -for_days
        let query_date = Calendar.current.date(byAdding: query_date_components, to: today)
        
        //array from DB
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "type=%@ and dt>=%@ and dt<=%@",name,query_date! as CVarArg,today as CVarArg)
        do{
            let result = try _context.fetch(request)
            
            if result.count >= for_days {
                return true
            }
            else{
                return false
            }
        }
        catch{
            print("Error check is Done Type!")
            return false
        }
    }

    
    //Save by typeName state value on today
    func saveTypeState(state: String){
        
        //Delete on today by typeName
        do {
            let startDate = Calendar.current.startOfDay(for: NSDate() as Date)
            let dateStringFormatter = DateFormatter()
            dateStringFormatter.dateFormat="yyyy-MM-dd HH:mm:ss ZZZ"
            let end_date = dateStringFormatter.date(from: String(describing: NSDate()))!
            
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format: "type=%@ and dt>=%@ and dt<=%@",typeName,startDate as CVarArg,end_date as CVarArg)
            let for_del = try _context.fetch(request)
            
            for del in for_del {
                _context.delete(del)
            }
        } catch {
            print("There was an error fetching Del for Type Operations.")
        }
        
        if (state != "None") {
            //Add in Tracker
            let trackObject = WatchCoreDataManager.insertManagedObject(className: NSStringFromClass(Tracker.self) as NSString, managedObjectContext: _context) as! Tracker
            trackObject.dt    = NSDate()
            trackObject.today = getToday(dt: NSDate())
            trackObject.type  = typeName
            
            if (state == "Done") {
                trackObject.value = valueDone
            }
            else if(state == "Persent"){
                trackObject.value = valuePersent
            }
            
            //Add into DoneTypes if check is OK!
            //Insert here check func!!!!!
            if isDoneThisType(name: typeName, for_days: 21) {
                //Add
                let doneTypeObject = WatchCoreDataManager.insertManagedObject(className: NSStringFromClass(DoneTypes.self) as NSString, managedObjectContext: _context) as! DoneTypes
                doneTypeObject.dt    = NSDate()
                doneTypeObject.state = "21"
                doneTypeObject.type  = typeName
            }
        }
        
        //Save data to CoreData
        if WatchCoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
            print("Error add in Check-List!")
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
    
    @IBAction func acitonOnGrey() {
        saveTypeState(state: "None")
        sendDataToMainDev(type: typeName, val: 0)
        self.greyButton.setBackgroundImage(getImageBySize(name: "grey_on_button"))
        self.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
        self.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
    }
    
    @IBAction func actionOnYellow() {
        saveTypeState(state: "Persent")
        sendDataToMainDev(type: typeName, val: 5)
        self.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_on_button"))
        self.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
        self.greenButton.setBackgroundImage(getImageBySize(name: "green_off_button"))
    }
    
    @IBAction func actionOnGreen() {
        saveTypeState(state: "Done")
        sendDataToMainDev(type: typeName, val: 10)
        self.greenButton.setBackgroundImage(getImageBySize(name: "green_on_button"))
        self.yellowButton.setBackgroundImage(getImageBySize(name: "yellow_off_button"))
        self.greyButton.setBackgroundImage(getImageBySize(name: "grey_off_button"))
    }
    
    func sendDataToMainDev(type: String, val: Any) {
        let session = WCSession.default()
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
    
}
