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
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewCalendar: CalendarView!
    var calendarCellView: CalendarCellView!
    var event: Event!
    var eventList:[Event] = []
    var realmEven: RealmEvent!
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Miagi Reminder"
        self.dateLabel.text = viewCalendar.time
        viewCalendar.parentView = self
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "eventCell")
        self.tableView.reloadData()
        fetchEvent()
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(RealmEvent.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    //MARK: Hanlde Calendar
    
    @IBAction func backButton(_ sender: Any) {
        viewCalendar.rewindOneMonth()
    }
    
    @IBAction func todayButton(_ sender: Any) {
        viewCalendar.currentToday()
    }
    
    @IBAction func nextButton(_ sender: Any) {
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
    
    
    @IBAction func addButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addEvent = storyBoard.instantiateViewController(withIdentifier: "addEvent") as! AddEventViewController
        self.navigationController?.pushViewController(addEvent, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
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
        let dateTimeFrom:Date! = formatter.date(from: data.timeFrom!)
        guard let timeFrom = dateTimeFrom else {
            return
        }
        print("min: \(timeFrom)")
        if currentDate > timeFrom {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let detailsEvent = storyBoard.instantiateViewController(withIdentifier: "addEvent") as! AddEventViewController
            detailsEvent.eventDetails = data
            self.navigationController?.pushViewController(detailsEvent, animated: true)
            print("Nho hon")
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let updateEvent = storyBoard.instantiateViewController(withIdentifier: "addEvent") as! AddEventViewController
            updateEvent.eventEdit = data
            self.navigationController?.pushViewController(updateEvent, animated: true)
            print("lon hon")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let data = eventList[indexPath.row]
            let realm = try! Realm()
            let idEvent = realm.objects(RealmEvent.self).filter{ $0.id == data.id! }
            try! realm.write() {
                self.realm.delete(idEvent)
                
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

