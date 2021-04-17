//
//  MapsVC.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import UIKit
import GoogleMaps
import CoreLocation


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class MapsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ARCameraDelegate{
    func onReturn(_ result: Puzzle) {
//        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
        print("arcamera on return to MapsVC")
        let index = self.puzzles?.firstIndex(where: {$0.name == result.name})
        if let puzzleIndex  = index{
            self.puzzles?.remove(at: puzzleIndex)
        }
        selectedMarker?.map = nil
        if self.loadPuzzle() == false{
            self.completeGame()
        }
    }
    
    weak var returnDelegate: sReturnDelegate?
    
    @IBOutlet weak var mMap: GMSMapView!
    var game: Game? = nil
    var gid: String? = nil
    var timer: Timer? = nil
    var secondsRemaining = 5
    var puzzles: [Puzzle]? = nil
    var isGames: Bool? = nil
    var isPlay: Bool? = nil
    var totalPuzzle: Int? = nil
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var returnLabel: UILabel!
    var pins = [CLLocationCoordinate2D]()
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    var selectedMarker : GMSMarker?
    private let geodata = GeoData()
    @IBAction func stopMapView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var games: [Game]? = nil
    private lazy var locmanager = CLLocationManager() // Create a location manager to interface with iOS's location manager.

    @IBAction func pauseGame(_ sender: Any) {
//        let token = UserID.shared.token
//        if token == nil{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninVC") as? SigninVC {
////                signinVC.returnDelegate = self
//                self.navigationController!.pushViewController(signinVC, animated: true)
//            }
//
//        }
        let store = GamesStore()
        if let currLen = puzzles?.count{
            let pid = totalPuzzle! - currLen
            var pauseResponse: Bool? = nil
            pauseResponse = store.pauseGame(gid!, String(pid))
            if pauseResponse == true{
                responseLabel.text = "Pause succeed."
                retryButton.isHidden = true
                returnLabel.isHidden = false
                secondsRemaining = 5
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
                returnDelegate?.onReturn(String(pid))
            } else {
                responseLabel.text = "Failed. Please Retry."
                retryButton.isHidden = false
                returnLabel.isHidden = true
            }
            popupView.isHidden = false
            popupView.center = self.view.center
            popupView.alpha = 1
            popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            self.view.addSubview(popupView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                self.popupView.transform = .identity
    //            self.viewDim.alpha = 0.8
            }, completion: nil)
        }
        print("Pause here.")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // set self as the delegate for GMSMapView's infoWindow events
        mMap.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mMap.isMyLocationEnabled = true
        // enable the location bull's eye button
        mMap.settings.myLocationButton = true
        var Marker: GMSMarker!
        if isPlay == false{
            //user is showing game locations not playing.
            if isGames == true{
                if let game = game, let geodata = game.location {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                    Marker = GMSMarker(position: coordinate)
                    Marker.map = mMap
                    Marker.userData = game

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
                            Marker = GMSMarker(position: coordinate)
                            Marker.map = mMap
                            Marker.userData = $0
                        }
                    }
                   
                }
            } else {
                locmanager.delegate = self
                locmanager.desiredAccuracy = kCLLocationAccuracyBest

                // obtain user's current location so that we can
                // zoom the map to the current location
                locmanager.startUpdatingLocation()
                var puzzleIndex = 0
                puzzles?.forEach {
                    if let geodata = $0.location {
                        let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                        Marker = GMSMarker(position: coordinate)
                        if puzzleIndex == 0{
                            Marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        }
                        Marker.map = mMap
                        Marker.userData = $0
                        pins += [coordinate]
                        puzzleIndex += 1
                    }
                }
                self.drawPolyline()
                
                let geodata = GeoData()
                let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                // move camera to chatt's location
                mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
            }
        } else{
            // users are playing the game. Show real map to them
            if self.loadPuzzle() == false{
                //no puzzles available
                self.completeGame()
            }
        }
    }
    
    
    @objc func updateCounting(){
            if self.secondsRemaining > 0{
                self.returnLabel.text = "\(self.secondsRemaining)s"
                self.secondsRemaining -= 1
            }else{
                self.timer?.invalidate()
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    func completeGame(){
        // complete Game
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        self.returnDelegate?.onReturn("Completed")
        
    }
    
    func loadPuzzle()->Bool{
        let token = UserID.shared.token
        if token == nil{
            self.pauseButton.isEnabled = false
        }
        var Marker = GMSMarker()
        if puzzles!.count > 0{
            let puzzle = puzzles![0]
            if let geodata = puzzle.location{
                let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                Marker = GMSMarker(position: coordinate)
                Marker.map = mMap
                Marker.userData = CLLocation(latitude: geodata.lat, longitude: geodata.lon)
                mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
            }
            return true
        }
        return false
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
    // When playing
    // click marker to popu up camera background
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) ->Bool {
        if let coordinate = marker.userData as? CLLocation{
//            let userLocation = CLLocation(latitude: self.geodata.lat, longitude: self.geodata.lon)
            let userLocation = mMap.myLocation
            if userLocation!.distance(from: coordinate) < 50 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let arcameraVC = storyboard.instantiateViewController(identifier: "ARCameraVC") as? ARCameraVC{
        //            arcameraVC.delegate = self
                    arcameraVC.puzzleTarget = self.puzzles![0]
                    arcameraVC.userLocation = userLocation!
                    arcameraVC.arCameraDelegate = self
                    selectedMarker = marker
                    self.navigationController?.pushViewController(arcameraVC, animated: true)
                }
            }
        }
        return true
    }
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        print("Do what ever you want.")
//        return true
//    }
}
