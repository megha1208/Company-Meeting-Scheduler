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
    
    var pickerData = ["09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]
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
            let alert = UIAlertController(title: "Select Valid Time", message: nil      , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
                return
        }
        
        if startValue.compare(endValue) == .orderedSame {
            let alert = UIAlertController(title: "Select Valid Time", message: "End Time cannot be same as Start Time", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if startValue.compare(endValue) == .orderedDescending {
            let alert = UIAlertController(title: "Select Valid Time", message: "End Time cannot be less than Start Time", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if endValue.timeIntervalSince(startValue) / 60 > 60 {
            let alert = UIAlertController(title: "Select Valid Time", message: "Meeting can be scheduled only for 60 minutes", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard meetingDescription.text != "" else {
            let alert = UIAlertController(title: "Please Enter Description", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var availableTime = ""
        for index in 0..<pickerData.count - 1 {
            
            let startTime = dateFormatter.date(from: pickerData[index])!
            let endTime = dateFormatter.date(from: pickerData[index+1])!
            guard availableTime == "" else { break }
            
            for item in scheduleData {
                let startArrayValue = dateFormatter.date(from: item.startTime)
                let endArrayValue = dateFormatter.date(from: item.endTime)
                if startArrayValue?.compare(startTime) != .orderedSame {
                        if startArrayValue?.compare(startTime) == .orderedAscending {
                            if endArrayValue?.compare(endTime) == .orderedAscending && (endArrayValue?.compare(startTime) == .orderedAscending || endArrayValue?.compare(startTime) == .orderedSame) {
                                availableTime = pickerData[index] + " - " + pickerData[index+1]
                                
                                break
                            }
                            else {
                                break
                            }
                        } else {
                            if endTime.compare(startArrayValue!) == .orderedAscending || endTime.compare(startArrayValue!) == .orderedSame {
                                availableTime = pickerData[index] + " - " + pickerData[index+1]
                                break
                            }
                            else {
                                break
                        }
                        
                    }
                } else {
                    break
                }
            }
        }
        if availableTime == "" {
            availableTime = "No slots available"
        }
        else {
            availableTime += " available"
        }
        
        for meetingItem in scheduleData {
            let startArrayValue = dateFormatter.date(from: meetingItem.startTime)
            let endArrayValue = dateFormatter.date(from: meetingItem.endTime)
            if startArrayValue?.compare(startValue) != .orderedSame {
                if startArrayValue?.compare(startValue) == .orderedAscending {
                    if endArrayValue?.compare(endValue) == .orderedAscending && (endArrayValue?.compare(startValue) == .orderedAscending || endArrayValue?.compare(startValue) == .orderedSame) {
                       
                    }
                    else {
                        let alert = UIAlertController(title: "Meeting already exists", message: "\(availableTime)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                } else {
                    if endValue.compare(startArrayValue!) == .orderedAscending || endValue.compare(startArrayValue!) == .orderedSame {
                       
                    }
                    else {
                        let alert = UIAlertController(title: "Meeting already exists", message: "\(availableTime)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "Meeting already exists", message: "\(availableTime)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    func setupNavigartionBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "SCHEDULE A MEETING"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func configureTextFields() {
        meetingDate.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: meetingDate.frame.width - 60, y: meetingDate.frame.origin.y + 5, width: 20, height: 20))
        let image = UIImage(named: "dropDownArrow")
        imageView.image = image
        meetingDate.rightView = imageView
        
        startTime.rightViewMode = UITextField.ViewMode.always
        let imageView1 = UIImageView(frame: CGRect(x: startTime.frame.width - 60, y: startTime.frame.origin.y + 5, width: 20, height: 20))
        let image1 = UIImage(named: "dropDownArrow")
        imageView1.image = image1
        startTime.rightView = imageView1
        
        endTime.rightViewMode = UITextField.ViewMode.always
        let imageView2 = UIImageView(frame: CGRect(x: endTime.frame.width - 60, y: endTime.frame.origin.y + 5, width: 20, height: 20))
        let image2 = UIImage(named: "dropDownArrow")
        imageView2.image = image2
        endTime.rightView = imageView2
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
        
        if pickerView.tag == 1 {
            return pickerData[row]
        } else {
            return pickerData[row]
        }
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
