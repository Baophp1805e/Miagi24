//
//  ViewController.swift
//  Miagi-Reminder
//
//  Created by apple on 8/12/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import NVActivityIndicatorView

class ViewController: UIViewController, UIGestureRecognizerDelegate, NVActivityIndicatorViewable{
    
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var viewCalendar: CalendarView!
    var calendarCellView: CalendarCellView!
    var newEvent: NewEventVC!
    var event: Event!
    var eventList:[Event] = []
    var realmEven: RealmEvent!
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var switchState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Miagi Reminder"
        self.selectedDateLabel.text = viewCalendar.time
        viewCalendar.parentView = self
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = UINib(nibName: "ListEvent", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "eventCell")
        self.tableView.reloadData()
        fetchEvent()
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(RealmEvent.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    //MARK: Hanlde Calendar
    
    @IBAction func btnBack(_ sender: Any) {
        viewCalendar.rewindOneMonth()
    }
    
    @IBAction func btnToday(_ sender: Any) {
        viewCalendar.currentToday()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        viewCalendar.advanceOneMonth()
    }
    
    //MARK: Realm
    
    func fetchEvent(){
        let realm = try! Realm()
        let getEvents = realm.objects(RealmEvent.self)
        for getEvent in getEvents {
            self.eventList.append(getEvent.toModel())
        }
        self.tableView.reloadData()
        print(getEvents)
    }
    
    
    @IBAction func btnAdd(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let commentVc = storyBoard.instantiateViewController(withIdentifier: "newEvent") as? NewEventVC
        self.navigationController?.pushViewController(commentVc!, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! ListEvent
        let data = eventList[indexPath.row]
        cell.bindData(event: data)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = eventList[indexPath.row]
        let currentDate = Date()
        print("Date: \(currentDate)")
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let minDate:Date! = formatter.date(from: data.timeFrom!)
        guard let min = minDate else {
            return
        }
        print("min: \(min)")
        if currentDate > min {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let detailsEvent = storyBoard.instantiateViewController(withIdentifier: "newEvent") as! NewEventVC
            detailsEvent.eventDetails = data
            self.navigationController?.pushViewController(detailsEvent, animated: true)
            print("Nho hon")
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let editVc = storyBoard.instantiateViewController(withIdentifier: "newEvent") as! NewEventVC
            editVc.eventEdit = data
            self.navigationController?.pushViewController(editVc, animated: true)
            print("lon hon")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let data = eventList[indexPath.row]
            let realm = try! Realm()
            let event = realm.objects(RealmEvent.self).filter{ $0.id == data.id! }
            try! realm.write() {
                self.realm.delete(event)
                
            }
            self.eventList.remove(at: indexPath.row)
            
        }
        DispatchQueue.main.async{
            self.tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableView.RowAnimation.top)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
}

