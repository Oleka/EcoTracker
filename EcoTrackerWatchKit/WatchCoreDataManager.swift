//
//  WatchCoreDataManager.swift
//  EcoTracker
//
//  Created by Olga Blinova on 22/05/2017.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

public class WatchCoreDataManager: NSObject {
    
    class func sharedAppGroup()->String{
        return "group.ru.olistudio.EcoTracker"
    }
    
    
    class func mangedObjectModel()->NSManagedObjectModel{
        
        let proxyBundle = Bundle(identifier: "ru.Olistudio.EcoTrackerWatchKit")
        
        let modelURL = proxyBundle?.url(forResource: "EcoTracker", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL!)!
        
    }
    
    class func persistantStoreCoordinator()->NSPersistentStoreCoordinator? {
        let error:NSError? = nil
        
        let sharedContainerURL:URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: WatchCoreDataManager.sharedAppGroup())
        if let sharedContainerURL = sharedContainerURL {
            let storeURL = sharedContainerURL.appendingPathComponent("EcoTracker.sqlite")
            let coordinator:NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: WatchCoreDataManager.mangedObjectModel())
            
            do {
                _ = try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                
            }
            catch{
                print(error)
                abort()
            }
            
            return coordinator
            
        }
        else{
            print(error!)
            return nil
        }
    }
    
    public class func managedObjectContext()->NSManagedObjectContext {
        let coordinator = WatchCoreDataManager.persistantStoreCoordinator()
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }
    
    
    public class func insertManagedObject(className:NSString, managedObjectContext:NSManagedObjectContext)->AnyObject{
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: className as String, into: managedObjectContext)
        
        return managedObject
        
    }
    
    public class func saveManagedObjectContext (managedObjectContext:NSManagedObjectContext)->Bool {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
            return true
        }
        
        return false
        
    }
    
    public class func fetchEntities (className:NSString, withPredicate predicate:NSPredicate?, andSortDescriptor sortDescriptor:NSSortDescriptor?, managedObjectContext:NSManagedObjectContext)->NSArray {
        
        var items: NSArray = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: className as String, in: managedObjectContext)
        
        fetchRequest.entity = entityDescription
        
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        
        if sortDescriptor != nil {
            fetchRequest.sortDescriptors = [sortDescriptor!]
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            items = try managedObjectContext.fetch(fetchRequest) as NSArray
            
        }
        catch{
            NSLog("Fetch data error!")
        }
        return items as NSArray
    }
    
    public class func addTrackerTypes(){
        
        //Types into new DB
        var _context: NSManagedObjectContext!
        _context = self.managedObjectContext()
        
        //If exist - check this!
        
            //let _request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
            //let res = try _context.fetch(_request)
            let res = self.fetchEntities(className: NSStringFromClass(MyTypes.self) as NSString, withPredicate: nil, andSortDescriptor: nil, managedObjectContext: _context)
            if res.count>0 {
                //OK!
            }
            else{
                //Read from .Plist and add all as new
                let path = Bundle.main.path(forResource: "TrackerTypes", ofType: "plist")
                let tr_types = NSDictionary(contentsOfFile: path!)
                
                for tr_type in tr_types! {
                    
                    //Add into MyTypes
                    let addMyTypeObject = self.insertManagedObject(className: NSStringFromClass(MyTypes.self) as NSString, managedObjectContext: _context) as! MyTypes
                    addMyTypeObject.name       = String(describing: tr_type.key)
                    addMyTypeObject.full_name  = String(describing: tr_type.value)
                    
                }
                //Save data to CoreData
                if self.saveManagedObjectContext(managedObjectContext: _context) == false{
                    print("Error saving Types, MyTypes!")
                }
            }
        
    }

}
