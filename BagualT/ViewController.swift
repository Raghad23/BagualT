//
//  ViewController.swift
//  BagualT
//
//  Created by Developments on 07/10/2020.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
    
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               // present an alert indicating location authorization required
               // and offer to take the user to Settings for the app via
               // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
               locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
           }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        print("present location : (newLocation.coordinate.latitude), (newLocation.coordinate.longitude)")
        var previousLocation : CLLocation!

        if (previousLocation as CLLocation?) != nil{
            //case if previous location exists
            if previousLocation.distance(from: newLocation) > 1 {
                addAnnotationsOnMap(locationToPoint: newLocation)
                previousLocation = newLocation
            }
        }else{
            //in case previous location doesn't exist
            addAnnotationsOnMap(locationToPoint: newLocation)
            previousLocation = newLocation
        }
        
        if let oldLocationNew = oldLocation as CLLocation?{
             let oldCoordinates = oldLocationNew.coordinate
             let newCoordinates = newLocation.coordinate
             var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
             mapView.addOverlay(polyline)
            
         }
    }
    private func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            var pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.red
            pr.lineWidth = 5
            return pr
        }
        return nil

    }
    func addAnnotationsOnMap(locationToPoint : CLLocation){

        var annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        var geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark], placemarks.count > 0 {
                var placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary;
                annotation.title = addressDictionary!["Name"] as? String
                self.mapView.addAnnotation(annotation)
            }
        })
    }
}

