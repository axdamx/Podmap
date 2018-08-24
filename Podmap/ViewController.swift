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
    @IBOutlet weak var freshChatImage: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var zoomMapBtn: UIButton! {
        didSet {
            
            zoomMapBtn.addTarget(self, action: #selector(didTapZoomBtn(_:)), for: .touchUpInside)

        }
    }
    
    private let locationManager = CLLocationManager()
    var zoom: Float = 15
    let parseJson = ParseJson()
    var place = [PodObject]()
    var polygonPath = GMSPolyline();
    var locationMarker: GMSMarker!


    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        //locationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        //locationMarker.map = mapView
        
        parseJson.getDetails { (place) in
            self.place = place!
            var data = [String]()
            var placeData = [String]()
            
            for i in self.place {
                data.append(i.geojson)
                placeData.append(i.pln_area_n)
                //print(placeData)
            }

            print(placeData)
            //print(data)
        }
    
        
//        createPolygon()
    }

    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.locationTextLabel.text = lines.joined(separator: "\n")
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func didTapZoomBtn (_ sender : Any) {
        
        zoom = zoom + 1
        self.mapView.animate(toZoom: zoom)
        
    }
    
//    func createPolygon(){
//
//        let path = GMSMutablePath()
//        for coordinate in coordinates{
//            path.add(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
//        }
//        path.add(CLLocationCoordinate2D(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude))
//
//        polygonPath = GMSPolyline(path: path)
//        polygonPath.strokeColor = UIColor.red
//        polygonPath.strokeWidth = 2.0
//        polygonPath.map = mapView
//    }

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
    
//    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//
//        let marker = GMSMarker(position: coordinate)
//        marker.title = "Found You!"
//        marker.map = mapView
//
//        print("long pressed at \(coordinate)")
//
//    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        mapView.clear() // clearing Pin before adding new
        let marker = GMSMarker(position: coordinate)
        marker.title = "Found You!"
        marker.map = mapView
    }
    
    
}

