//
//  PreviewData.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/5/3.
//

import Foundation
import MapKit
import Contacts

struct PreviewData {
    
    static var apple: MKMapItem {
        
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        let addressDictionary: [String: Any] = [
            CNPostalAddressStreetKey: "1 Infinite Loop",
            CNPostalAddressCityKey: "Cupertion",
            CNPostalAddressStateKey: "CA",
            CNPostalAddressPostalCodeKey: "95014",
            CNPostalAddressCountryKey: "United States"
        ]
        
        let placemark = MKPlacemark(coordinate: coordinate,addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Apple Inc"
        return mapItem
    }
}
