//
//  TrackerViewController.swift
//  EcoTracker
//
//  Created by Oleka on 23/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
            
        }
    }
}

extension String{
    func date(format:String) -> Date?
    {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as TimeZone!
        formatter.dateFormat = format
        //formatter.timeZone = NSTimeZone.local
        return formatter .date(from: self)
    }
}

extension Date {
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day!
    }
}

class TrackerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var periodTypeControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var period_View: UIView!
    
    var trackTypes : [MyTypes] = []
    
    func getDate(dd:Date) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dd as Date)
        
        return dateString
    }
    
    func getMonth(dd:Date) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        dateString = dateFormatter.string(from: dd as Date)
        
        return dateString
    }
    
    func getDataTypes(){
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            trackTypes = try _context.fetch(MyTypes.fetchRequest())
        }
        catch{
            print("Fetching Error!")
        }
        
    }
    
    
    
    @IBAction func changePeriod(_ sender: Any) {
        
        //clear at first
        let sublayers = period_View.layer.sublayers
        if sublayers != nil {
            for layer in sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        period_View.addSubview(loadPeriod(tracker_width: tableView.bounds.width-70))
        print("w in period=\(tableView.bounds.width-70)")
        period_View.setNeedsDisplay()
        tableView.reloadData()
        
    }
    
    let beginX: Int = 0
    let beginY: Int = 0
    var blockWidth: Int = 20
    var searched : [Tracker] = []
    
    var beginDate:  Date? = nil
    var endDate:    Date? = nil
    
    
//    func loadTracker(tr_type: String) -> UIView{
//        
//        let tracker_view: UIView = TrackerBlock(frame: CGRect(x: 0.0, y: 0.0, width: 300, height: 50))
//        tracker_view.backgroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
//        
//        //Define width of blocks by SegmentIndex
//        if (self.periodTypeControl.selectedSegmentIndex == 0) {
//            //Week
//            blockWidth = 20
//            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as NSDate?
//            endDate    = NSDate()
//        }
//        else if (self.periodTypeControl.selectedSegmentIndex == 1) {
//            //Month
//            blockWidth = 10
//            beginDate  = NSDate()
//            endDate    = NSDate()
//        }
//        else{
//            //Year
//            blockWidth = 2
//            beginDate  = NSDate()
//            endDate    = NSDate()
//        }
//        
//        //Get data from DB selected by periodTypeControl
//        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        do {
//            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
//            request.predicate = NSPredicate(format:"type=%@ and dt>=%@ AND dt<=%@",tr_type, beginDate!, endDate!)
//            searched = try _context.fetch(request)
//            
//            var offsetX: Int = beginX
//            let offsetY: Int = beginY
//            
//            
//            for track in searched {
//                
//                //Define block color
//                var blockColor: UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)//gray
//                
//                if track.value == 5 {
//                    blockColor = .yellow
//                }
//                else if track.value == 10 {
//                    blockColor = UIColor(red: 84.0/255.0, green: 197.0/255.0, blue: 24.0/255.0, alpha: 1.0)//green
//                }
//                else{
//                    blockColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)//gray
//                }
//                
//                //Load block
//                let block = TrackerBlock(frame: CGRect(x: offsetX, y: offsetY, width: Int(blockWidth), height: 50))
//                block.backgroundColor = blockColor
//                
//                tracker_view.addSubview(block)
//                
//                offsetX += blockWidth
//                
//            }
//            
//        } catch {
//            print("There was an error fetching.")
//        }
//        
//        return tracker_view
//    }
    
    func loadTrackerForPeriod(tr_type: String, tracker_width: CGFloat) -> UIView{
        
        let tracker_view: UIView = TrackerBlock(frame: CGRect(x: 0.0, y: 0.0, width: tracker_width, height: 50))
        tracker_view.backgroundColor = .clear
        
        //Days between
        var days: Int = 0
        
        //Define width of blocks by SegmentIndex
        if (self.periodTypeControl.selectedSegmentIndex == 0) {
            //Week
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/7
        }
        else if (self.periodTypeControl.selectedSegmentIndex == 1) {
            //Month
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .month], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/30
        }
        else{
            //Year
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .year], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/365
        }
        
        //Get data from DB selected by periodTypeControl
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format:"type=%@ and dt>=%@ AND dt<=%@",tr_type, beginDate! as CVarArg, endDate! as CVarArg)
            searched = try _context.fetch(request)
            
            var offsetX: Int = beginX
            let offsetY: Int = beginY
            
            var i: Int = 0
            var today: Date = beginDate!
            
            while i < days {
                
                //Filter searched by today
                let namePredicate = NSPredicate(format: "today like %@",getDate(dd: today));
                let filteredArray = searched.filter { namePredicate.evaluate(with: $0) };
                
                //Define block color
                var blockColor: UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)//gray
                
                if filteredArray.count==0 {
                    //no data today!
                    //Define block color
                    blockColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)//gray
                }
                else{
                    if filteredArray[0].value == 5 {
                        blockColor = .yellow
                    }
                    else if filteredArray[0].value == 10 {
                        blockColor = UIColor(red: 84.0/255.0, green: 197.0/255.0, blue: 24.0/255.0, alpha: 1.0)//green
                    }
                }
                
                //Load block
                let block = TrackerBlock(frame: CGRect(x: offsetX, y: offsetY, width: Int(blockWidth), height: 50))
                block.backgroundColor = blockColor
                
                tracker_view.addSubview(block)
                
                offsetX += blockWidth
                today = today.addingTimeInterval(1*60*60*24)
                i += 1
            }
            
            
        } catch {
            print("There was an error fetching.")
        }
        
        return tracker_view
    }

    //View_Perod
    func loadPeriod(tracker_width: CGFloat) -> UIView{
        
        let tracker_view: UIView = TrackerBlock(frame: CGRect(x: 0.0, y: 0.0, width: tracker_width, height: 50))
        tracker_view.backgroundColor = .clear
        
        //Days between
        var days: Int = 0
        
        //Define width of blocks by SegmentIndex
        if (self.periodTypeControl.selectedSegmentIndex == 0) {
            //Week
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/7
        }
        else if (self.periodTypeControl.selectedSegmentIndex == 1) {
            //Month
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .month], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/30
        }
        else{
            //Year
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .year], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/365
        }
        
        
            var offsetX: Int = 70 //type_image_width
            let offsetY: Int = 0
            
            var i: Int = 0
            var today: Date = beginDate!
            var week_day: Int = 1
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "e"
            let dayOfWeekString = dateFormatter.string(from: beginDate!)
            print(dayOfWeekString)
        
            while i < days {
                
                let periodLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth) , height: 20.0)))
                
                if i==0 {
                    periodLabel.text = "\(String(i+1))\(getMonth(dd:beginDate!))"
                }
                else{
                    //Day by week in mounth
                    if (self.periodTypeControl.selectedSegmentIndex == 1){
                        //only week_day=1
                        if week_day == 1 {
                            periodLabel.text = String(i+1)
                        }
                        else{
                           periodLabel.text = " "
                        }
                    }
                    else {
                        periodLabel.text = String(i+1)
                    }
                }
                    
                periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                periodLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                periodLabel.textAlignment = .center
                
                tracker_view.addSubview(periodLabel)
                
                //for next
                offsetX += blockWidth
                today = today.addingTimeInterval(1*60*60*24)
                i += 1
                if week_day>6 {
                    week_day = 1
                }
                else{
                    week_day += 1
                }
            }
        
        return tracker_view
    }

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let log = trackTypes[indexPath.row]
        
        let cellId: String = "MyCell"
        let cell: TrackerTableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TrackerTableViewCell
        
        cell.typeImage.image = UIImage.init(named: "\(log.name!).png")
        
        //clear at first
        let sublayers = cell.dataView.layer.sublayers
        
        if sublayers != nil {
            for layer in sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        cell.dataView.addSubview(loadTrackerForPeriod(tr_type: log.name!, tracker_width: cell.contentView.bounds.width-70))
        print("w in table=\(cell.contentView.bounds.width-70)")
        cell.selectionStyle = .none
        cell.typeName         = log.name!
        cell.parentController = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
