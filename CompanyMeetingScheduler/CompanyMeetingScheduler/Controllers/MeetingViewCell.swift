//
//  MeetingViewCell.swift
//  CompanyMeetingScheduler
//
//  Created by Megha Johari on 5/10/19.
//  Copyright © 2019 Megha Johari. All rights reserved.
//

import UIKit

class MeetingViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var participants: UILabel!
    @IBOutlet weak var meetingDescription: UILabel!
    
}
