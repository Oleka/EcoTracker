//
//  TypeViewController.swift
//  EcoTracker
//
//  Created by Oleka on 04/01/17.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData
import EcoTrackerKit
import WatchConnectivity

class TypeViewController: UIViewController,UITextViewDelegate,WCSessionDelegate {
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var describeText: UITextView!
    
    var _context: NSManagedObjectContext!
    var detail_type : [Types] = []
    var isSelected : Bool = false
    
    /*
    // MARK: - WCSessionDelegate Functions
    */
    var session: WCSession?
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { }
    
    /*
     // MARK: - UIViewController Functions
     */
    @IBAction func noSelectAction(_ sender: Any) {
        //Delete type from MyTypes
        do {
            let request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
            request.predicate = NSPredicate(format: "name=%@",detail_type[0].name!)
            let for_del = try _context.fetch(request)
            for del in for_del {
                _context.delete(del)
            }
            
            if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
                print("Error delete MyTypes!")
            }
            
            //Save to Apple Watch = delete type to MyTypes
            if (session?.isReachable)! {
                let iPhoneAppContext = ["delete_type": detail_type[0].name!]

                do {
                    try session?.updateApplicationContext(iPhoneAppContext)
                } catch {
                    print("Something went wrong")
                }
            }
            else{
                print("Error - type not be deleted!")
            }
        } catch {
            print("There was an error fetching Plus Operations.")
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func selectTypeAction(_ sender: Any) {
        
        //Add Type into MyTypes
        let addMyTypeObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(MyTypes.self) as NSString, managedObjectContext: _context) as! MyTypes
        addMyTypeObject.name       = String(describing: detail_type[0].name!)
        addMyTypeObject.full_name  = String(describing: detail_type[0].full_name!)
        addMyTypeObject.dateBegin  = NSDate()
        addMyTypeObject.is_notification = false
        
        //Save data to CoreData
        if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
            print("Error saving MyTypes!")
        }
        
        //Save to Apple Watch = add type to MyTypes
        if let validSession = session {
            let iPhoneAppContext = ["add_type": detail_type[0].name!]
            
            do {
                try validSession.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Something went wrong")
            }
        }
        else{
           print("Error - type not be added!")
        }
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.describeText.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _context = CoreDataManager.managedObjectContext()
        
        describeText.delegate = self
        // Do any additional setup after loading the view.
        typeImage.image = UIImage.init(named: "big_\(String(describing: detail_type[0].name!)).png")
        
        typeNameLabel.text = detail_type[0].full_name
        
        //Description from rtf
        if let rtf = Bundle.main.url(forResource: detail_type[0].name, withExtension: "rtf", subdirectory: nil, localization: nil) {
            
            do{
                let attributedString =
                    try NSAttributedString(url: rtf, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                describeText.attributedText = attributedString
                
            }catch{}
            
            describeText.isEditable = false
            // describeText.contentOffset = CGPoint.zero
        }
        else{
            describeText.text = "-"
            describeText.isEditable = false
        }
        
        if isSelected==true {
            selectButton.isHidden = true
            removeButton.isHidden = false
        }
        else{
            selectButton.isHidden = false
            removeButton.isHidden = true
        }
        
        // Apple Watch Support
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
        else{
            print("Apple Watch Support - not supported!")
        }
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
