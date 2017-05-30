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

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var _context: NSManagedObjectContext!
    
    var myTrackTypes : [MyTypes] = []
    var myTracker : [Tracker] = []
    
    func getDataTypes(){
        
        do{
            myTrackTypes = try _context.fetch(MyTypes.fetchRequest())
            
            let startDate = Calendar.current.startOfDay(for: NSDate() as Date)
            
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format: "dt>=%@ AND dt<=%@",startDate as CVarArg, NSDate() as CVarArg)
            myTracker = try _context.fetch(request)
        }
        catch{
            print("Fetching Error!")
        }
        
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        _context = WatchCoreDataManager.managedObjectContext()
        
        WatchCoreDataManager.addTrackerTypes()
        
        getDataTypes()
        
        // Configure interface objects here.
        
        tableView.setNumberOfRows(myTrackTypes.count, withRowType: "watchRow")
        
        for (index, member) in myTrackTypes.enumerated() {
            
            let controller = tableView.rowController(at: index) as! WatchRowController
            
            controller.typeImage.setImage(UIImage.init(named: "\(String(describing: member.name!)).png"))
            
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
