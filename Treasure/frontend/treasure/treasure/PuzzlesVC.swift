//
//  MapsVC.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import UIKit
import GoogleMaps

protocol ReturnDelegate: UIViewController {
    func onReturn(_ result: Puzzle)
}
class PuzzlesVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    weak var returnDelegate: ReturnDelegate?
    @IBOutlet weak var mMap: GMSMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    var game: GamePost? = nil
    var games: [GamePost]? = nil
    private let geodata = GeoData()
    var puzzle: Puzzle? = nil

    private lazy var locmanager = CLLocationManager() // Create a location manager to interface with iOS's location manager.

    @IBAction func stopPuzzles(_ sender: Any) {
        puzzle = Puzzle(location: geodata, name: "setup a new game", type: "Empty", description: descriptionText.text)
        returnDelegate?.onReturn(puzzle!)
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set self as the delegate for GMSMapView's infoWindow events
        mMap.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mMap.isMyLocationEnabled = true
        // enable the location bull's eye button
        mMap.settings.myLocationButton = true
        var chattMarker: GMSMarker!
//        puzzle.name = "Setup a new puzzle."
//        if let game = game, let geodata = game.location {
//
//            let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
//            chattMarker = GMSMarker(position: coordinate)
//            chattMarker.map = mMap
//            chattMarker.userData = game
//
//            // move camera to chatt's location
//            mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 6.0)
//        } else {
        // set self as the delegate for CLLocationManager's events
        // and set up the location manager.
        let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
        chattMarker = GMSMarker(position: coordinate)
        chattMarker.map = mMap
        puzzle = Puzzle(location: geodata, name: "setup a new game", type: "Empty", description: nil)
        chattMarker.userData = puzzle
        mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 12.0)
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest

        // obtain user's current location so that we can
        // zoom the map to the current location
        locmanager.startUpdatingLocation()
        
        // Add a marker on the MapView for each chatt
//        games?.forEach {
//            if let geodata = $0.location {
//                chattMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
//                chattMarker.map = mMap
//                chattMarker.userData = $0
//            }
//        }
//    }
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
           guard let puzzle = marker.userData as? Puzzle else {
               return nil
           }

           let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 150))
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
        
            
           
//           let timestamp = UILabel(frame: CGRect.init(x: 10, y: 10, width: view.frame.size.width - 16, height: 15))
//           timestamp.text = game.timestamp
//           timestamp.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//           timestamp.textColor = .systemBlue
//           view.addSubview(timestamp)
//
//           let username = UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
//           username.text = game.username
//           username.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//           username.textColor = .black
//           view.addSubview(username)
//
//           let gamename = UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
//            gamename.text = game.gamename
//            username.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//            username.textColor = .black
//            view.addSubview(username)
//
//           let description = UILabel(frame: CGRect.init(x: username.frame.origin.x, y: username.frame.origin.y + username.frame.size.height + 10, width: view.frame.size.width - 16, height: 15))
//           description.text = game.description
//           description.textColor = .darkGray
//           view.addSubview(description)

           guard let geodata = puzzle.location else {
               return view
           }

//           let infoLabel = UILabel(frame: CGRect.init(x: description.frame.origin.x, y: description.frame.origin.y + description.frame.size.height + 30, width: view.frame.size.width - 16, height: 40))
//           infoLabel.text = "Posted from " + geodata.loc + ", while facing " + geodata.facing + " moving at " + geodata.speed + " speed."
//           infoLabel.font = UIFont.systemFont(ofSize: 16)
//
//           infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//           infoLabel.numberOfLines = 2
//
//           infoLabel.textColor = .black
//           infoLabel.highlight(searchedText: geodata.loc, geodata.facing, geodata.speed)
//           view.addSubview(infoLabel)
           
           return view
       }
}
