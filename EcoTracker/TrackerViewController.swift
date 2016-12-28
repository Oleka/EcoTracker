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

class TrackerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var periodTypeControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var trackTypes : [Types] = []
    
    func getDataTypes(){
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            trackTypes = try _context.fetch(Types.fetchRequest())
        }
        catch{
            print("Fetching Error!")
        }
        
    }
    
    @IBAction func changePeriod(_ sender: Any) {
        
        //Define width of blocks by SegmentIndex
        if (periodTypeControl.selectedSegmentIndex == 0) {
            //Week
            blockWidth = 20
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as NSDate?
            endDate    = NSDate()
            print("week=\(beginDate)")
        }
        else if (periodTypeControl.selectedSegmentIndex == 1) {
            //Month
            blockWidth = 10
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .month], from: Date())) as NSDate?
            endDate    = NSDate()
            print("month=\(beginDate)")
        }
        else{
            //Year
            blockWidth = 2
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.year, .year], from: Date())) as NSDate?
            endDate    = NSDate()
            print("year=\(beginDate)")
        }
        
        loadTracker()
        
    }
    
    let beginX: Int = 80
    let beginY: Int = 128
    var blockWidth: Int = 0
    var searched : [Tracker] = []
    
    var beginDate:  NSDate? = nil
    var endDate:    NSDate? = nil
    
    
    func loadTracker(){
        
        //Define width of blocks by SegmentIndex
        if (self.periodTypeControl.selectedSegmentIndex == 0) {
            //Week
            blockWidth = 20
            beginDate  = Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) as NSDate?
            endDate    = NSDate()
        }
        else if (self.periodTypeControl.selectedSegmentIndex == 1) {
            //Month
            blockWidth = 10
            beginDate  = NSDate()
            endDate    = NSDate()
        }
        else{
            //Year
            blockWidth = 2
            beginDate  = NSDate()
            endDate    = NSDate()
        }
        
        //Get data from DB selected by periodTypeControl
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format:"dt>=%@ AND dt<=%@", beginDate!, endDate!)
            searched = try _context.fetch(request)
            
            var offsetX: Int = beginX
            let offsetY: Int = beginY
            
            for track in searched {
                
                //Define block color
                var blockColor: UIColor = .gray
                
                if track.value == 5 {
                    blockColor = .yellow
                }
                else if track.value == 10 {
                    blockColor = .green
                }
                else{
                    blockColor = .gray
                }
                
                //Load block
                let block = TrackerBlock(frame: CGRect(x: offsetX, y: offsetY, width: Int(blockWidth), height: 20))
                block.backgroundColor = blockColor
                
                view.addSubview(block)
                block.setNeedsDisplay()
                
                offsetX += blockWidth
                
            }
            
        } catch {
            print("There was an error fetching.")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load tracker
        loadTracker()
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
        let cell = UITableViewCell()
        
        let log = trackTypes[indexPath.row]
        let table_label = "\(log.full_name!)"
        cell.textLabel?.text = table_label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Delete stat row
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let log = trackTypes[indexPath.row]
            _context.delete(log)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //update data after deleting
            do{
                trackTypes = try _context.fetch(Types.fetchRequest())
            }
            catch{
                print("Fetching Error after deleting!")
            }
            tableView.reloadData()
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
