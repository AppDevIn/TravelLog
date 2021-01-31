//
//  Location.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 30/1/21.
//

import Foundation
import MapKit

class Location {
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String
    
    static let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .medium
      return formatter
    }()

    init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
      latitude =  location.latitude
      longitude =  location.longitude
      self.date = date
      dateString = Location.dateFormatter.string(from: date)
      description = descriptionString
    }
    
    convenience init(visit: CLVisit, descriptionString: String) {
      self.init(visit.coordinate, date: visit.arrivalDate, descriptionString: descriptionString)
    }
}
