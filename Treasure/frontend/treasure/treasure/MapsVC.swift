//
//  MapsVC.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import UIKit
import GoogleMaps
import CoreLocation
protocol RoutesReturnDelegate: UIViewController {
    func onReturnFromRoutes(_ result: Puzzle)
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class MapsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    @IBOutlet weak var mMap: GMSMapView!
    var game: Game? = nil
    var puzzles: [Puzzle]? = nil
    var isGames: Bool? = nil
    var isPlay: Bool? = nil
    var pins = [CLLocationCoordinate2D]()
    weak var returnDelegate: RoutesReturnDelegate?
    @IBAction func stopMapView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var games: [Game]? = nil
    private lazy var locmanager = CLLocationManager() // Create a location manager to interface with iOS's location manager.

    override func viewDidLoad() {
        super.viewDidLoad()
        // set self as the delegate for GMSMapView's infoWindow events
        mMap.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mMap.isMyLocationEnabled = true
        // enable the location bull's eye button
        mMap.settings.myLocationButton = true
        var chattMarker: GMSMarker!
        if isPlay == false{
            if isGames == true{
                if let game = game, let geodata = game.location {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                    chattMarker = GMSMarker(position: coordinate)
                    chattMarker.map = mMap
                    chattMarker.userData = game

                    // move camera to chatt's location
                    mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
                }
                if let games = games{
                    // set self as the delegate for CLLocationManager's events
                    // and set up the location manager.
                    locmanager.delegate = self
                    locmanager.desiredAccuracy = kCLLocationAccuracyBest

                    // obtain user's current location so that we can
                    // zoom the map to the current location
                    locmanager.startUpdatingLocation()
                    
                    // Add a marker on the MapView for each chatt
                    games.forEach {
                        if let geodata = $0.location {
                            let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                            chattMarker = GMSMarker(position: coordinate)
                            chattMarker.map = mMap
                            chattMarker.userData = $0
                            
                        }
                    }
                   
                }
            } else {
                locmanager.delegate = self
                locmanager.desiredAccuracy = kCLLocationAccuracyBest

                // obtain user's current location so that we can
                // zoom the map to the current location
                locmanager.startUpdatingLocation()
                puzzles?.forEach {
                    if let geodata = $0.location {
                        let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                        chattMarker = GMSMarker(position: coordinate)
                        chattMarker.map = mMap
                        chattMarker.userData = $0
                        pins += [coordinate]
                    }
                }
                self.drawPolyline()
                
                let geodata = GeoData()
                let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                // move camera to chatt's location
                mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
            }
        } else{
            
        }
    }

    func drawPolyline() {
            
        //Step 1:
//        let coordinates = self.geoJson.map({CLLocationCoordinate2D(latitude: $0.last!, longitude: $0.first!)})
        
        //Step 2:
        let chunkSize = 3
        let chunkedCoordinates = self.pins.chunked(into: chunkSize)
        
        //Step 3:
        let path = GMSMutablePath()
        
        //Step 4:
        for chunk in chunkedCoordinates {
            for coordinate in chunk {
                path.add(coordinate)
            }
            
            if chunk.count == 3 {
                let location1 = CLLocation(latitude: chunk[1].latitude, longitude: chunk[1].longitude)
                let location2 = CLLocation(latitude: chunk[2].latitude, longitude: chunk[2].longitude)
                
                if !GMSGeometryIsLocationOnPath(chunk[1], path, false) ||
                    !GMSGeometryIsLocationOnPath(chunk[2], path, false) ||
                    location2.distance(from: location1) < 1.5 {
                    continue
                }
                    
//                let angle = GMSGeometryHeading(chunk[1], chunk[2])// chunk[1].heading(to: chunk[2])
                var arrowImage = UIImage(named: "icons8-arrow-50")
                arrowImage = arrowImage?.withTintColor(UIColor.orange.withAlphaComponent(0.8))
                
//                let marker = GMSMarker(position: chunk[1])
//                marker.icon = arrowImage
//                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//                marker.isFlat = true
//                marker.rotation = angle
//                marker.map = mMap
            }
        }
        
        //Step 5:
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.orange
        polyline.strokeWidth = 5.0
        polyline.map = mMap
        
        //Step 6:
        let bounds = GMSCoordinateBounds(path: path)
        mMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mMap.myLocation else {
            return
        }
        locmanager.stopUpdatingLocation()
        
        // Zoom in to the user's current location
        mMap.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15.0)
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let game = marker.userData as? Game{
            let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 150))
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = 6
            
            let timestamp = UILabel(frame: CGRect.init(x: 10, y: 10, width: view.frame.size.width - 16, height: 15))
            timestamp.text = game.timestamp
            timestamp.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            timestamp.textColor = .systemBlue
            view.addSubview(timestamp)
            
            let username = UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
            username.text = game.username
            username.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            username.textColor = .black
            view.addSubview(username)
         
            let gamename = UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
             gamename.text = game.gamename
             username.font = UIFont.systemFont(ofSize: 16, weight: .bold)
             username.textColor = .black
             view.addSubview(username)
            
            let description = UILabel(frame: CGRect.init(x: username.frame.origin.x, y: username.frame.origin.y + username.frame.size.height + 10, width: view.frame.size.width - 16, height: 15))
            description.text = game.description
            description.textColor = .darkGray
            view.addSubview(description)

            guard let geodata = game.location else {
                return view
            }

            let infoLabel = UILabel(frame: CGRect.init(x: description.frame.origin.x, y: description.frame.origin.y + description.frame.size.height + 30, width: view.frame.size.width - 16, height: 40))
            infoLabel.text = "Posted from " + geodata.loc + ", while facing " + geodata.facing + " moving at " + geodata.speed + " speed."
            infoLabel.font = UIFont.systemFont(ofSize: 16)
            
            infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            infoLabel.numberOfLines = 2
            
            infoLabel.textColor = .black
            infoLabel.highlight(searchedText: geodata.loc, geodata.facing, geodata.speed)
            view.addSubview(infoLabel)
            
            return view
        } else if let puzzle = marker.userData as? Puzzle{
            let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100))
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = 6
         
             let puzzlename = UILabel(frame: CGRect.init(x: 10, y: 10, width: view.frame.size.width - 16, height: 15))
             puzzlename.text = puzzle.name
             puzzlename.font = UIFont.systemFont(ofSize: 16, weight: .bold)
             puzzlename.textColor = .black
             view.addSubview(puzzlename)
         
             let description = UILabel(frame: CGRect.init(x: puzzlename.frame.origin.x, y: puzzlename.frame.origin.y + puzzlename.frame.size.height + 10, width: view.frame.size.width - 16, height: 15))
             description.text = puzzle.description
             description.textColor = .darkGray
             view.addSubview(description)
            return view
        } else{
            return nil
        }

           
       }
}
