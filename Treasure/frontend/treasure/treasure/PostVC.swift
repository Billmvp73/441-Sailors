//
//  ViewController.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate {
    private let geodata = GeoData()
    
    @IBOutlet weak var addPuzzlesButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var tagTextView: UITextField!
    
    @IBAction func submitGames(_ sender: Any) {
        let game = GamePost(username: "change to google user id -- TODO",
                                    gamename: self.nameTextField.text, description: self.descriptionTextView.text, tag: self.tagTextView.text, location: self.geodata, puzzles: Array())
                let store = GamesStore()
                store.postGames(game)
                dismiss(animated: true, completion: nil)
    }
    
    var renderGames:(()->Void)?
    @IBAction func addPuzzles(_ sender: Any) {
        self.renderGames = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let puzzlesVC = storyboard.instantiateViewController(withIdentifier: "PuzzlesVC") as? PuzzlesVC{
                self.present(puzzlesVC, animated: true, completion: nil)
                var puzzle: Puzzle? = nil
                puzzle = puzzlesVC.puzzle
                print(puzzle?.description)
            }
        }
        self.renderGames?()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 6.0
        addPuzzlesButton.clipsToBounds = true
        addPuzzlesButton.layer.cornerRadius = 6.0
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "descriptionription"
            textView.textColor = UIColor.lightGray
        }
    }

}

