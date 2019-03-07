//
//  CheckListTableViewCell.swift
//  EcoTracker
//
//  Created by Oleka on 09/01/17.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData
import EcoTrackerKit

class CheckListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var check_dontButton: UIButton!
    @IBOutlet weak var check_persentButton: UIButton!
    @IBOutlet weak var check_doneButton: UIButton!
    @IBOutlet weak var typeImage: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var _context: NSManagedObjectContext!
    var parentController : AddViewController?
    var typeName: String!
    var fullName: String!
    var typeValue: Int16 = 0
    let valueDone: Int16 = 10
    let valuePersent: Int16 = 5
    
    func getToday(dt: NSDate) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dt as Date)
        
        return dateString
    }
    
    
    
    @IBAction func tapAction(sender: Any) {
        if self.nameLabel.isHidden {
            self.nameLabel.isHidden = false
            self.nameLabel.text = self.fullName
        }
        else{
            self.nameLabel.isHidden = true
            self.nameLabel.text = ""
        }
    }
    
    @IBAction func tapEnd(sender: Any) {
        if self.nameLabel.isHidden == false {
            self.nameLabel.isHidden = true
            self.nameLabel.text = ""
        }
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
            let trackObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(Tracker.self) as NSString, managedObjectContext: _context) as! Tracker
            trackObject.dt    = NSDate() as Date
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
                let doneTypeObject = CoreDataManager.insertManagedObject(className: NSStringFromClass(DoneTypes.self) as NSString, managedObjectContext: _context) as! DoneTypes
                doneTypeObject.dt    = NSDate() as Date
                doneTypeObject.state = "21"
                doneTypeObject.type  = typeName
            }
        }
        
        //Save data to CoreData
        if CoreDataManager.saveManagedObjectContext(managedObjectContext: self._context) == false{
            print("Error add in Check-List!")
        }
        
    }
    
    @IBAction func set_Done(_ sender: Any) {
        
        check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
        check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
        check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
        
        check_persentButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        
        saveTypeState(state: "Done")
        
        parentController?.animateButton(imageNameForState: "green_leaf.png")
        parentController?.getDataTypes()
    }
    
    @IBAction func set_Persent(_ sender: Any) {
        
        check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
        check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
        check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
        
        check_doneButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        
        saveTypeState(state: "Persent")
        parentController?.animateButton(imageNameForState: "yellow_leaf.png")
        parentController?.getDataTypes()
    }
    
    @IBAction func set_None(_ sender: Any) {
        check_dontButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
        check_dontButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
        check_dontButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
        
        check_doneButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        check_persentButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        
        saveTypeState(state: "None")
        parentController?.animateButton(imageNameForState: "grey_leaf.png")
        parentController?.getDataTypes()
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.isHidden = true
        _context = CoreDataManager.managedObjectContext()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
    override func prepareForReuse() {
        
        nameLabel.isHidden = true
        check_doneButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        check_persentButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        check_dontButton.setImage(UIImage.init(named: "Check_off.png"), for: .normal)
        
        //Check by data value
        if (typeValue == 10){
            check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
            check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
            check_doneButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
        }
        else if(typeValue == 5){
            check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .normal)
            check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .selected)
            check_persentButton.setImage(UIImage.init(named: "Check_on.png"), for: .highlighted)
        }
        
    }
}
