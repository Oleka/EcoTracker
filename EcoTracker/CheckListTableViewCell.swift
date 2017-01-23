//
//  CheckListTableViewCell.swift
//  EcoTracker
//
//  Created by Oleka on 09/01/17.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class CheckListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var check_dontButton: UIButton!
    @IBOutlet weak var check_persentButton: UIButton!
    @IBOutlet weak var check_doneButton: UIButton!
    @IBOutlet weak var typeImage: UIImageView!
    
    var parentController : AddViewController?
    var typeName: String!
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
    
    //Check func is done the Type
    func isDoneThisType(name: String, for_days: Int) -> Bool {
        
        //Get date from today-for_days
        let today = Date()
        var query_date_components = DateComponents()
        query_date_components.day = -for_days
        let query_date = Calendar.current.date(byAdding: query_date_components, to: today)
        
        //array from DB
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
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
            let log = Tracker(context: _context)
            log.dt    = NSDate()
            log.today = getToday(dt: NSDate())
            log.type  = typeName
            
            if (state == "Done") {
                log.value = valueDone
            }
            else if(state == "Persent"){
                log.value = valuePersent
            }
            
            //Add into DoneTypes if check is OK!
            //Insert here check func!!!!!
            if isDoneThisType(name: typeName, for_days: 21) {
                //Add
                let donetype = DoneTypes(context: _context)
                donetype.dt    = NSDate()
                donetype.state = "21"
                donetype.type  = typeName
            }
        }
        
        //Save data to CoreData
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    override func prepareForReuse() {
        
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
