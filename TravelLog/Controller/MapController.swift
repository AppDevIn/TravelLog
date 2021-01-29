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
    
    func zoomOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        
        //When the app is open
        case .authorizedWhenInUse:
            //Map code
            mapView.showsUserLocation = true // Show the blue dot
            zoomOnUserLocation()
            if let coor = locationManager.location?.coordinate {
                fetchPlaces(coordinate: coor) { (places) in
                    print(places)
                }
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
    
    func fetchPlaces(coordinate coor:CLLocationCoordinate2D,completionHandler: @escaping (Place) -> Void) {
        
        let apiKey:String = "BziU0Uj8Q-hONi9AaTYikl8EsDT_bBdXE7MZt1dFQ8k"
        
        let url = URL(string: "https://places.ls.hereapi.com/places/v1/discover/explore?at=\(coor.latitude),\(coor.longitude)&cat=eat-drink&apiKey=\(apiKey)")!
        print(url)

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
            print("Error with fetching films: \(error)")
            return
          }
          
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(String(describing: response))")
            return
          }
            
            
            
            
          if let data = data  {
            
            

            do {

                let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                let items:[NSDictionary] = (jsonResult?["results"] as! NSDictionary)["items"] as! [NSDictionary]
                let next:String = (jsonResult?["results"] as! NSDictionary)["next"] as! String
                print(next)
                let result = Results(next: next, items: items)
                print(result.items[0].position[0])
//                completionHandler(welcome)
            } catch {
                print(error.localizedDescription)

            }
            
            
          }
        })
        task.resume()
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
