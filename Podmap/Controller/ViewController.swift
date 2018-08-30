//
//  ViewController.swift
//  Podmap
//
//  Created by Mohd Adam on 23/08/2018.
//  Copyright © 2018 Mohd Adam. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet weak var locationTextLabel: UILabel!
    @IBOutlet weak var locationLatLabel: UILabel!
    @IBOutlet weak var locationLongLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var freshChatBtn: UIButton! {
        didSet {
            freshChatBtn.addTarget(self, action: #selector(freshChatBtnTapped(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var zoomMapBtn: UIButton! {
        didSet {
            zoomMapBtn.addTarget(self, action: #selector(didTapZoomBtn(_:)), for: .touchUpInside)
        }
    }
    
    private let locationManager = CLLocationManager()
    var zoom: Float = 15
    var polygonPath = GMSPolyline()
    var locationMarker: GMSMarker!
    var coordinateArray: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLongLabel.text = ""
        locationLatLabel.text = ""
        locationTextLabel.text = ""
        
        mapView.delegate = self
        chatUserObject() // FreshChat settings
        parseJsonData() // Succesfully parse the whole Json data in, but couldn't get the coordinates's value. Thus couldn't parse in the coordinates to create the polygon :(
        freshChatNotification() // FreshChat settings with notifications
        mapLocationManager() // Location Manager delegate
        
    }
    
    @objc func didTapZoomBtn (_ sender : Any) {
        
        zoom = zoom + 1
        cameraMoveToLocation(toLocation: coordinateArray.last)
    }
    
    @objc func freshChatBtnTapped (_ sender: Any) {
        
        Freshchat.sharedInstance().showConversations(self)
    }
    
    func freshChatNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification(notification:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
    }
    
    func mapLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func parseJsonData() {
        
        let jsonUrlString = "https://developers.onemap.sg/privateapi/popapi/getAllPlanningarea?token=eyJ0eXAi"
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let parseJsonData = try JSONDecoder().decode(PodObject.self, from: data)
                for data in parseJsonData {
                    
                    //print(data.plnAreaN)
                    //print(data.geojson)
                }
                
            } catch let Jsonerror {
                print("error \(Jsonerror)")
            }
            
            }.resume()
    }
    
    func chatUserObject()  {
        
        let user = FreshchatUser.sharedInstance();
        let unixTimestamp = 15349621
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm dd-MM-yyyy" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        user?.firstName = "Mohd Adam";
        user?.lastName = "Muhd Sani Ting";
        user?.email = "testdev_MohdAdam@telepod.com";
        user?.phoneCountryCode="65";
        user?.phoneNumber = "97778888";
        
        Freshchat.sharedInstance().setUser(user)
        Freshchat.sharedInstance().setUserPropertyforKey("userId", withValue: "abcdef123456")
        Freshchat.sharedInstance().setUserPropertyforKey("OS", withValue: "IOS")
        Freshchat.sharedInstance().setUserPropertyforKey("registrationDate", withValue: strDate)
        Freshchat.sharedInstance().setUserPropertyforKey("customerType", withValue: "Premium")
        Freshchat.sharedInstance().setUserPropertyforKey("city", withValue: "San Bruno")
        Freshchat.sharedInstance().setUserPropertyforKey("loggedIn", withValue: "true")
        Freshchat.sharedInstance().setUserPropertyforKey("transactionCount", withValue: "3")
        
        Freshchat.sharedInstance().unreadCount { (count:Int) -> Void in
            print("Unread count (Async) :\(count)")
        }
        
    }
    
    @objc func methodOfReceivedNotification(notification: Notification ) {
        Freshchat.sharedInstance().unreadCount { (count:Int) -> Void in
            print("Unread count (Async) :\(count)")
        }
    }
    
    func createPolygon(){
        
        let path = GMSMutablePath()
        for coordinate in coordinateArray {
            path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        path.add(CLLocationCoordinate2D(latitude: coordinateArray[0].latitude, longitude: coordinateArray[0].longitude))
        
        polygonPath = GMSPolyline(path: path)
        polygonPath.strokeColor = UIColor.blue
        polygonPath.strokeWidth = 1.5
        polygonPath.map = mapView
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.locality else {
                return
            }
            self.locationTextLabel.text = lines
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.animate(to: GMSCameraPosition(target: toLocation!, zoom: 18, bearing: 0, viewingAngle: 0))
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        var latLong:CLLocationCoordinate2D
        
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        latLong = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.getAryCoordinates(latLong: latLong)
    }
    
    func getAryCoordinates(latLong: CLLocationCoordinate2D) {
        
        locationLatLabel.text = String(latLong.latitude)
        locationLongLabel.text = String(latLong.longitude)
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        locationLatLabel.text = "Lat: \(String(coordinate.latitude))"
        locationLongLabel.text = "Long: \(String(coordinate.longitude))"
        mapView.clear()
        
        let marker = GMSMarker(position: coordinate)
        reverseGeocodeCoordinate(coordinate)
        marker.title = "Found You!"
        marker.icon = UIImage(named: "icons8-marker")
        marker.map = mapView
        
        coordinateArray.append(coordinate)
        createPolygon()
        
    }
    
}

