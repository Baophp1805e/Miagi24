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

//enum UpdateDetails {
//    case eventDetails
//    case eventEdit
//    case addEvent
//}

class AddEventViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate , GMSMapViewDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var informLabel: UILabel!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var namecityLabel: UILabel!
    @IBOutlet weak var beforeinformLabel: UILabel!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var timeFromLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
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
//    var strCityMaps: String?
    @IBOutlet weak var cityLabel: UILabel!
    private var datePicker: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    var addEvent: Event!
    var eventDetails: Event!
    var eventEdit: Event!
    
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField?.delegate = self
        describeTextField?.delegate = self
        timefromTextField?.delegate = self
        timetoTextField?.delegate = self
        mapGoogle()
        showDatePicker()
        googleMaps?.delegate = self
        currentTime()
        updateDetails()
        self.setNotificationKeyboard()
        scrollView.delegate = self
        customTextField()
//        customLable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
    }
    
    @objc func nowSwitch1(switchz: UISwitch) {
        let defaults = UserDefaults.standard
        if switchz.isOn {
            print("On")
            defaults.set(true, forKey: "SwitchState")
            NotificationManager.shared.scheduleNotification(title: (titleTextField?.text)!, body: (timefromTextField?.text)!, time: datePicker.date)
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
    
    func currentTime(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let myString = formatter.string(from: Date()) // string purpose I add here
        let yourDate = formatter.date(from: myString)
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
        let map = storyBoard.instantiateViewController(withIdentifier: "mapVC") as! MapsViewController
        map.delegate = self
        self.navigationController?.pushViewController(map, animated: true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing( true )
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let minDate:Date? = formatter.date(from: timefromTextField.text!)
        let maxDate:Date? = formatter.date(from: timetoTextField.text!)
        
        switch minDate!.compare(maxDate!) {
        case .orderedAscending:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "viewParrent") as! ViewController
            if let event = eventEdit {
                realmUpdate()
            } else {
                realmAdd()
            }
            nowSwitch1(switchz: switch1)
            tenSwitch2(switchs: switch2)
            self.navigationController?.pushViewController(viewController, animated: true)
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
    
    func realmUpdate() {
        guard let title = titleTextField?.text,
            let describe = describeTextField?.text,
            let city = cityLabel?.text,
            let timeFrom = timefromTextField?.text,
            let timeTo = timetoTextField?.text
            else { return }
        let realm = try! Realm()
        realm.beginWrite()
        if let eventUpdate = realm.object(ofType: RealmEvent.self, forPrimaryKey: eventEdit!.id) {
            eventUpdate.title = title
            eventUpdate.describe = describe
            eventUpdate.city = city
            eventUpdate.timeFrom = timeFrom
            eventUpdate.timeTo = timeTo
            realm.add(eventUpdate, update: .modified)
        }
        try? realm.commitWrite()
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
    
    func updateDetails() {
        if let eventEdit = eventEdit {
            titleTextField?.text = eventEdit.title
            describeTextField?.text = eventEdit.describe
            timefromTextField?.text = eventEdit.timeFrom
            timetoTextField?.text = eventEdit.timeTo
            self.title = "Update Event"
        } else if let eventDetails = eventDetails {
            titleTextField?.text = eventDetails.title
            describeTextField?.text = eventDetails.describe
            cityLabel?.text  = eventDetails.city!
            timefromTextField?.text = eventDetails.timeFrom
            timetoTextField?.text = eventDetails.timeTo
            titleTextField?.isEnabled = false
            describeTextField?.isEnabled = false
            timefromTextField?.isEnabled = false
            timetoTextField?.isEnabled = false
            switch1.isEnabled = false
            switch2.isEnabled = false
            googleMaps?.isHidden = true
            saveBarButton.isEnabled = false
            saveBarButton.tintColor = UIColor.clear
            self.title = "Details Event"
        } else {
            saveBarButton.isEnabled = true
            self.title = "New Event"
        }
    }
    
    //MARK: Auto Adjust UIScrollView when keyboard is up
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    // Notification when keyboard show
    func setNotificationKeyboard ()  {
        // setup keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView
            .contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        
        return false
    }

    
    func customTextField() {
        titleTextField.customBorder(radius: 20)
        describeTextField.customBorder(radius: 20)
        timefromTextField.customBorder(radius: 20)
        timetoTextField.customBorder(radius: 20)
    }
    
}

extension AddEventViewController: MapsViewControllerDelegate {
    func backCityName(name: String) {
        cityLabel.text = name
    }
}

