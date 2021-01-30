//
//  File.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 29/1/21.
//

import Foundation
import UIKit
import MapKit

class MapController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    let regionMeters:Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        
        //Accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        
        //When the app is open
        case .authorizedWhenInUse:
            //Map code
            mapView.showsUserLocation = true // Show the blue dot
            
            // Zoom on the location
            if let location = locationManager.location {
                self.mapView.centerToLocation(location)
            }
            
            
            locationManager.startUpdatingLocation()
            
            break
        //The app is not allowed one time pop up
        case .denied:
            //Show alert with instruction on how to turn on permission
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //Show an alert letting them know what's up
            break
        //Even when the app is closed
        case .authorizedAlways:
            break
        default:
            print("Unkown location status")
        }
    }
    
    //Check if the loaction service is handled
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            //Set the location manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //Show some error message and turn them on
        }
    }
    
}


extension MapController : CLLocationManagerDelegate {
    
    //To track as you move
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Guard against not having location
        guard let location = locations.last else {return}
        //Where the map view center is, this is the users last known location
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //Find the regison based on the location
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)
    }
    
    //When the authrization is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
