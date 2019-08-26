//
//  DetailsVC.swift
//  Miagi-Reminder
//
//  Created by apple on 8/22/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class DetailsVC: UIViewController {

    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeToTextField: UITextField!
    @IBOutlet weak var timeFromTextFiled: UITextField!
    @IBOutlet weak var describeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    var eventDetails: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "DetailsEvent"
        fetchData()
    }
    @IBAction func cancelButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let commentVc = storyBoard.instantiateViewController(withIdentifier: "viewParrent") as! ViewController
        self.navigationController?.pushViewController(commentVc, animated: true)
    }
    
    func fetchData() {
        titleTextField?.text = eventDetails?.title
        describeTextField?.text = eventDetails?.describe
        cityLabel?.text = eventDetails?.city
        timeFromTextFiled?.text = eventDetails?.timeFrom
        timeToTextField?.text = eventDetails?.timeTo
        
    }
    
    

}
