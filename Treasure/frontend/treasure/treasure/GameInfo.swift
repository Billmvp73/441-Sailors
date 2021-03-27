//
//  GameInfo.swift
//  treasure
//
//  Created by Guoxin YIN on 2021/3/27.
//

import UIKit

class GameInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameTag: UILabel!
    
    var gamenameString = ""
    var gamedescriptionString = ""
    var gameTagString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameName.text = gamenameString
        gameDescription.text = gamedescriptionString
        gameTag.text = gameTagString
    }
    
    @IBAction func startGame(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentPicker(.camera)
        } else {
            print("Camera not available. iPhone simulators don't simulate the camera.")
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
