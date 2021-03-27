//
//  GameInfo.swift
//  treasure
//
//  Created by Guoxin YIN on 2021/3/27.
//

import UIKit
import CoreLocation
class GameInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameTag: UILabel!
    
    var gamenameString = ""
    var gamedescriptionString = ""
    var gameTagString = ""
    var puzzles = [Puzzle]()
    var location: CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        gameName.text = gamenameString
        gameDescription.text = gamedescriptionString
        gameTag.text = gameTagString
    }
    
    @IBAction func startGame(_ sender: Any) {
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            presentPicker(.camera)
//        } else {
//            print("Camera not available. iPhone simulators don't simulate the camera.")
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let arcameraVC = storyboard.instantiateViewController(identifier: "ARCameraVC") as? ARCameraVC{
//            arcameraVC.delegate = self
            arcameraVC.puzzles = self.puzzles
            arcameraVC.userLocation = self.location!
            self.present(arcameraVC, animated: true, completion: nil)
        }
    }
    
    private func presentPicker(_ sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
//        imagePickerController.mediaTypes = ["public.image","public.movie"]
//        imagePickerController.videoMaximumDuration = TimeInterval(5) // secs
//        imagePickerController.videoQuality = .typeHigh
        print("in presentPicker")
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

//extension GameInfo: ARCameraDelegate{
//    func viewController(controller: ARCameraVC, tappedTarget: ARItem) {
//        self.dismiss(animated: true, completion: nil)
//
//    }
//}
