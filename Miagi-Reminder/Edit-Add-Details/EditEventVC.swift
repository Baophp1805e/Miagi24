//
//  EditEventVC.swift
//  Miagi-Reminder
//
//  Created by apple on 8/22/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import RealmSwift


class EditEventVC: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate , GMSMapViewDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var describeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeFromTF: UITextField!
    @IBOutlet weak var timeToTF: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    var indexPath: IndexPath!
 
    @IBOutlet weak var mapGoogles: GMSMapView!
    var eventEdit: Event?
    var realm: RealmEvent?
    var eventList:[Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapGoogles?.delegate = self
        mapGoogle()
        fetchData()
        titleTextField.delegate = self
        describeTextField.delegate = self
        cityTextField.delegate = self
    }
    @IBAction func doneButton(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let minDate:Date? = formatter.date(from: timeFromTF.text!)
        let maxDate:Date? = formatter.date(from: timeToTF.text!)
        switch minDate!.compare(maxDate!) {
            
        case .orderedAscending:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let commentVc = storyBoard.instantiateViewController(withIdentifier: "viewParrent") as! ViewController
            updateRealm()
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
    
    func updateRealm() {
        guard let title = titleTextField?.text,
            let describe = describeTextField?.text,
            let city = cityTextField?.text,
            let timeFrom = timeFromTF?.text,
            let timeTo = timeToTF?.text
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
    
    @IBAction func cancelButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let commentVc = storyBoard.instantiateViewController(withIdentifier: "viewParrent") as! ViewController
        self.navigationController?.pushViewController(commentVc, animated: true)
    }
    
    func mapGoogle()  {
        let camera = GMSCameraPosition.camera(withLatitude: 21.016431, longitude: 105.795290, zoom: 15.0)
        mapGoogles?.camera = camera
        mapGoogles?.delegate = self
        mapGoogles?.isMyLocationEnabled = true
        mapGoogles?.settings.myLocationButton = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func fetchData() {
        titleTextField?.text = eventEdit?.title
        describeTextField?.text = eventEdit?.describe
        cityTextField?.text = eventEdit?.city
        timeFromTF?.text = eventEdit?.timeFrom
        timeToTF?.text = eventEdit?.timeTo
    }
    
}
