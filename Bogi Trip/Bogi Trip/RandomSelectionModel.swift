//
//  RandomSelectionModel.swift
//  Bogi Trip
//
//  Created by Tymon Kobylecki on 28/12/2021.
//  Copyright © 2021 Tymon Kobylecki. All rights reserved.
//

import UIKit
import CoreLocation

class RandomSelectionModel: NSObject{
    @Published dynamic var coordLat = 0.0
    @Published dynamic var coordLong = 0.0
    func getRandomLocation(location: CLLocationCoordinate2D, rangeMini: Double, rangeMaxi: Double){
        var randDist = 0.0
        if rangeMini < rangeMaxi{
            randDist = Double.random(in: rangeMini..<rangeMaxi)*1000.0
        }else if rangeMini == rangeMaxi{
            randDist = rangeMini * 1000.0
        }
        let randAngle = Double.random(in: 0..<2*Double.pi)
        let coords = moveByDistAngle(angle: randAngle, distanceMeters: randDist, origin: location)
        coordLong = coords.longitude
        coordLat = coords.latitude
    }
    func moveByDistAngle(angle: Double, distanceMeters: Double, origin: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6)
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(angle))
        let lon2 = lon1 + atan2(sin(angle) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
