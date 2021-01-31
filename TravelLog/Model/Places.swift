//
//  Places.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 30/1/21.
//

import Foundation
import MapKit
import Contacts



class Places: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var mapItem: MKMapItem
    
    init(
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D,
        mapItem: MKMapItem
    ) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.mapItem = mapItem
        super.init()
    }
    
    
}
