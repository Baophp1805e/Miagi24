//
//  MapsVC.swift
//  Miagi-Reminder
//
//  Created by apple on 8/19/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

protocol backNewEvent: class {
    func passData(text: String)
}

class MapsVC: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    // OUTLETS
    
    weak var delegate: backNewEvent?
    var newEvent: NewEventVC?
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var googleMapView: GMSMapView!
    var mapView: GMSMapView!
    // VARIABLES
    @IBOutlet weak var lblCurrentLocation: UILabel!
    @IBOutlet weak var centerView: UIView!
    var locationManager = CLLocationManager()
    var cirlce: GMSCircle!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locateWithLongitude(21.011840, andLatitude: 105.797182, andTitle: "Trung kinh")
        //        initGoogleMaps()
        let circleView = UIView()
        circleView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        view.addSubview(circleView)
        view.bringSubviewToFront(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: circleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let widthConstraint = NSLayoutConstraint(item: circleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let centerXConstraint = NSLayoutConstraint(item: circleView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: circleView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([heightConstraint, widthConstraint, centerXConstraint, centerYConstraint])
        
        view.updateConstraints()
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
            circleView.layer.cornerRadius = circleView.frame.width/2
            circleView.clipsToBounds = true
        })
        lblCurrentLocation.text = "Trung Kinh"
    }
  
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let camera = GMSCameraPosition.camera(withLatitude: lon, longitude: lat, zoom: 15.0)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.isMyLocationEnabled = true
            //        self.view = mapView
            self.googleMapView?.camera = camera
            self.googleMapView?.delegate = self
            //        self.googleMapsView?.isMyLocationEnabled = true
            self.googleMapView?.settings.myLocationButton = true
            self.cirlce = GMSCircle(position: camera.target, radius: 100000)
            self.cirlce.fillColor = UIColor.red.withAlphaComponent(0.5)
            self.cirlce.map = mapView
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("\(position.target.latitude) \(position.target.longitude)")
        cirlce.position = position.target
    }
    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.googleMapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapView?.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapView?.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
        
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapView?.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        print("Dia diem là: \(place)")
        lblCurrentLocation.text = String(describing: place.name)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @IBAction func btnSave(_ sender: Any) {
        guard let nameMaps = lblCurrentLocation.text else {
            return
        }
        delegate?.passData(text: nameMaps)
        self.navigationController?.popViewController(animated: true)
    }
  
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
}

