//
//  MeetingViewControllerExtension.swift
//  CompanyMeetingScheduler
//
//  Created by Megha Johari on 5/15/19.
//  Copyright © 2019 Megha Johari. All rights reserved.
//

import Foundation
import UIKit

extension MeetingViewController {
    
    func setupNavigartionBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "SCHEDULE A MEETING"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func validateAvailableTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale.current
        
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
        return availableTime
    }
    
    func createAlertView(alertTile: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTile, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDropDownIcon(to textField: UITextField) {
        textField.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: textField.frame.width - 60, y: textField.frame.origin.y + 5, width: 20, height: 20))
        let image = UIImage(named: "dropDownArrow")
        imageView.image = image
        textField.rightView = imageView
    }
}
