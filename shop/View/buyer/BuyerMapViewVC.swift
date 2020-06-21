//
//  BuyerMapViewVC.swift
//  shop
//
//  Created by Admin on 04/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
import GoogleMaps
import GooglePlaces
class BuyerMapViewVC: UIViewController {
    var buyeroneshopVC : BuyerOneShopVC!
    var allshop = [Shop]()
    var spinnerView = JTMaterialSpinner()
    
    private let locationManager = CLLocationManager()
    @IBOutlet weak var MapViewUV: GMSMapView!
    @IBOutlet weak var LocationLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        MapViewUV.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setready()
    }
    
    func setready(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allshop = []
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "buyerallshop.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                let status_shop = value["status_shop"] as! String
                if status == "ok" {
                    if status_shop == "ok"{
                        let shops = value["allshop"] as? [[String: Any]]
                        for i in 0 ... (shops?.count)!-1 {
                            let shop_id = shops?[i]["id"] as! String
                            let shop_name = shops?[i]["shopname"] as! String
                            let shop_email = shops?[i]["shopemail"] as! String
                            let shop_mobile = shops?[i]["shopmobile"] as! String
                            let shop_address = shops?[i]["shopaddress"] as! String
                            let shop_location = shops?[i]["shoplocation"] as! String
                            let shop_image = shops?[i]["shopimg"] as! String
                            let shop_fav = shops?[i]["shopfav"] as! String
                            let marker = GMSMarker()
                            let position = shop_location.components(separatedBy: ",")
                            let latitude_pos = position[0]
                            let longitude_pos = position[1]
                            print(latitude_pos)
                            
                            if i == 0{
                                marker.position = CLLocationCoordinate2D(latitude: -33.86 , longitude: 151.20)
                            }else {
                                
                                marker.position = CLLocationCoordinate2D(latitude: -33.81, longitude: 151)
                            }
                            marker.title = shop_id
                            marker.map = self.MapViewUV
                            let shopcell = Shop(id: shop_id, name: shop_name, email: shop_email, mobile: shop_mobile, address: shop_address, location: shop_location, image: shop_image, fav: shop_fav)
                            self.allshop.append(shopcell)
                            
                        }
                        
                    }else{
                        Toast(text: "No shop data").show()
                    }
                    
                    self.spinnerView.endRefreshing()
                    
                    
                }else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "No shop data").show()
                }
            }
            else{
                Toast(text: "No internet").show()
            }
        }
        
//        for i in 1...2{
//            let marker = GMSMarker()
//            if(i == 1){
//                marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//                marker.title = "1"
//                marker.snippet = "adfadf"
////                marker.icon = UIImage(named: "fav-red")
//
//            }else{
//                marker.position = CLLocationCoordinate2D(latitude: -33.01, longitude: 151)
//                marker.title = "2"
//                marker.snippet = "Australia"
//            }
//            marker.map = MapViewUV
//        }
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.LocationLbl.text = lines.joined(separator: "\n")
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
// MARK: - CLLocationManagerDelegate
extension BuyerMapViewVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        MapViewUV.isMyLocationEnabled = true
        MapViewUV.settings.myLocationButton = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        MapViewUV.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
    
}
extension BuyerMapViewVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let i :Int = Int(marker.title as! String)!
        Defaults.save(allshop[i-1].id, with: Defaults.SHOPID_KEY)
        Defaults.save(allshop[i-1].name, with: Defaults.SHOPNAME_KEY)
        Defaults.save(allshop[i-1].email, with: Defaults.SHOPEMAIL_KEY)
        Defaults.save(allshop[i-1].mobile, with: Defaults.SHOPMOBILE_KEY)
        Defaults.save(allshop[i-1].address, with: Defaults.SHOPADDRESS_KEY)
        Defaults.save(allshop[i-1].location, with: Defaults.SHOPLOCATION_KEY)
        Defaults.save(allshop[i-1].image, with: Defaults.SHOPIMG_KEY)
        Defaults.save(allshop[i-1].fav, with: Defaults.SHOPFAV_KEY)
        self.buyeroneshopVC = self.storyboard?.instantiateViewController(withIdentifier: "buyeroneshopVC") as? BuyerOneShopVC
        self.present(self.buyeroneshopVC, animated: true, completion: nil)
       
        return false
    }
    
//
    
}

