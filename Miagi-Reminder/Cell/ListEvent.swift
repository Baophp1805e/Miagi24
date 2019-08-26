//
//  ListEvent.swift
//  Miagi-Reminder
//
//  Created by apple on 8/14/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

class ListEvent: UITableViewCell {
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var indexPath: IndexPath!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var titleEventLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func bindData(event: Event) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let minDate:Date? = formatter.date(from: event.timeFrom!)
        let maxDate:Date? = formatter.date(from: event.timeTo!)
//        print(" DateCell : \(minDate!)")
        formatter.dateFormat = "HH:mm"
        let strDateMin = formatter.string(from: minDate!)
        let strDateMax = formatter.string(from: maxDate!)
        startTimeLabel.text = strDateMin
        endTimeLabel.text = strDateMax
        titleEventLabel.text = event.title
        describeLabel.text = event.describe
        cityLabel.text = event.city
    
    }

}

