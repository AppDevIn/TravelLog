//
//  Location.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 30/1/21.
//

import Foundation

class Location {
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String

    init(latitude lat: Double, longitude lng: Double, date d: Date, dateString ds: String, description des: String) {
        self.latitude = lat
        self.longitude = lng
        self.date = d
        self.dateString = ds
        self.description = des
    }
}
