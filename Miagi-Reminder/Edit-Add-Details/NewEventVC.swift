//
//  NewEventClassViewController.swift
//  Miagi-Reminder
//
//  Created by apple on 8/12/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import RealmSwift
import UserNotifications

class NewEventVC: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate , GMSMapViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var googleMaps: GMSMapView?
    var locationManager = CLLocationManager()
    @IBOutlet weak var timetoTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var describeTextField: UITextField!
    @IBOutlet weak var timefromTextField: UITextField!
    var parrentVC: ViewController!
    var eventList:[Event] = []
    var strCityMaps: String?
    @IBOutlet weak var cityLabel: UILabel!
    private var datePicker: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    var addEvent: Event!
    
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        handlePicker()
        self.title = "New Event"
        titleTextField?.delegate = self
        describeTextField?.delegate = self
        mapGoogle()
        showDatePicker()
        googleMaps?.delegate = self
        currentTime()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        nowSwitch1(switchz: switch1)
        tenSwitch2(switchs: switch2)
    }
    
    @objc func nowSwitch1(switchz: UISwitch) {
        let defaults = UserDefaults.standard
        if switchz.isOn {
            print("On")
            defaults.set(true, forKey: "SwitchState")
            NotificationManager.shared.scheduleNotification(title: (titleTextField?.text)!, body: (timefromTextField?.text)!, time: datePicker.date)
            //            scheduleNotification()
            UserDefaults.standard.synchronize()
        } else {
            print("Off")
            defaults.set(false, forKey: "SwitchState")
            NotificationManager.shared.center.removePendingNotificationRequests(withIdentifiers: ["LocalNotification"])
            UserDefaults.standard.synchronize()
        }
    }
    
    func tenSwitch2(switchs: UISwitch) {
        let defaults = UserDefaults.standard
        
        if switch2.isOn {
            print("On")
            defaults.set(true, forKey: "SwitchStates")
            NotificationManager.shared.scheduleNotifications(title: (titleTextField?.text)!, body: (timefromTextField?.text)!, time: datePicker.date)
            //            scheduleNotifications()
        } else {
            print("Off")
            defaults.set(false, forKey: "SwitchStates")
            NotificationManager.shared.center.removePendingNotificationRequests(withIdentifiers: ["LocalNotifications"])
        }
        
    }
    
    @IBAction func switch1Button(_ sender: Any) {
        nowSwitch1(switchz: switch1)
    }
    
    @IBAction func switch2Button(_ sender: Any) {
        tenSwitch2(switchs: switch2)
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker = UIDatePicker()
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        timefromTextField.inputAccessoryView = toolbar
        timetoTextField.inputAccessoryView = toolbar
        timefromTextField.inputView = datePicker
        timetoTextField.inputView = datePicker
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func currentTime(){
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        timefromTextField.text = myStringafd
        timetoTextField.text = myStringafd
    }
    
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = formatter.string(from: datePicker.date)
        if timefromTextField.isFirstResponder {
            timefromTextField.text = strDate
        } else {
            timetoTextField.text = strDate
        }
        self.view.endEditing(true)
    }
    
    func mapGoogle()  {
        let camera = GMSCameraPosition.camera(withLatitude: 21.016431, longitude: 105.795290, zoom: 15.0)
        googleMaps?.camera = camera
        googleMaps?.delegate = self
        googleMaps?.isMyLocationEnabled = true
        googleMaps?.settings.myLocationButton = true
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let commentVc = storyBoard.instantiateViewController(withIdentifier: "mapVC") as! MapsVC
        commentVc.delegate = self
        self.navigationController?.pushViewController(commentVc, animated: true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing( true )
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let minDate:Date? = formatter.date(from: timefromTextField.text!)
        let maxDate:Date? = formatter.date(from: timetoTextField.text!)
        
        switch minDate!.compare(maxDate!) {
            
        case .orderedAscending:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let commentVc = storyBoard.instantiateViewController(withIdentifier: "viewParrent") as! ViewController
            realmAdd()
            self.navigationController?.pushViewController(commentVc, animated: true)
            print("Date A is earlier than date B")
        case .orderedSame:
            errorLabel.text = "Wrong Time, Try Again!!!"
            errorLabel.textColor = UIColor.red
            print("Date A is later than date B")
        case .orderedDescending:
            errorLabel.text = "Wrong Time, Try Again!!!"
            errorLabel.textColor = UIColor.red
            print("The two dates are the same")
        }
    }
    
    func realmAdd() {
        guard let title = titleTextField?.text,
            let describe = describeTextField?.text,
            let city = cityLabel?.text,
            let timeFrom = timefromTextField?.text,
            let timeTo = timetoTextField?.text
            else { return }
        let idEvent = "idEvent"
        let currentId = UserDefaults.standard.value(forKey: idEvent) as? Int ?? 0
        let realm = try! Realm()
        realm.beginWrite()
        
        let event = RealmEvent()
        event.id = currentId
        event.title = title
        event.describe = describe
        event.city = city
        event.timeFrom = timeFrom
        event.timeTo = timeTo
        realm.add(event)
        UserDefaults.standard.set(currentId + 1, forKey: idEvent)
        try? realm.commitWrite()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewEventVC: backNewEvent {
    func passData(text: String) {
        cityLabel.text = text
    }
    
    
}

extension NewEventVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}
