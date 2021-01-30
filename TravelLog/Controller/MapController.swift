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
    let regionMeters:Double = 1000
    
    let centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "location")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterOnUserLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        mapView.delegate = self
        
        
        //Button configure
        
        view.addSubview(centerMapButton)
        centerMapButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -94).isActive = true
        centerMapButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        centerMapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.layer.cornerRadius = 50/2
        centerMapButton.alpha = 1
        
    }
    
    @objc func handleCenterOnUserLocation () {
        if let location = locationManager.location {
            self.mapView.centerToLocation(location, regionRadius:1000 )
        }
    }
    func setupLocationManager() {
        locationManager.delegate = self
        
        //Accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func attractionPin() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Attractions"
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                return
            }
            
            for item in response.mapItems {
                let place = Places(title: item.placemark.name, subtitle: nil, coordinate: item.placemark.coordinate, mapItem: item)
                self.mapView.addAnnotation(place)
                
            }
        }
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
            
            //Pin al the attractions
            attractionPin()
            
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
        //        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
        //        mapView.setRegion(region, animated: true)
    }
    
    //When the authrization is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapController: MKMapViewDelegate {
    // 1
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Places else {
            return nil
        }
        // 3
        let identifier = "places"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let place = view.annotation as? Places else {
            return
          }

          let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
          ]
          place.mapItem.openInMaps(launchOptions: launchOptions)
    }
    
}


private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 50000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
