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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
}


extension MapController : MKMapViewDelegate {
    
}
