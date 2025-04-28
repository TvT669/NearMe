//
//  LocationManager.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/4/29.
//

import Foundation
import MapKit
import Observation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    static let shared = LocationManager()
    
    var region: MKCoordinateRegion = MKCoordinateRegion()
    
   private override init() {
       super.init()
       self.manager.delegate = self
    }
}

extension LocationManager {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func locacationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case.authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case.denied:
            print("denied")
        case .restricted:
            print("restricted")
            @unknown default :
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        
    }
}
