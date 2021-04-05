//
//  GameInfo.swift
//  treasure
//
//  Created by Guoxin YIN on 2021/3/27.
//

import UIKit
import CoreLocation
class GameInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, sReturnDelegate{
    func onReturn(_ result: String?) {
        if result != "FAILED"{
            refreshTimeline()
        }
    }
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var gameTag: UILabel!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var gamenameString = ""
    var gamedescriptionString = ""
    var gameTagString = ""
    var puzzles = [Puzzle]()
    var location: CLLocation?
    var gid: String?
    var nextID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        gameName.text = gamenameString
        gameDescription.text = gamedescriptionString
        gameTag.text = gameTagString
        titleBar.title = gamenameString
        let token = UserID.shared.token
        if token == nil{
            self.LogInButton.isHidden = false
            self.continueButton.isHidden = true
        } else{
            self.continueButton.isHidden = false
            self.LogInButton.isHidden = true
        }
    }
    @IBOutlet weak var LogInButton: UIButton!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBAction func signInGame(_ sender: Any) {
        let token = UserID.shared.token
        if token == nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninVC") as? SigninVC {
                signinVC.returnDelegate = self
                self.navigationController!.pushViewController(signinVC, animated: true)
            }
        }
    }
    @IBAction func resumeGame(_ sender: Any) {
        if let token = UserID.shared.token{
            let store = GamesStore()
            store.resumeGame(token, gid!, refresh: { pid in
                if let puzzleID = pid{
                    self.nextID = Int(puzzleID)
//                    print(self.nex)
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let mapsVC = storyboard.instantiateViewController(identifier: "MapsVC") as? MapsVC{
                //            arcameraVC.delegate = self
                            mapsVC.puzzles = Array(self.puzzles.dropFirst(self.nextID!))
                //            mapsVC.userLocation = self.location!
                            mapsVC.isPlay = true
                            mapsVC.isGames = false
                            mapsVC.totalPuzzle = self.puzzles.count
                            mapsVC.gid = self.gid
                            self.navigationController?.pushViewController(mapsVC, animated: true)
                        }
                    }
                }
            })
        }
    }
    @IBAction func startGame(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let arcameraVC = storyboard.instantiateViewController(identifier: "ARCameraVC") as? ARCameraVC{
////            arcameraVC.delegate = self
//            arcameraVC.puzzles = self.puzzles
//            arcameraVC.userLocation = self.location!
//            self.navigationController?.pushViewController(arcameraVC, animated: true)
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mapsVC = storyboard.instantiateViewController(identifier: "MapsVC") as? MapsVC{
//            arcameraVC.delegate = self
            mapsVC.puzzles = self.puzzles
//            mapsVC.userLocation = self.location!
            mapsVC.isPlay = true
            mapsVC.isGames = false
            mapsVC.totalPuzzle = self.puzzles.count
            mapsVC.gid = self.gid
            self.navigationController?.pushViewController(mapsVC, animated: true)
        }
    }
    
    func refreshTimeline(){
        DispatchQueue.main.async {
            let token = UserID.shared.token
            if token == nil{
                self.LogInButton.isHidden = false
                self.continueButton.isHidden = true
            } else{
                self.continueButton.isHidden = false
                self.LogInButton.isHidden = true
            }
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
