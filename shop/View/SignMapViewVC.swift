//
//  SignMapViewVC.swift
//  shop
//
//  Created by Admin on 04/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class SignMapViewVC: UIViewController {
    var signinVC : SigninVC! = nil
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var locatonLbl: UILabel!
    @IBOutlet weak var MapviewUV: GMSMapView!
    private let locationManager = CLLocationManager()
    var locationStr: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        MapviewUV.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func setBtn(_ sender: Any) {
        Defaults.save(locationStr, with: Defaults.LOCATION_KEY)
        Defaults.save(addressLbl.text!, with: Defaults.ADDRESS_KEY)
        self.dismiss(animated: true, completion: nil)
        signinVC.setvalue()
        
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.addressLbl.text = lines.joined(separator: "\n")
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

}
// MARK: - CLLocationManagerDelegate
extension SignMapViewVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        MapviewUV.isMyLocationEnabled = true
        MapviewUV.settings.myLocationButton = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        MapviewUV.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
    
}
extension SignMapViewVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        let lat = mapView.camera.target.latitude
        print(lat)
        
        let lon = mapView.camera.target.longitude
        print(lon)
        locatonLbl.text = "Latitude: "+"\(lat)" + "\n" + "Longitude: " + "\(lon)"
        locationStr = "\(lat)" + "," + "\(lon)"
    }
}

