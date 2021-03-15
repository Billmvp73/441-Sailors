//
//  GeoData.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import Foundation
import GoogleMaps

class GeoData: NSObject, CLLocationManagerDelegate {
    var lat: Double = 0.0
    var lon: Double = 0.0
    var loc: String = ""
    var facing: String = "unknown"
    var speed: String = "unknown"
    var currLoc: Bool = true
    
    init(lat: Double = 0.0,  lon: Double = 0.0, loc: String = "", facing: String = "unknown", speed: String = "unknown") {
        self.lat = lat; self.lon = lon; self.loc = loc; self.facing = facing; self.speed = speed
    }
    
    private lazy var locmanager = CLLocationManager()
    
    init(lat: Double = 0.0, lon: Double = 0.0){
        super.init()
        self.lat = lat
        self.lon = lon
        self.currLoc = false
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        locmanager.requestWhenInUseAuthorization()

        // and start getting user's current location and heading
        locmanager.startUpdatingLocation()
        locmanager.startUpdatingHeading()
    }

    override init() {
        super.init()
        // Configure the location manager
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest
        locmanager.requestWhenInUseAuthorization()

        // and start getting user's current location and heading
        locmanager.startUpdatingLocation()
        locmanager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Get user's location
            if self.currLoc == true{
                lat = location.coordinate.latitude
                lon = location.coordinate.longitude
                // Reverse geocode to get user's city name
                GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { response , _ in
                    if let address = response?.firstResult(), let lines = address.lines {
                        // get city name from the first address returned
                        self.loc = lines[0].components(separatedBy: ", ")[1]
                    }
                }
            } else {
                let newCoordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
                GMSGeocoder().reverseGeocodeCoordinate(newCoordinate) { response , _ in
                    if let address = response?.firstResult(), let lines = address.lines {
                        // get city name from the first address returned
                        self.loc = lines[0].components(separatedBy: ", ")[1]
                    }
                }
            }
            
//            if lat == 0 && lon == 0{
//                lat = location.coordinate.latitude
//                lon = location.coordinate.longitude
//            }
            
            // Reverse geocode to get user's city name
//            GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { response , _ in
//                if let address = response?.firstResult(), let lines = address.lines {
//                    // get city name from the first address returned
//                    self.loc = lines[0].components(separatedBy: ", ")[1]
//                }
//            }
            
            // Get user's speed of movement
            if (location.speed < 0.0) {
                // bad reading: probably due to initial fix, try again
                return
            }
            locmanager.stopUpdatingLocation()
            speed = convertSpeed(location.speed)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (newHeading.headingAccuracy < 0) {
            // unreliable reading, try again
            return
        }
        locmanager.stopUpdatingHeading()
        facing = convertHeading(newHeading.magneticHeading)
    }

    func convertHeading(_ heading: Double) -> String {
        let compass = ["North", "NE", "East", "SE", "South", "SW", "West", "NW", "North"]
        let index = Int(round(heading.truncatingRemainder(dividingBy: 360) / 45))
        return compass[index]
    }
    func convertSpeed(_ speed: Double) -> String {
        switch speed {
            case 1.2..<5:
                return "walking"
            case 5..<7:
                return "running"
            case 7..<13:
                return "cycling"
            case 13..<30:
                return "driving"
            case 30..<56:
                return "in train"
            case 56..<256:
                return "flying"
            default:
                return "resting"
        }
    }
}
