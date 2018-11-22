//
//  ViewController.swift
//  EcoTracker
//
//  Created by Oleka on 23/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData
import EcoTrackerKit
import WatchConnectivity

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

class AddViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate,WCSessionDelegate {
    
    @IBAction func syncMyTypes(_ sender: Any) {
        sendMyTypesToWatch(ses: session!)
    }
    @IBOutlet weak var leafButton: UIButton!
    
    @IBOutlet weak var watchButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hi_View: UIImageView!
    
    @IBOutlet weak var bg_View: UIImageView!
    
    var _context: NSManagedObjectContext!
    
    var myTrackTypes : [MyTypes] = []
    var myTracker : [Tracker] = []
    
    var watchTracker: [String : Any] = [:]
    
    var session: WCSession?
    var isWatchPared: Bool = false
    
    func getPoints(dt: NSDate) -> String {
        
        var points: String = "0"
        
        //Select Value sum on date dt
        
        let startDate = Calendar.current.startOfDay(for: dt as Date)
        
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        
        request.predicate = NSPredicate(format: "dt>=%@ and dt<=%@",startDate as CVarArg,dt as CVarArg)
        
        do {
            let results = try _context.fetch(request)
            
            var pp: Int16 = 0
            for res in results {
                pp += res.value
            }
            
            points = String(pp)
            
        } catch _ {
            // If it fails, ensure the array is nil
            points = "0"
        }
        
        
        return points
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        //do som stuff from the popover
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue for the popover configuration window
        if segue.identifier == "infoPopOver" {
            if let controller = segue.destination as? InfoViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 140, height: 140)
                controller.pointsValue = getPoints(dt: NSDate())
                controller.view.cornerRadius=70
                controller.popoverPresentationController?.backgroundColor = .clear
                
            }
        }
    }
    
    
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
    
    //Animate
    func animateButton(imageNameForState: String){
        //Animation
        
        UIView.animate(withDuration: 0.6, animations:{
            self.leafButton.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3)
            self.leafButton.setImage(UIImage.init(named: imageNameForState), for: .normal)
        },
                       completion:{
                        (finish: Bool) in UIView.animate(withDuration: 0.2, animations:{
                            self.leafButton.transform = CGAffineTransform.identity
                        })
                        
        })
    }
    
    
    func isNewUser() -> Bool {
        
        let _request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
        do{
            let res = try _context.fetch(_request)
            if res.count>0 {
                return false
            }
            else{
                return true
            }
        }
        catch{
            return true
        }
    }
    
    func addTrackerTypes(){
        
        //Types into new DB
        
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
                    let addTypeObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(Types.self) as NSString, managedObjectContext: _context) as! Types
                    addTypeObject.name       = String(describing: tr_type.key)
                    addTypeObject.full_name  = String(describing: tr_type.value)
                    
                    //Add into MyTypes
                    let addMyTypeObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(MyTypes.self) as NSString, managedObjectContext: _context) as! MyTypes
                    addMyTypeObject.name       = String(describing: tr_type.key)
                    addMyTypeObject.full_name  = String(describing: tr_type.value)
                    
                }
                //Save data to CoreData
                if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
                    print("Error saving Types, MyTypes!")
                }
            }
        } catch {
            print("There was an error fetching Types.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        //For watch
        setupConnectivity()
        if isWatchPared == false{
            self.watchButton.isHidden = true
        }
        else{
           self.watchButton.isHidden = false
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            _context = CoreDataManager.managedObjectContext()
            dateLabel.text = "Сегодня \(getDate(dd: NSDate()))"
            getDataTypes()
            tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //_context = CoreDataManager.managedObjectContext()
        if isNewUser() {
            UIApplication.shared.statusBarView?.backgroundColor = .clear
            let introController = self.storyboard?.instantiateViewController(withIdentifier: "CheckListIntro") as! ChIntroViewController
            self.present(introController, animated: true, completion: {
                self.addTrackerTypes()
            })
            
        }
        else{
            UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getDate (dd:NSDate) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateString = dateFormatter.string(from: dd as Date)
        
        return dateString
    }
    
    
    
    //Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTrackTypes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId: String = "MyCell"
        let cell: CheckListTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CheckListTableViewCell
        
        let log = myTrackTypes[indexPath.row]
        cell.typeImage.setImage(UIImage.init(named: "\(String(describing: log.name!)).png"), for: .normal)
        cell.typeImage.imageEdgeInsets = UIEdgeInsetsMake(60,60,60,60)
        
        cell.typeName = log.name
        cell.fullName = log.full_name
        cell.selectionStyle = .none
        cell.parentController = self
        
        let namePredicate = NSPredicate(format: "type like %@",log.name!);
        let filteredArray = myTracker.filter { namePredicate.evaluate(with: $0) };
        
        if(filteredArray.count>0){
            cell.typeValue = filteredArray[0].value
            //Check by data value
            if (filteredArray[0].value == 10){
                cell.check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
                cell.check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
                cell.check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
                
                cell.check_persentButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
                cell.check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
            }
            else if(filteredArray[0].value == 5){
                cell.check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
                cell.check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
                cell.check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
                
                cell.check_doneButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
                cell.check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
            }
        }
        else{
            cell.typeValue = 0
            cell.check_doneButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
            cell.check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
            cell.check_persentButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    //Today form Date
    func getToday(dt: NSDate) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dt as Date)
        
        return dateString
    }
    
    //Watch sinc
    func updateCheckListFromWatch(){
        
        var typeName: String = ""
        var typeValue: Int16 = 0
        
        for watch_record in watchTracker {
            
            if (watch_record.key == "type"){
                typeName = watch_record.value as! String
            }
            else if (watch_record.key == "value"){
                typeValue = watch_record.value as! Int16
            }
        }
        
        //Update data from watch for today in iPhone base
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
        //Add from watch
       
        let trackObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(Tracker.self) as NSString,managedObjectContext: _context) as! Tracker
        trackObject.dt    = NSDate()
        trackObject.today = getToday(dt: NSDate())
        trackObject.type  = typeName
        trackObject.value = typeValue
        
        //Save data to CoreData
        if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
            print("Error add in Check-List!")
        }
        
        

    }
    
    // MARK:- Apple Watch connection
    fileprivate func setupConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            print("WCSession is supported")
            
            if !(session?.isPaired)! {
                print("Apple Watch is not paired")
                isWatchPared = false
            }
            
            if !(session?.isWatchAppInstalled)! {
                print("Apple Watch app is not installed")
                isWatchPared = false
            }
            else{
                isWatchPared = true
            }

        } else {
            print("Apple Watch connectivity is not supported on this device")
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        watchTracker = message
        
        DispatchQueue.main.async {
            //Update Check-list from Watch
            self.updateCheckListFromWatch()
            self.getDataTypes()
            self.tableView.reloadData()
        }
        
        let replyValues = ["status": "Data sent!"]
        replyHandler(replyValues)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    func sendMyTypesToWatch(ses: WCSession){
        do {
            //myTrackTypes
            var myTypesForWatch = [String: Any]()
            var myTypes  = [String]()
                    
            do{
                
                let myTypesFromPhone_request = NSFetchRequest<MyTypes>(entityName: "MyTypes")
                let myTypesFromPhone = try _context.fetch(myTypesFromPhone_request)
                for myTypesFromPhoneItem in myTypesFromPhone {
                    myTypes.append(myTypesFromPhoneItem.name!)
                }
            }
            catch{
                print("Fetching myTypesForWatch Error!")
            }
            
            myTypesForWatch["types"] = myTypes
                    
            try ses.updateApplicationContext(myTypesForWatch)
        } catch {
            print("Error: \(error)")
        }
    }
    
}

