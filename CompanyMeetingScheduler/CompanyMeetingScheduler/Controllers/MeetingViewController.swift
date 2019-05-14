//
//  MeetingViewController.swift
//  CompanyMeetingScheduler
//
//  Created by Megha Johari on 5/9/19.
//  Copyright © 2019 Megha Johari. All rights reserved.
//

import UIKit

class MeetingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var meetingDate: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var meetingDescription: UITextField!
    @IBOutlet weak var startTimePickerView: UIPickerView!
    @IBOutlet weak var endTimePickerView: UIPickerView!
    
    var pickerData = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00"]
    var scheduleData = [Meeting]()
    var meetingDateString = ""
    weak var delegate: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigartionBar()
        configureTextFields()
        meetingDate.text = meetingDateString
        startTimePickerView.selectRow(4, inComponent: 0, animated: true)
        endTimePickerView.selectRow(4, inComponent: 0, animated: true)
    }
    
    @IBAction func submitMeeting(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale.current
        
        guard  let startTimeString = startTime.text,
               let endTimeString = endTime.text,
               let startValue = dateFormatter.date(from: startTimeString),
               let endValue = dateFormatter.date(from: endTimeString)
            else {
                createAlertView(alertTile: "Select Valid Time", alertMessage: "")
                return
        }
        
        if startValue.compare(endValue) == .orderedSame {
            createAlertView(alertTile: "Select Valid Time", alertMessage: "End Time cannot be same as Start Time")
            return
        }
        
        if startValue.compare(endValue) == .orderedDescending {
            createAlertView(alertTile: "Select Valid Time", alertMessage: "End Time cannot be less than Start Time")
            return
        }
        
        let remainder = endValue.timeIntervalSince(startValue).truncatingRemainder(dividingBy: 180)
        if remainder != 0  {
            createAlertView(alertTile: "Select Valid Time", alertMessage: "Meeting can be scheduled only for 30 minutes")
            return
        }
        
        guard meetingDescription.text != "" else {
            createAlertView(alertTile: "Please Enter Description", alertMessage: "")
            return
        }
        
        let availableTime = validateAvailableTime()
        
        //create extension and this method
        for meetingItem in scheduleData {
            let startArrayValue = dateFormatter.date(from: meetingItem.startTime)
            let endArrayValue = dateFormatter.date(from: meetingItem.endTime)
            if startArrayValue?.compare(startValue) != .orderedSame {
                if startArrayValue?.compare(startValue) == .orderedAscending {
                    if endArrayValue?.compare(endValue) == .orderedAscending && (endArrayValue?.compare(startValue) == .orderedAscending || endArrayValue?.compare(startValue) == .orderedSame) {
                    }
                    else {
                        createAlertView(alertTile: "Meeting already exists", alertMessage: "\(availableTime)")
                        return
                    }
                } else {
                    if endValue.compare(startArrayValue!) == .orderedAscending || endValue.compare(startArrayValue!) == .orderedSame {
                    }
                    else {
                        createAlertView(alertTile: "Meeting already exists", alertMessage: "\(availableTime)")
                        return
                    }
                }
            }
            else
            {
                createAlertView(alertTile: "Meeting already exists", alertMessage: "\(availableTime)")
                return
            }
        }
        let alert = UIAlertController(title: "Success", message: "Meeting Scheduled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction?) in
                self.delegate!.dismissMeetingViewController()
        }))
        self.present(alert, animated: true, completion: nil)
        
        return
    }
    
    func configureTextFields() {
        addDropDownIcon(to: meetingDate)
        addDropDownIcon(to: startTime)
        addDropDownIcon(to: endTime)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return pickerData.count
        } else {
            return pickerData.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            startTime.text = pickerData[row]
            pickerView.isHidden = true
        } else {
            endTime.text = pickerData[row]
            pickerView.isHidden = true
        }
        
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.placeholder == "Start Time" {
            startTimePickerView.isHidden = false
        }
        else if textField.placeholder == "End Time" {
            endTimePickerView.isHidden = false
        }
        return false
    }
}
