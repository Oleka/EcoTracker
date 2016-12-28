//
//  ViewController.swift
//  EcoTracker
//
//  Created by Oleka on 23/12/16.
//  Copyright © 2016 Olga Blinova. All rights reserved.
//

import UIKit

class AddViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        typeField.delegate=self
        valueField.delegate=self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectedDate: NSDate? = nil
    
    func getDate (dd:NSDate) -> String {
        
        var dateString: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateString = dateFormatter.string(from: dd as Date)
        
        return dateString
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        dateField.text = getDate(dd: sender.date as NSDate)
        selectedDate = sender.date as NSDate?
    }
    
    @IBAction func selDate(_ textField: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.backgroundColor = .clear
        textField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        
    }

    @IBAction func add(_ sender: Any) {
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //Add into StatLog
        let log = Tracker(context: _context)
        log.dt = selectedDate
        var value_int :Int16 = 0
        value_int = Int16(valueField.text!)!
        log.value = value_int
        log.type  = typeField.text
        
        
        //Save data to CoreData
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}

