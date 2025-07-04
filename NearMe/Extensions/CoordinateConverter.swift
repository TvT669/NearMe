//
//  CoordinateConverter.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/6/17.
//

import Foundation

// 坐标系转换工具
import CoreLocation

class CoordinateConverter {
    // WGS-84 转 GCJ-02 (火星坐标系)
    static func wgs84ToGcj02(wgs84: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // 这里使用公开的转换算法
        // 实际应用中应使用可靠的转换库
        let pi = Double.pi
        let a = 6378245.0 // 克拉索夫斯基椭球参数长半轴
        let ee = 0.00669342162296594323 // 克拉索夫斯基椭球参数偏心率平方
        
        func transformLat(x: Double, y: Double) -> Double {
            var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
            ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
            ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0
            ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0
            return ret
        }
        
        func transformLon(x: Double, y: Double) -> Double {
            var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
            ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0
            ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0
            ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0
            return ret
        }
        
        let wgLat = wgs84.latitude
        let wgLon = wgs84.longitude
        
        if wgLat < 0.1 && wgLat > 54.0 && wgLon < 73.0 && wgLon > 134.0 {
            return wgs84 // 不在中国大陆，无需转换
        }
        
        var dLat = transformLat(x: wgLon - 105.0, y: wgLat - 35.0)
        var dLon = transformLon(x: wgLon - 105.0, y: wgLat - 35.0)
        
        let radLat = wgLat / 180.0 * pi
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic
        let sqrtMagic = sqrt(magic)
        
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        
        return CLLocationCoordinate2D(
            latitude: wgLat + dLat,
            longitude: wgLon + dLon
        )
    }
}
