//
//  SecondViewController.swift
//  BeerSalery
//
//  Created by Dani Lihardja on 2/20/18.
//  Copyright © 2018 Prince Hendrie. All rights reserved.
//

import UIKit


class SecondViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var salary: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var unpaidDay: UITextField!
    
    let monthPicker = UIDatePicker()
    
    var selectedDate:Date = Date()
    
    @IBOutlet weak var calculateBtn: UIButton!
    let greenColor = UIColor(red: 96/255, green: 186/255, blue: 157/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        salary.delegate = self
        date.delegate = self
        unpaidDay.delegate = self
        
        setDateMonth(selectedDate: selectedDate)
        
        unpaidDay.text = "0"
        
        // Add tap gesture recognizer to view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmisKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        calculateBtn.addTarget(self, action: #selector(calculateButtonPressed), for: .touchUpInside)
        calculateBtn.layer.cornerRadius = 5
        
        
        // month picker
        monthPicker.datePickerMode = .date
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePress))
        toolBar.setItems([doneButton], animated: false)
        
        date.inputAccessoryView = toolBar
        
        date.inputView = monthPicker
       
    }
    
    func setDateMonth(selectedDate: Date) {
        let dateCurrent = selectedDate
        let calendar = Calendar.current
        let year = calendar.component(.year, from: dateCurrent)
        let month = calendar.component(.month, from: dateCurrent)
        
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        dateFormater.timeStyle = .none
        dateFormater.dateFormat = "MMM yyyy"
        
        let workingDays = countWorkingDays(start: getFirstDateinMonth(month:month, year:year, dateCurrent: dateCurrent) as NSDate, totalDay: getCountDaysinMonth(calendar: calendar, month: month, year: year, dateCurrent: dateCurrent))
        
        date.text = "\(dateFormater.string(from: selectedDate)) (total \(workingDays) working days in \(dateFormater.string(from: selectedDate)))"
    }
    
    @objc func donePress(){
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        dateFormater.timeStyle = .none
        dateFormater.dateFormat = "MMM yyyy"
        
        selectedDate = monthPicker.date
        setDateMonth(selectedDate: selectedDate)
        
        self.view.endEditing(true)
    }
    
    @objc func dissmisKeyboard() {
        _ = salary.resignFirstResponder()
        _ = date.resignFirstResponder()
        _ = unpaidDay.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if salary == textField {
            // Uses the number format corresponding to your Locale
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            //formatter.locale = Locale.current
            formatter.maximumFractionDigits = 0
            
            
            // Uses the grouping separator corresponding to your Locale
            // e.g. "," in the US, a space in France, and so on
            if let groupingSeparator = formatter.groupingSeparator {
                
                if string == groupingSeparator {
                    return true
                }
                
                
                if let textWithoutGroupingSeparator = textField.text?.replacingOccurrences(of: groupingSeparator, with: "") {
                    var totalTextWithoutGroupingSeparators = textWithoutGroupingSeparator + string
                    if string == "" { // pressed Backspace key
                        totalTextWithoutGroupingSeparators.removeLast()
                    }
                    if let numberWithoutGroupingSeparator = formatter.number(from: totalTextWithoutGroupingSeparators),
                        let formattedText = formatter.string(from: numberWithoutGroupingSeparator) {
                        
                        textField.text = formattedText
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    
    func alert(message: String, title: String = "", style: AlertStyle) {
        _ = SweetAlert().showAlert(title, subTitle: message, style: style, buttonTitle: "OK", buttonColor: greenColor, action: nil)
        
    }
    
    func validasi(salery: String, unpaidDay: String, workingDays: Int) -> String {
        var error: String = ""
        
        let unpaidDayInt = Int(unpaidDay)!
        let workingDaysInt = workingDays
        
        if (salery.count) == 0 {
            error = "Salary is required!"
        }else if (unpaidDay.count) == 0 {
            error = "Unpaid day in a month is required!"
        }else if  unpaidDayInt > workingDaysInt {
            error = "Your unpaid day can not more than your working day in a mount(monday to friday of the month.)!"
        }
        
        return error
    }
    
    @objc func calculateButtonPressed() {
        
        dissmisKeyboard()
        let salery = self.salary.text!
        let newSalery = salery.replacingOccurrences(of: ".", with: "")
        let latestSalery = newSalery.replacingOccurrences(of: ",", with: "")
        
        let unpaidDay = self.unpaidDay.text!
        let dateCurrent = selectedDate
        let calendar = Calendar.current
        let year = calendar.component(.year, from: dateCurrent)
        let month = calendar.component(.month, from: dateCurrent)
        
        let workingDays = countWorkingDays(start: getFirstDateinMonth(month:month, year:year, dateCurrent: dateCurrent) as NSDate, totalDay: getCountDaysinMonth(calendar: calendar, month: month, year: year, dateCurrent: dateCurrent))
        
        // validasi login
        let error: String = validasi(salery: latestSalery, unpaidDay: unpaidDay, workingDays: workingDays)
        if(error.count > 0){
            alert(message: error, title: "Warning", style: AlertStyle.warning)
        }else{
            
            
            let salery:Int? = Int(latestSalery)
            let unpaidDay:Int? = Int(unpaidDay)
            
            let totalworkingDays = (workingDays - unpaidDay!)
            let totalworkingDaysSaleryMonth = (salery! * totalworkingDays)/workingDays
            
        
            alert(message: "$SG \(self.formatNumber(amount: NSNumber(value: round(Double(totalworkingDaysSaleryMonth)))))", title: "Your Salery this Month", style: AlertStyle.success)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func formatNumber(amount:NSNumber)-> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        return numberFormatter.string(from: amount)!
    }

    func getCountDaysinMonth(calendar: Calendar, month:Int, year:Int, dateCurrent: Date)->Int{
        let dateComponents = DateComponents(year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    func getFirstDateinMonth(month:Int, year:Int, dateCurrent: Date)->Date{
        
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = NSTimeZone(abbreviation: "GMT+0:00")! as TimeZone
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateCurrent)
        
        
        components.day = 1
        components.month = month
        components.year = year
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let dateFirst = gregorian.date(from: components)!
        return dateFirst
    }
    
    func countWorkingDays(start: NSDate, totalDay: Int) -> Int {
        
        var workingDays = 0
        var date = start
        
        for _ in 1 ... totalDay {
            if !date.isDateWeekend {
                workingDays +=  1
            }
            date = date.tomorrow
        }
        
        return workingDays
    }
    
    func countWeekendDays(start: NSDate, totalDay: Int) -> Int {
        
        var weekendDays = 0
        var date = start
        
        for _ in 1 ... totalDay {
            
            if date.isDateWeekend {
                weekendDays +=  1
            }
            date = date.tomorrow
        }
        
        return weekendDays
    }

}



extension NSDate: Comparable { }

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}

struct Cal {
    static let iso8601 = NSCalendar(identifier: NSCalendar.Identifier.ISO8601)!
}
extension NSDate {
    var isDateWeekend: Bool {
        return Cal.iso8601.isDateInWeekend(self as Date)
    }
    var tomorrow: NSDate {
        return Cal.iso8601.date(byAdding: .day, value: 1, to: self as Date, options: .matchNextTime)! as NSDate
    }
}
