//
//  MapsVC.swift
//  swiftChatter
//
//  Created by pyhuang on 3/3/21.
//

import UIKit
import GoogleMaps
import SceneKit
import RealityKit
//import Alamofire
import QuickLook

protocol ReturnDelegate: UIViewController {
    func onReturn(_ result: Puzzle)
}

class PuzzlesVC: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, URLSessionDownloadDelegate{
    
    //create puzzle list
    var list = ["word", "toy_plane","toy_drummer","toy_robot_vintage"]
    var ar_url = ["","https://developer.apple.com/augmented-reality/quick-look/models/biplane/toy_biplane.usdz","https://developer.apple.com/augmented-reality/quick-look/models/drummertoy/toy_drummer.usdz","https://developer.apple.com/augmented-reality/quick-look/models/vintagerobot2k/toy_robot_vintage.usdz"]
    var model_files_name = ["","toy_biplane.usdz","toy_drummer.usdz","toy_robot_vintage.usdz"]
    var model_name = ["word", "plane", "drummer", "vintage robot"]
    var cur_row = 0
    var activeTextField : UITextField? = nil
    var activeViewField : UITextView? = nil
    
//    @IBOutlet weak var scrollView: UIScrollView!
    weak var returnDelegate: ReturnDelegate?
    @IBOutlet weak var mMap: GMSMapView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var puzzletypeText: UITextField!
    @IBOutlet weak var puzzletypeDropdown: UIPickerView!
    @IBOutlet weak var wordContentText: UITextView!
    @IBOutlet weak var modelurlText: UITextField!
    @IBOutlet weak var modelnameText: UITextField!
    @IBOutlet weak var sceneView: SCNView!
    
    @IBAction func submit_model_url(_ sender: Any) {
        let model_url: String = self.modelurlText.text!
        self.ar_url.append(model_url)
        let model_file_name = self.get_file_name(url_string: model_url)
        let model_name = model_file_name.components(separatedBy: ".")[0]
        self.list.append(model_name)
        self.model_files_name.append(model_file_name)
        self.modelurlText.text = ""
        if (modelnameText.text != nil) {
            self.model_name.append(modelnameText.text!)
        }
        else {
            self.model_name.append(model_name)
        }
        self.modelnameText.text = ""
        
        
    }
    
    func get_file_name(url_string: String) -> String{
        let model_name_arr = url_string.components(separatedBy: "/")
        let model_file_name = model_name_arr[model_name_arr.endIndex - 1]
        return model_file_name
    }
    
    /// Downloads An SCNFile From A Remote URL
    func downloadSceneTask(url_string: String){

            //1. Get The URL Of The SCN File
            guard let url = URL(string: url_string) else { return }

            //2. Create The Download Session
            let downloadSession = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: nil)

            //3. Create The Download Task & Run It
            let downloadTask = downloadSession.downloadTask(with: url)
            downloadTask.resume()
        }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        //1. Create The Filename
//        let new_name = "\(self.list[self.cur_row]).usdz"
        let new_name = "\(self.model_files_name[self.cur_row])"
        let fileURL = getDocumentsDirectory().appendingPathComponent(new_name)

        //2. Copy It To The Documents Directory
        do {
            try FileManager.default.copyItem(at: location, to: fileURL)

            print("Successfuly Saved File \(fileURL)")

            //3. Load The Model
//            self.showAr(name: self.model_files_name[self.cur_row])
            

        } catch {

            print("Error Saving: \(error)")
        }

    }
    func getDocumentsDirectory() -> URL {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory

    }

    // add drop down list for puzzle type
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
//        pickerView.selectRow(0, inComponent: 0, animated: true)
//        pickerView.reloadAllComponents();
//        return list.count
        return model_name.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
