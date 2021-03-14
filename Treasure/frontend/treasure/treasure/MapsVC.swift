//
//  MapsVC.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import UIKit
import GoogleMaps

class MapsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mMap: GMSMapView!
    var game: GamePost? = nil
    @IBAction func stopMapView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var games: [GamePost]? = nil
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

        if let game = game, let geodata = game.location {
            
            let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
            chattMarker = GMSMarker(position: coordinate)
            chattMarker.map = mMap
            chattMarker.userData = game

            // move camera to chatt's location
            mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
        } else {
            // set self as the delegate for CLLocationManager's events
            // and set up the location manager.
            locmanager.delegate = self
            locmanager.desiredAccuracy = kCLLocationAccuracyBest

            // obtain user's current location so that we can
            // zoom the map to the current location
            locmanager.startUpdatingLocation()
            
            // Add a marker on the MapView for each chatt
            games?.forEach {
                if let geodata = $0.location {
                    chattMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
                    chattMarker.map = mMap
                    chattMarker.userData = $0
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mMap.myLocation else {
            return
        }
        locmanager.stopUpdatingLocation()
        
        // Zoom in to the user's current location
        mMap.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 6.0)
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
           guard let game = marker.userData as? GamePost else {
               return nil
           }

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
       }
}
