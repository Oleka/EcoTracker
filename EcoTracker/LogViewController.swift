//
//  LogViewController.swift
//  EcoTracker
//
//  Created by Oleka on 23/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class LogViewController: UIViewController {
    
    @IBOutlet weak var doneStackView: UIStackView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var periodTypeControl: UISegmentedControl!
    @IBOutlet weak var period_View: UIView!
    @IBOutlet weak var data_View: UIView!
    @IBOutlet weak var periodByDate: UIView!
    
    
    let beginX: CGFloat = 0.0
    let beginY: Int = 83
    var blockWidth: CGFloat = 0.0
    var searched : [Tracker] = []
    
    var beginDate:  Date? = nil
    var endDate:    Date? = nil
    
    func changeOrientation(){
        if(UIDevice.current.orientation != UIDeviceOrientation.landscapeRight)
        {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
            //update data view
            
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
        period_View.addSubview(loadPeriod(tracker_width: period_View.bounds.width))
        period_View.setNeedsDisplay()
        
        //clear at first periodByDate
        let p_sublayers = periodByDate.layer.sublayers
        if p_sublayers != nil {
            for layer in p_sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        periodByDate.addSubview(loadTrackerForPeriod(tracker_width: periodByDate.bounds.width, tracker_Y: periodByDate.bounds.maxY))
    }

    
    func loadTrackerForPeriod(tracker_width: CGFloat, tracker_Y: CGFloat) -> UIView{
        
        let tracker_view: UIView = TrackerBlock(frame: CGRect(x: 0.0, y: 0.0, width: tracker_width, height: 300))
        tracker_view.backgroundColor = .clear
        
        //Days between
        var days: Int = 0
        
        //Define width of blocks by SegmentIndex
        if (self.periodTypeControl.selectedSegmentIndex == 0) {
            //Week
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = tracker_width/7
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
            
            blockWidth = tracker_width/37
        }
        else{
            //Year
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .year], from: Date())) as Date?
            endDate    = Date()
            days = endDate!.days(from: beginDate!)+1
            blockWidth = tracker_width/365
        }
        
        //Get data from DB selected by periodTypeControl
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format:"dt>=%@ AND dt<=%@", beginDate! as CVarArg, endDate! as CVarArg)
            searched = try _context.fetch(request)
            
            var offsetX: CGFloat = beginX
            let startY: CGFloat = tracker_Y+2
            
            var heightBlock: CGFloat = 0.0
            
            var i: Int = 0
            var today: Date = beginDate!
            
            while i < days {
                
                //Filter searched by today
                let namePredicate = NSPredicate(format: "today like %@",getDate(dd: today));
                let filteredArray = searched.filter { namePredicate.evaluate(with: $0) };
                
                //Define block color
                let blockColor: UIColor = UIColor(red: 0.0/255.0, green: 200.0/255.0, blue: 255.0/255.0, alpha: 1.0)//blue
                
                if filteredArray.count==0 {
                    //no data today!
                    heightBlock = 0.0
                }
                else{
                    
                    var sumValue : Int16 = 0
                    for fa in filteredArray {
                        sumValue += fa.value
                    }
                    
                    heightBlock = CGFloat(sumValue)*self.periodByDate.bounds.height/300.0
                       
                }
                
                //Load block
                let block = TrackerBlock(frame: CGRect(x: offsetX, y: startY-heightBlock, width: blockWidth, height: heightBlock))
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
        
        let tracker_view: UIView = TrackerBlock(frame: CGRect(x: 0.0, y: 0.0, width: tracker_width, height: 12))
        tracker_view.backgroundColor = .clear
        
        //Days between
        var days: Int = 0
        var offsetX: CGFloat = 0.0 //type_image_width
        let offsetY: CGFloat = 0.0
        
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
            blockWidth = tracker_width/7
            
            while i < days {
                let periodLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth) , height: 12.0)))
                if i==0 {
                    periodLabel.text = "\(getDay(dd:today))\(getMonth(dd:beginDate!))"
                }
                else{
                    periodLabel.text = getDay(dd:today)
                }
                periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                periodLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightThin)
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
            
            blockWidth = tracker_width/37
            
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
                    let periodLabel: UILabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*7) , height: 12.0)))
                    periodLabel.text = "\(getDay(dd:today))\(getMonth(dd:today))"
                    
                    periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    periodLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightThin)
                    periodLabel.textAlignment = .left
                    
                    tracker_view.addSubview(periodLabel)
                    
                    
                }
                else{
                    
                    var periodLabel: UILabel = UILabel()
                    periodLabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*7) , height: 12.0)))
                    
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
                    periodLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightThin)
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
            var offsetX: Double = 0.0 //type_image_width
            let offsetY: Double = 0.0
            beginDate = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))
            endDate    = Date()
            
            let blockWidth: Double = Double(tracker_width/365)
            
            today = beginDate!
            
            while i < 12 {
                
                let dayInMonth = (Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: today)?.days(from: today))!+1
                
                
                var periodLabel: UILabel = UILabel()
                periodLabel = UILabel(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: Double(blockWidth*Double(dayInMonth)) , height: 12.0)))
                
                
                periodLabel.text = "\(getMonth(dd:today))"
                
                periodLabel.textColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                periodLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightThin)
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

    func getDay(dd:Date) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
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
    
    func getDate(dd:Date) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dd as Date)
        
        return dateString
    }
    
    func getPoints() -> String {
        
        var points: String = "0"
        
        //Select Value sum on date dt
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //clear at first doneStackView
        let sublayers = doneStackView.arrangedSubviews
        //if sublayers != nil {
            for layer in sublayers {
                layer.removeFromSuperview()
            }
        //}
        
        getDoneTypes()
        pointsLabel.text = getPoints()
        
        
        //clear at first period_View
        let _sublayers = period_View.layer.sublayers
        if _sublayers != nil {
            for layer in _sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        period_View.addSubview(loadPeriod(tracker_width: periodByDate.bounds.width))
        period_View.setNeedsDisplay()
        
        
        //clear at first periodByDate
        let p_sublayers = periodByDate.layer.sublayers
        if p_sublayers != nil {
            for layer in p_sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        periodByDate.addSubview(loadTrackerForPeriod(tracker_width: periodByDate.bounds.width, tracker_Y: periodByDate.bounds.maxY))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // best call super just in case
        super.viewWillTransition(to: size, with: coordinator)
        
        // will execute before rotation
        coordinator.animate(alongsideTransition: { context in
            // do whatever with your context
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
            
            //Orientation change
            if self.periodTypeControl != nil {
                if UIDevice.current.orientation.isPortrait {
                    if(self.periodTypeControl.selectedSegmentIndex == 2){
                        self.periodTypeControl.selectedSegmentIndex = 1
                    }
                }
            }
            
            //Period update
            if self.period_View != nil {
                //clear at first
                let sublayers = self.period_View.layer.sublayers
                if sublayers != nil {
                    for layer in sublayers! {
                        layer.removeFromSuperlayer()
                    }
                }
                self.period_View.addSubview(self.loadPeriod(tracker_width: size.width-70))
                self.period_View.setNeedsDisplay()
            }
            
            //Data update
            if self.periodByDate != nil {
                //clear at first periodByDate
                let p_sublayers = self.periodByDate.layer.sublayers
                if p_sublayers != nil {
                    for layer in p_sublayers! {
                        layer.removeFromSuperlayer()
                    }
                }
                self.periodByDate.addSubview(self.loadTrackerForPeriod(tracker_width: self.periodByDate.bounds.width, tracker_Y: self.periodByDate.bounds.maxY))
            }
            
        }, completion: nil)
        
        
        // will execute after rotation
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func getDoneTypes(){
        
        var logs : [DoneTypes] = []
        
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            logs = try _context.fetch(DoneTypes.fetchRequest())
            
            var i: Int = 0
            var offsetX: Int = 0
            let offsetY: Int = 0
            //New view for 5 images
            
            //Stack View
            var stackViewForFive   = UIStackView()
            stackViewForFive.axis  = UILayoutConstraintAxis.horizontal
            stackViewForFive.distribution  = UIStackViewDistribution.equalSpacing
            stackViewForFive.alignment = UIStackViewAlignment.fill
            stackViewForFive.spacing   = 4.0
           
            if logs.count == 0 {
                
                
                var noDataView: UILabel = UILabel()
                noDataView.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 70, height: 20.0))
                noDataView.textAlignment = .left
                noDataView.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
                noDataView.textColor = .gray
                noDataView.numberOfLines = 4
                noDataView.text = "Здесь будет список ваших привычек, закрепленных по принципу выполнения двадцать один (21) день подряд"
                
                doneStackView.addArrangedSubview(noDataView)
                
                noDataView = UILabel()
                noDataView.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 70, height: 20.0))
                noDataView.textAlignment = .left
                noDataView.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
                noDataView.textColor = .gray
                noDataView.text = " "
                
                doneStackView.addArrangedSubview(noDataView)
                
                noDataView = UILabel()
                noDataView.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 70, height: 20.0))
                noDataView.textAlignment = .left
                noDataView.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
                noDataView.textColor = .gray
                noDataView.text = " "
                
                doneStackView.addArrangedSubview(noDataView)
                
            }
            else {
                for done_type in logs {
                
                    let imageView: UIImageView = UIImageView(frame: CGRect(origin: CGPoint(x: offsetX, y: offsetY), size: CGSize(width: 38.0 , height: 38.0)))
                    imageView.image = UIImage.init(named: "\(done_type.type!).png")
                
                    stackViewForFive.addArrangedSubview(imageView)
                
                    i += 1
                    if (i > 4) || (i == logs.count) {
                    
                        doneStackView.addArrangedSubview(stackViewForFive)
                    
                        i = 0
                        offsetX = 0
                        stackViewForFive   = UIStackView()
                        stackViewForFive.axis  = UILayoutConstraintAxis.horizontal
                        stackViewForFive.distribution  = UIStackViewDistribution.equalSpacing
                        stackViewForFive.alignment = UIStackViewAlignment.fill
                        stackViewForFive.spacing   = 4.0
                    
                    }
                }
            }
            
        }
        catch{
            print("Fetching Error!")
        }
        
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
