//
//  ViewController.swift
//  EcoTracker
//
//  Created by Oleka on 23/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var leafButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hi_View: UIImageView!
    
    @IBOutlet weak var bg_View: UIImageView!

    var myTrackTypes : [MyTypes] = []
    var myTracker : [Tracker] = []
    
    func getPoints(dt: NSDate) -> String {
        
        var points: String = "0"
        
        //Select Value sum on date dt
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
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
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            myTrackTypes = try _context.fetch(MyTypes.fetchRequest())
            
            let startDate = Calendar.current.startOfDay(for: NSDate() as Date)
            
            let request = NSFetchRequest<Tracker>(entityName: "Tracker")
            request.predicate = NSPredicate(format: "dt>=%@ and dt<=%@",startDate as CVarArg,NSDate() as CVarArg)
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
        
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isNewUser() {
            self.hi_View.isHidden = false
            self.bg_View.isHidden = false
        }
        else {
            self.hi_View.isHidden = true
            self.bg_View.isHidden = true
            dateLabel.text = "Сегодня \(getDate(dd: NSDate()))"
            getDataTypes()
            tableView.reloadData()
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
        cell.typeImage.image = UIImage.init(named: "\(log.name!).png")
        cell.typeName = log.name!
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
        return 60
    }
    
    
    
}

