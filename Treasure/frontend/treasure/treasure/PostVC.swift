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
    @IBOutlet weak var discTextView: UITextView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var tagTextView: UITextField!
    @IBAction func submitGames(_ sender: Any) {
        let game = GamePost(userid: "change to apple user id -- TODO",
                        name: self.nameTextField.text, disc: self.discTextView.text, tag: self.tagTextView.text, puzzles: Array())
//        let store = GamesStore()
//        store.postGames(game)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        discTextView.delegate = self
        discTextView.textColor = UIColor.lightGray
        discTextView.layer.borderWidth = 0.5
        discTextView.layer.borderColor = UIColor.lightGray.cgColor
        discTextView.clipsToBounds = true
        discTextView.layer.cornerRadius = 6.0
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
            textView.text = "discription"
            textView.textColor = UIColor.lightGray
        }
    }

}

