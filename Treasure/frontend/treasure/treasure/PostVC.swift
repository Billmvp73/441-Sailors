//
//  ViewController.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import UIKit

class PostVC: UIViewController {
    private let geodata = GeoData()
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tagTextView: UITextView!
    @IBAction func submitGames(_ sender: Any) {
        let game = Game(username: self.usernameLabel.text,
                        message: self.messageTextView.text, tag: self.tagTextView.text, location: geodata)
        let store = GamesStore()
        store.postGames(game)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

