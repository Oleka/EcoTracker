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
    
    func changeOrientation(){
        if(UIDevice.current.orientation != UIDeviceOrientation.landscapeRight)
        {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
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
    
    func getDay(dd:Date) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
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
        
        if (self.periodTypeControl.selectedSegmentIndex == 2) {
            changeOrientation()
        }
        
        //clear at first
        let sublayers = period_View.layer.sublayers
        if sublayers != nil {
            for layer in sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        period_View.addSubview(loadPeriod(tracker_width: tableView.bounds.width-70))
        period_View.setNeedsDisplay()
        
        tableView.reloadData()
        
    }
    
    let beginX: Int = 0
    let beginY: Int = 0
    var blockWidth: Int = 20
    var searched : [Tracker] = []
    
    var beginDate:  Date? = nil
    var endDate:    Date? = nil
    
    
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
            //For mounth
            //Find Mon in previous week from beginDate
            let beginDateComponents = Calendar.current.dateComponents([.weekOfYear, .year], from: beginDate!)
            let begin_week = beginDateComponents.weekOfYear
            
            //Create date Mon previous
            var firstDayComponents = DateComponents()
            firstDayComponents.year = beginDateComponents.year
            firstDayComponents.weekOfYear = begin_week!
            firstDayComponents.weekday = 2
            let firstDay = Calendar.current.date(from: firstDayComponents)
            beginDate = firstDay!
            endDate    = Date()
            days = endDate!.days(from: firstDay!)+1
            
            blockWidth = Int(tracker_width)/37
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
        var offsetX: Int = 70 //type_image_width
        let offsetY: Int = 0
        
        var i: Int = 0
        var today: Date = Date()
        var week_day: Int = 0
        
        //Define width of blocks by SegmentIndex
        if (self.periodTypeControl.selectedSegmentIndex == 0) {
            
            //Week
            //Find Mon in week today
            let beginDateComponents = Calendar.current.dateComponents([.weekday, .weekOfYear, .year], from: Date())
           
            //Create date Mon previous
            var firstDayComponents = DateComponents()
            firstDayComponents.year = beginDateComponents.year
            firstDayComponents.weekOfYear = beginDateComponents.weekOfYear
            firstDayComponents.weekday = 2
            beginDate = Calendar.current.date(from: firstDayComponents)
            today = beginDate!
            
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = Int(tracker_width)/7
            
            while i < days {
                let periodLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth) , height: 20.0)))
                if i==0 {
                    periodLabel.text = "\(getDay(dd:today))\(getMonth(dd:beginDate!))"
                }
                else{
                    periodLabel.text = getDay(dd:today)
                }
                periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                periodLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                periodLabel.textAlignment = .center
                
                tracker_view.addSubview(periodLabel)
                
                //for next
                offsetX += blockWidth
                today = today.addingTimeInterval(1*60*60*24)
                i += 1
            }
            
        }
        else if (self.periodTypeControl.selectedSegmentIndex == 1) {
            //Month
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .month], from: Date())) as Date?
            endDate    = Date()
            
            blockWidth = Int(tracker_width)/37
            
            //For mounth
            //Find Mon in previous week from beginDate
            let beginDateComponents = Calendar.current.dateComponents([.weekOfYear, .year], from: beginDate!)
            let begin_week = beginDateComponents.weekOfYear
            
            //Create date Mon previous
            var firstDayComponents = DateComponents()
            firstDayComponents.year = beginDateComponents.year
            firstDayComponents.weekOfYear = begin_week!
            firstDayComponents.weekday = 2
            let firstDay = Calendar.current.date(from: firstDayComponents)
            today = firstDay!
            days = endDate!.days(from: firstDay!)+1
            
            while i < days {
                
                if i==0 {
                    let periodLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*7) , height: 20.0)))
                    periodLabel.text = "\(getDay(dd:today))\(getMonth(dd:today))"
                    
                    periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    periodLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                    periodLabel.textAlignment = .left
                    
                    tracker_view.addSubview(periodLabel)
                    
                    
                }
                else{
                    
                        var periodLabel: UILabel = UILabel()
                        periodLabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*7) , height: 20.0)))
                    
                        //only week_day=1
                        let todayComponents = Calendar.current.dateComponents([.weekday], from: today)
                        week_day = todayComponents.weekday!
                        
                        if (week_day == 2){
                            periodLabel.text = getDay(dd:today)
                        }
                        else{
                            periodLabel.text = " "
                            
                        }
                        
                        periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        periodLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
                        periodLabel.textAlignment = .left
                        
                        tracker_view.addSubview(periodLabel)
                        
                        
                }
                
                //for next
                offsetX += blockWidth
                today = today.addingTimeInterval(1*60*60*24)
                i += 1
            }

            
        }
        else{
            //Year
            var offsetX: Double = 70.0 //type_image_width
            let offsetY: Double = 0.0
            beginDate = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))
            endDate    = Date()
            
            let blockWidth: Double = Double(tracker_width/365)
            print("tracker_width=\(tracker_width)")
            print("blockWidth=\(blockWidth)")
            today = beginDate!
            
            while i < 12 {
                
                let dayInMonth = (Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: today)?.days(from: today))!+1
                    print("days in month=\(dayInMonth)")
                    print("today=\(today)")
                    print("blockWidth*dayInMonth=\(blockWidth*Double(dayInMonth))")
                
                var periodLabel: UILabel = UILabel()
                periodLabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*Double(dayInMonth)) , height: 20.0)))
                
                
                periodLabel.text = "\(getMonth(dd:today))"
                
                periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                periodLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightThin)
                    periodLabel.textAlignment = .left
                    
                tracker_view.addSubview(periodLabel)
                
                //for next
                offsetX += blockWidth*Double(dayInMonth)
                today = Calendar.current.date(byAdding: DateComponents(month: 1), to: today)!
                i += 1
            }

        }
        
       
        return tracker_view
    }

    //Standart
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //Orientation change
        if UIDevice.current.orientation.isPortrait {
            if(self.periodTypeControl.selectedSegmentIndex == 2){
                self.periodTypeControl.selectedSegmentIndex = 1
            }
        }
        
        tableView.reloadData()
        
        //clear at first
        let sublayers = period_View.layer.sublayers
        if sublayers != nil {
            for layer in sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        period_View.addSubview(loadPeriod(tracker_width: size.width-70))
        period_View.setNeedsDisplay()
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getDataTypes()
        
        //clear at first
        let sublayers = period_View.layer.sublayers
        if sublayers != nil {
            for layer in sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        period_View.addSubview(loadPeriod(tracker_width: self.view.bounds.width-70))
        
        period_View.setNeedsDisplay()
        
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
