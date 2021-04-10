//
//  StreetViewVC.swift
//  treasure
//
//  Created by 潘芝亦 on 2021/4/10.
//

import Foundation
import UIKit
import GoogleMaps

class StreetViewVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
 

    @IBOutlet weak var panoramaView: GMSPanoramaView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panoramaView.delegate = self
        panoramaView.moveNearCoordinate(coordinate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.panoramaView.animate(to: GMSPanoramaCamera(heading: 90, pitch: 0, zoom: 1), animationDuration: 2)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension StreetViewVC: GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        print(error.localizedDescription)
    }
}
