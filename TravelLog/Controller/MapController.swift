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
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        //Ignoring User
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
    }
    
    func zoomOnUserLocation() {
        if let locations = locationManager.location?.coordinate {
            let location = CLLocationCoordinate2D(latitude: 56.2639, longitude: 9.5018)
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func addPin(coordinate coor: CLLocationCoordinate2D, _ title:String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coor
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        
        //When the app is open
        case .authorizedWhenInUse:
            //Map code
            mapView.showsUserLocation = true // Show the blue dot
                        zoomOnUserLocation()
            if let coor = locationManager.location?.coordinate {
                
                
            }
            
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "Attractions"
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                for item in response.mapItems {
                    self.addPin(coordinate: item.placemark.coordinate, item.name!)
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
    
    func placesToPin(coordinate coor:CLLocationCoordinate2D, url Url:String?){
        fetchPlaces(coordinate: coor, url: Url) { (result) in
            
            for place in result.items {
                self.addPin(coordinate: CLLocationCoordinate2D(latitude: place.position[0], longitude:place.position[1]), place.title)
            }
            
            
            
            if let url = result.next {
                self.placesToPin(coordinate: coor, url:url)
            }
        }
    }
    
    func fetchPlaces(coordinate coor:CLLocationCoordinate2D, url Url:String?,completionHandler: @escaping (Results) -> Void) {
        
        var url:URL
        let apiKey:String = "BziU0Uj8Q-hONi9AaTYikl8EsDT_bBdXE7MZt1dFQ8k"
        
        if let link = Url {
            url = URL(string: link)!
        } else {
            
            
            url = URL(string: "https://places.ls.hereapi.com/places/v1/discover/explore?at=\(coor.latitude),\(coor.longitude)&cat=sights-museums&apiKey=\(apiKey)")!
        }
        
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
                    
                    var items:[NSDictionary]
                    var apiResult:NSDictionary
                    
                    if let result:NSDictionary = (jsonResult?["results"] as! NSDictionary?) {
                        items = result["items"] as! [NSDictionary]
                        apiResult = result
                    } else {
                        items = jsonResult?["items"] as! [NSDictionary]
                        apiResult = jsonResult!
                    }
                    
                    var result:Results
                    if let next:String = apiResult["next"] as! String? {
                        result = Results(next: next, items: items)
                    } else {
                        result = Results(next: nil, items: items)
                    }
                    
                    
                    
                    completionHandler(result)
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
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
//        mapView.setRegion(region, animated: true)
    }
    
    //When the authrization is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapController : UISearchBarDelegate {
    
}

extension MapController : MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
       willSet {
         // 1
         guard let artwork = newValue as? Artwork else {
           return
         }
         canShowCallout = true
         calloutOffset = CGPoint(x: -5, y: 5)
         rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

         // 2
         markerTintColor = artwork.markerTintColor
         if let letter = artwork.discipline?.first {
           glyphText = String(letter)
         }
       }
     }
}
