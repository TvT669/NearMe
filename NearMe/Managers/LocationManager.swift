//
//  LocationManager.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/4/29.
//

import Foundation
import MapKit
import Observation


enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return NSLocalizedString("Location access denied.", comment:"")
        case .authorizationRestricted:
            return NSLocalizedString("Location access retricted", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknow location", comment: "")
        case .accessDenied:
            return NSLocalizedString("Access denied", comment: "")
        case .network:
            return NSLocalizedString("Network failed", comment: "")
        case .operationFailed:
            return NSLocalizedString("Operation failed", comment: "")
        
        }
    }
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    static let shared = LocationManager()
    
  
    var currentLocation: CLLocation?
    
    // 控制是否更新区域
     var shouldUpdateRegion: Bool = true
    
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var error: LocationError? = nil
    
   private override init() {
       super.init()
       self.manager.delegate = self
       
       /*添加精度设置和启动位置更新
              manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation  // 导航级别精度
              manager.distanceFilter = 10   最小移动距离(米)才触发更新*/
      
    }
}

extension LocationManager {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        // 坐标转换（WGS-84 → GCJ-02）
          let convertedCoord = CoordinateConverter.wgs84ToGcj02(wgs84: location.coordinate)
          
          // 创建转换后的位置
          let convertedLocation = CLLocation(
              coordinate: convertedCoord,
              altitude: location.altitude,
              horizontalAccuracy: location.horizontalAccuracy,
              verticalAccuracy: location.verticalAccuracy,
              timestamp: location.timestamp
          )
          
          // 保存转换后的位置
          self.currentLocation = convertedLocation
        
        print("📍 原始坐标: \(location.coordinate.latitude), \(location.coordinate.longitude)")
              print("📍 转换后坐标: \(convertedCoord.latitude), \(convertedCoord.longitude)")
              print("📍 精度: \(location.horizontalAccuracy)米")
        
        // 仅在需要时更新地图区域
           if shouldUpdateRegion {
               self.region = MKCoordinateRegion(
                   center: convertedCoord,
                   span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
               )
           }
        
        //  print("LocationManager当前位置: 经度=\(location.coordinate.longitude), 纬度=\(location.coordinate.latitude)")
        
        /*  locations.last.map {
         region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
         }*/
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case.authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            
            /*
            manager.startUpdatingLocation()*/
        case.denied:
            error = .authorizationDenied
        case .restricted:
            error = .authorizationRestricted
        @unknown default :
            break
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        //在 locationManager(_:didFailWithError:) 方法中将 error 转换为 CLError 的目的是 ​精准识别 Core Location 框架抛出的特定错误类型，这是处理定位错误的关键步骤。
        
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                self.error = . unknownLocation
            case .denied:
                self .error = .accessDenied
            case .network:
                self.error = .network
            default:
                self.error = .operationFailed
            }
        }
    }
    
    
}
