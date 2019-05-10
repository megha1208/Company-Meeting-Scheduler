//
//  ViewController.swift
//  CompanyMeetingScheduler
//
//  Created by Megha Johari on 5/8/19.
//  Copyright © 2019 Megha Johari. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var meetingArray = [Meeting]() {
        didSet {
            sortedArray = meetingArray.sorted(by: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.locale = Locale.current
                let startDate1 = dateFormatter.date(from: $0.startTime)
                let startDate2 = dateFormatter.date(from: $1.startTime)
                if startDate1?.compare(startDate2!) == .orderedAscending {
                    return true
                }
                else {
                    return false
                }

            })
        }
    }
    var sortedArray = [Meeting]()
    var cacheURLString = ""
    var currentDate = Date()
    var firstTimeCounter = 0
    var currentDateString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: currentDate)
        fetchAllMeetingsForDate(date: result)
        currentDateString = result
        self.navigationItem.title = currentDateString
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        self.edgesForExtendedLayout = UIRectEdge.top
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func previousSchedule(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        var yesterday = Date()
        var weekday = 0
        
        // Skipping Weekends
        repeat {
            yesterday = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            currentDate = yesterday
            weekday = Calendar.current.component(.weekday, from: yesterday)
        } while weekday == 1 || weekday == 7
        
        let prevDateString = formatter.string(from: currentDate)
        fetchAllMeetingsForDate(date: prevDateString)
        currentDateString = prevDateString
        self.navigationItem.title = currentDateString
    }
    
    @IBAction func nextSchedule(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        var tomorrow = Date()
        var weekday = 0
        
        // Skipping Weekends
        repeat {
            tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            currentDate = tomorrow
            weekday = Calendar.current.component(.weekday, from: tomorrow)
        } while weekday == 1 || weekday == 7
        
        let nextDateString = formatter.string(from: currentDate)
        fetchAllMeetingsForDate(date: nextDateString)
        currentDateString = nextDateString
        self.navigationItem.title = currentDateString
    }
    
    
    func fetchAllMeetingsForDate(date: String) {
        let urlString = "http://fathomless-shelf-5846.herokuapp.com/api/schedule?date=" + date
        let defaults = UserDefaults.standard
        
        //Accessing data from user Defaults
        if let keyUrl = defaults.string(forKey: defaultsKeys.keyURLString) {
            if keyUrl == urlString {
                guard let meetingData = defaults.object(forKey: defaultsKeys.keyMeetingArray) as? Data else {
                    return
                }
                self.meetingArray = (NSKeyedUnarchiver.unarchiveObject(with: meetingData as Data) as? [Meeting])!
                self.tableView.reloadData()
                return
            }
        }
        
        //Setting the data to User Deafaults
        if firstTimeCounter != 0 {
            let meetingData = NSKeyedArchiver.archivedData(withRootObject: self.meetingArray)
            defaults.set(meetingData, forKey: defaultsKeys.keyMeetingArray)
            defaults.set(cacheURLString, forKey: defaultsKeys.keyURLString)
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                print("Error while fetching Meeting data")
                return
            }
            
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                    print("Nil data received from URL")
                    return
            }
            var scheduleArray = [Meeting]()
            for meetingData in json! {
                let meetingItem = Meeting(dictionary: meetingData)
                scheduleArray.append(meetingItem!)
            }
            self.meetingArray = scheduleArray
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                if self.firstTimeCounter == 0 {
                    let meetingData = NSKeyedArchiver.archivedData(withRootObject: self.meetingArray)
                    defaults.set(meetingData, forKey: defaultsKeys.keyMeetingArray)
                    defaults.set(urlString, forKey: defaultsKeys.keyURLString)
                    self.firstTimeCounter += 1
                }
            }
            
        })
        task.resume()
        cacheURLString = urlString
        
        
    }
    
    //MARK: - TableView Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sortedArray.count == 0) ? 1 : sortedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath as IndexPath) as! MeetingViewCell
        guard sortedArray.count == 0 else {
            
            let dateAsString = sortedArray[indexPath.row].startTime
            let endDateString = sortedArray[indexPath.row].endTime
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            let date = dateFormatter.date(from: dateAsString)
            let endTimeValue = dateFormatter.date(from: endDateString)
            
            dateFormatter.dateFormat = "hh:mm a"
            let startTime12 = dateFormatter.string(from: date!)
            let endTime12 = dateFormatter.string(from: endTimeValue!)
            
            cell.startTimeLabel.text = startTime12
            cell.endTimeLabel.text = endTime12
            cell.meetingDescription.text = sortedArray[indexPath.row].meetingDesc
            
            var participantString = ""
            for participant in sortedArray[indexPath.row].participants {
                    participantString = participantString + participant + ", "
            }
    
            let arrayString = participantString.dropLast(2)
            cell.participants.text = String(arrayString)
            return cell
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleMeeting" {
            let meetingViewController: MeetingViewController = (segue.destination as? MeetingViewController)!
            meetingViewController.scheduleData = self.sortedArray
            meetingViewController.meetingDateString = currentDateString
            meetingViewController.delegate = self
        }
    }
    
    func dismissMeetingViewController() {
        navigationController?.popViewController(animated: true)
    }

}


