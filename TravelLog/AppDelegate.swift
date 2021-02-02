//
//  AppDelegate.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 16/1/21.
//

import UIKit
import CoreData
import Firebase
import FirebaseFirestore
import CoreLocation
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        
        FirebaseApp.configure()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        checkLocationAuthorization()

        
        
        
        return true
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        
        //When the app is open
        case .authorizedWhenInUse:
            
            break
        //The app is not allowed one time pop up
        case .denied:
            //Show alert with instruction on how to turn on permission
            break
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            //Show an alert letting them know what's up
            break
        //Even when the app is closed
        case .authorizedAlways:
            
            //     Uncomment following code to enable fake visits
            locationManager.distanceFilter = 35 // 0
            locationManager.allowsBackgroundLocationUpdates = true // 1
            locationManager.startUpdatingLocation()  // 2
            break
        default:
            print("Unkown location status")
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TravelLog")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}


// MARK: - Location

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place.name)"
                self.newVisitReceived(visit, description: description)
                
      
                 
            }
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 1
        guard let location = locations.first else {
            return
        }
        
        
        
        // 2
        AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                // 3
                var description:String
                if let name = place.name {
                    description = "\(name)"
                } else {
                    description = "\(place.description)"
                }
                
                
                //4
                let fakeVisit = FakeVisit(
                    coordinates: location.coordinate,
                    arrivalDate: Date(),
                    departureDate: Date())
                
                self.newVisitReceived(fakeVisit, description: description)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        
        
        let placeController = PlaceController()
        guard placeController.AddPlace(visit, description:description) else {
            return
        }
        
      
        
        //Save into the Plist
        let userDefault = UserDefaults.init(suiteName: "group.sg.mad2.TravelLog")
        userDefault!.setValue(description, forKey: "location")

        
        
        // 1
        let content = UNMutableNotificationContent()
        content.title = "New Journal entry 📌"
        content.body = location.description
        content.sound = .default
        
        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        
        // 3
        center.add(request, withCompletionHandler: nil)
        
    }
}


//MARK: - Fake Vist Class

final class FakeVisit: CLVisit {
    private let myCoordinates: CLLocationCoordinate2D
    private let myArrivalDate: Date
    private let myDepartureDate: Date
    
    override var coordinate: CLLocationCoordinate2D {
        return myCoordinates
    }
    
    override var arrivalDate: Date {
        return myArrivalDate
    }
    
    override var departureDate: Date {
        return myDepartureDate
    }
    
    init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
        myCoordinates = coordinates
        myArrivalDate = arrivalDate
        myDepartureDate = departureDate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
