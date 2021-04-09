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
            if result != "Completed"{
                self.nextID = Int(result!)
                if self.nextID != nil{
                    self.History = true
                }
    //            self.History = true
                refreshTimeline()
            } else {
                isCompleted = true
                refreshTimeline()
            }
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
    var nextID: Int? = nil
    var History: Bool? = nil
    var isCompleted = false
    
    private func loadHistory(_ token: String){
        let store = GamesStore()
        store.resumeGame(token, self.gid!, refresh: { pid in
            if let puzzleID = pid{
                self.nextID = Int(puzzleID)
                self.History = true
                print("History exists and load it.")
            } else {
                self.nextID = nil
                self.History = false
                print("History doesn't exist.")
            }
        }) {
            DispatchQueue.main.async {
                if self.nextID == nil && self.History == false{
                    self.continueButton.isHidden = true
                }
            }
        }
    }
    
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
            if self.History == nil{
                // Haven't load any history for this game
                //call store.resumeGame() to load history
                self.loadHistory(token!)
            } else if self.History == true{
                // has history to load
                self.continueButton.isHidden = false
            } else{
                // no history to load
                self.continueButton.isHidden = true
            }
//            self.continueButton.isHidden = false
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
        if let nextPuzzle = self.nextID{
//            self.History = true
//            self.nextID = nil
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mapsVC = storyboard.instantiateViewController(identifier: "MapsVC") as? MapsVC{
    //            arcameraVC.delegate = self
                mapsVC.puzzles = Array(self.puzzles.dropFirst(nextPuzzle))
    //            mapsVC.userLocation = self.location!
                mapsVC.isPlay = true
                mapsVC.isGames = false
                mapsVC.totalPuzzle = self.puzzles.count
                mapsVC.gid = self.gid
                mapsVC.returnDelegate = self
                self.navigationController?.pushViewController(mapsVC, animated: true)
            }
        } else {
            print("No history exists.")
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
            self.nextID = 0
            self.History = true
//            arcameraVC.delegate = self
            mapsVC.puzzles = self.puzzles
//            mapsVC.userLocation = self.location!
            mapsVC.isPlay = true
            mapsVC.isGames = false
            mapsVC.totalPuzzle = self.puzzles.count
            mapsVC.gid = self.gid
            mapsVC.returnDelegate = self
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
                if self.History == nil{
                    // Haven't load any history for this game
                    //call store.resumeGame() to load history
                    self.loadHistory(token!)
                } else if self.History == true{
                    // has history to load
                    self.continueButton.isHidden = false
                } else{
                    // no history to load
                    self.continueButton.isHidden = true
                }
    //            self.continueButton.isHidden = false
                self.LogInButton.isHidden = true
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isCompleted{
            let alert = UIAlertController(title: "Congratulations", message: "You finished the game with a score of \(0)!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.continueButton.isHidden = true
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