//        pickerView.reloadAllComponents()
//        pickerView.selectRow(0, inComponent: 0, animated: true)
//        pickerView.reloadAllComponents();
//        return list[row]
        return model_name[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.view.endEditing(true)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        pickerView.reloadAllComponents();
//        self.puzzletypeText.text = self.list[row]
        self.puzzletypeText.text = self.model_name[row]
        self.puzzletypeDropdown.isHidden = true
        self.cur_row = row
        if self.list[row] != "word"{
            self.wordContentText.isHidden = true
            self.sceneView.isHidden = false
            self.downloadSceneTask(url_string: self.ar_url[row])
        } else{
            self.wordContentText.isHidden = false
            self.sceneView.isHidden = true
        }
        
        self.showAr(name: self.model_files_name[row])
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == self.puzzletypeText {
            self.puzzletypeDropdown.isHidden = false
            //if you don't want the users to se the keyboard type:
            textField.endEditing(true)
        }
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      self.activeTextField = nil
    }
    
    var prevPuzzles: [Puzzle]? = nil
    var puzzle: Puzzle? = nil
    var markerPress: [GMSMarker]? = nil
    var puzzleMarker: GMSMarker?

    private lazy var locmanager = CLLocationManager() // Create a location manager to interface with iOS's location manager.

    @IBAction func stopPuzzles(_ sender: Any) {
        if self.puzzleMarker?.map != nil{
            if let coordinate = self.puzzleMarker?.position{
                let geoPuzzle = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
                puzzle = Puzzle(location: geoPuzzle, name: nameText.text, type: self.list[self.cur_row],description: descriptionText.text)
                returnDelegate?.onReturn(puzzle!)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAr(name: String) {
//    func showAr() {
        let downloadedScenePath = getDocumentsDirectory().appendingPathComponent(name)
        do {
            let scene = try SCNScene(url: downloadedScenePath, options: nil)
            
    //        let scene = SCNScene(named: name)
            // 2: Add camera node
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            // 3: Place camera
            cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
            // 4: Set camera on scene
            scene.rootNode.addChildNode(cameraNode)
            
            // 5: Adding light to scene
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
            scene.rootNode.addChildNode(lightNode)
            
            // 6: Creating and adding ambien light to scene
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light?.type = .ambient
            ambientLightNode.light?.color = UIColor.darkGray
            scene.rootNode.addChildNode(ambientLightNode)
            
                    
            // If you don't want to fix manually the lights
        //        sceneView.autoenablesDefaultLighting = true
            
            // Allow user to manipulate camera
            sceneView.allowsCameraControl = true
            
            // Show FPS logs and timming
            // sceneView.showsStatistics = true
            
            // Set background color
            sceneView.backgroundColor = UIColor.white
            
            // Allow user translate image
            sceneView.cameraControlConfiguration.allowsTranslation = false
            
            // Set scene settings
            sceneView.scene = scene
        } catch  {
            print("Error Loading Scene")
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in the viewdidload")
        
        
//        let name = puzzletypeText.text! + ".usdz"
        // 1: Load .obj file
//        let scene = SCNScene(named: "toy plane.usdz")
//        self.showAr(name: "plane.usdz")
        self.puzzletypeDropdown.isHidden = true
        
        
        nameText.delegate = self
        descriptionText.delegate = self
        wordContentText.delegate = self
        descriptionText.textColor = UIColor.lightGray
        descriptionText.layer.borderWidth = 0.5
        descriptionText.layer.borderColor = UIColor.lightGray.cgColor
        descriptionText.clipsToBounds = true
        descriptionText.layer.cornerRadius = 6.0
        descriptionText.text = "description"
        wordContentText.textColor = UIColor.lightGray
        wordContentText.layer.borderWidth = 0.5
        wordContentText.layer.borderColor = UIColor.lightGray.cgColor
        wordContentText.clipsToBounds = true
        wordContentText.layer.cornerRadius = 6.0
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
//         self.view.frame.origin.y = -210 // Move view 150 points upward
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

          // if keyboard size is not available for some reason, dont do anything
          return
        }

        // if active text field is not nil
        if activeTextField != nil && activeTextField!.tag == 1{
            self.view.frame.origin.y = 0
            print("not move the view up")
        } else {
            self.view.frame.origin.y = 0 - keyboardSize.height
            print("move the view up")
        }

      
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
        self.activeViewField = textView
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.tag == 1 {
                textView.text = "What's the content of this puzzle?"
            } else {
                textView.text = "description"
            }
            
            textView.textColor = UIColor.lightGray
        }
        self.activeViewField = nil
    }
}
