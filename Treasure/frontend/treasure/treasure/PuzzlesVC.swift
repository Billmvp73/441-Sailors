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

class PuzzlesVC: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
//    @IBOutlet weak var scrollView: UIScrollView!
    weak var returnDelegate: ReturnDelegate?
    @IBOutlet weak var mMap: GMSMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var puzzletypeText: UITextField!
    @IBOutlet weak var puzzletypeDropdown: UIPickerView!
    
    //create puzzle list
    var list = ["word puzzle","interaction puzzle"]
    
    // add drop down list for puzzle type
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return list.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return list[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.puzzletypeText.text = self.list[row]
        self.puzzletypeDropdown.isHidden = true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == self.puzzletypeText {
            self.puzzletypeDropdown.isHidden = false
            //if you don't want the users to se the keyboard type:
            textField.endEditing(true)
        }
    }
    
    var prevPuzzles: [Puzzle]? = nil
//    var geodata: GeoData? = nil
    var puzzle: Puzzle? = nil
    var markerPress: [GMSMarker]? = nil
    var puzzleMarker: GMSMarker?
//    var puzzles: [Puzzle]? = nil

    private lazy var locmanager = CLLocationManager() // Create a location manager to interface with iOS's location manager.

    @IBAction func stopPuzzles(_ sender: Any) {
        if let coordinate = self.puzzleMarker?.position{
            let geoPuzzle = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            puzzle = Puzzle(location: geoPuzzle, name: nameText.text, type: puzzletypeText.text, description: descriptionText.text)
            returnDelegate?.onReturn(puzzle!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scrollView.delegate = self
//        puzzletypeText.delegate = self
//        puzzletypeDropdown.delegate = self
        nameText.delegate = self
        descriptionText.delegate = self
        descriptionText.textColor = UIColor.lightGray
//        nameTextField.textColor = UIColor.lightGray
//        tagTextView.textColor = UIColor.lightGray
        descriptionText.layer.borderWidth = 0.5
        descriptionText.layer.borderColor = UIColor.lightGray.cgColor
        descriptionText.clipsToBounds = true
        descriptionText.layer.cornerRadius = 6.0
        descriptionText.text = "description"
        // set self as the delegate for GMSMapView's infoWindow events
        mMap.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mMap.isMyLocationEnabled = true
        // enable the location bull's eye button
        mMap.settings.myLocationButton = true

        var chattMarker: GMSMarker!

        
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBest

        // obtain user's current location so that we can
        // zoom the map to the current location
        locmanager.startUpdatingLocation()
        prevPuzzles?.forEach {
            if let geodata = $0.location {
                chattMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
                chattMarker.map = mMap
                chattMarker.userData = $0
            }
        }
        
        let geodata = GeoData()
        let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
        // move camera to chatt's location
        mMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15.0)
        
        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWillShow(notification:)),
               name: UIResponder.keyboardWillShowNotification,
               object: nil)
        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWillHide(notification:)),
               name: UIResponder.keyboardWillHideNotification,
               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(notification: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mMap.myLocation else {
            return
        }
        locmanager.stopUpdatingLocation()
        
        // Zoom in to the user's current location
        mMap.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15.0)
    }
    
    var counterMarker: Int = 0


    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {

        if self.counterMarker < 1
            {
                self.counterMarker += 1
                let marker = GMSMarker(position: coordinate)
                marker.appearAnimation = GMSMarkerAnimation.pop
                marker.position = coordinate
                marker.title = self.nameText.text
//                marker.snippet = ""
                marker.map = mapView
//                marker.map = mapView
               self.puzzleMarker = marker
        } else {
                self.counterMarker = 0
                self.puzzleMarker?.map = nil
//                self.puzzleMarker?.position = nil
//                print(counterMarker)
        }
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
       guard let puzzle = marker.userData as? Puzzle else {
           return nil
       }

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
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "description"
            textView.textColor = UIColor.lightGray
        }
    }
}
