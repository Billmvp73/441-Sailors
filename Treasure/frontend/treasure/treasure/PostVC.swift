//
//  ViewController.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, sReturnDelegate, ReturnDelegate, RoutesReturnDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    func onReturn(_ result: String?){ }
    private let geodata = GeoData()
    var puzzles = [Puzzle]()
    @IBOutlet var popupView: UIView!
//    @IBOutlet weak var viewDim: UIView!
    @IBOutlet weak var addPuzzlesButton: UIButton!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBAction func refreshPost(_ sender: Any) {
        self.viewDidLoad()
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var tagTextView: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBAction func submitGames(_ sender: Any) {
        let game = GamePost(gamename: self.nameTextField.text, description: self.descriptionTextView.text, tag: self.tagTextView.text, location: self.geodata, puzzles: self.puzzles)
        
        let store = GamesStore()
        var postResponse : Bool?=nil
        postResponse = store.postGames(game)
        if postResponse == true{
            responseLabel.text = "Post successfully!"
            self.retryButton.isHidden = true
            self.continueButton.isHidden = false
        } else{
            responseLabel.text = "Failed. Please retry."
            self.continueButton.isHidden = true
            self.retryButton.isHidden = false
        }
        popupView.isHidden = false
        popupView.center = self.view.center
        popupView.alpha = 1
        popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        self.view.addSubview(popupView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.popupView.transform = .identity
//            self.viewDim.alpha = 0.8
        }, completion: nil)
//        puzzles = [Puzzle]()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
//    var renderGames:(()->Void)?
//    @IBAction func addPuzzles(_ sender: Any) {
//        self.renderGames = {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let puzzlesVC = storyboard.instantiateViewController(withIdentifier: "PuzzlesVC") as? PuzzlesVC{
//                if self.puzzlestr == nil{
//                    self.present(puzzlesVC, animated: true, completion: nil)
//                }
//            }
//        }
//        self.renderGames?()
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.lightGray
//        nameTextField.textColor = UIColor.lightGray
//        tagTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 6.0
        addPuzzlesButton.clipsToBounds = true
        addPuzzlesButton.layer.cornerRadius = 6.0
//        self.viewDim.backgroundColor = UIColor.black
//        self.viewDim.alpha = 0
        popupView.isHidden = true
        descriptionTextView.text = "description"
        nameTextField.text = ""
        tagTextView.text = ""
        tableView.delegate = self
        tableView.dataSource = self
        // register a defalut cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "puzzleCell")
        tableView.addSubview(refreshControl)
        tableView.isEditing = true
        refreshControl.addTarget(self, action: #selector(PostVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshTimeline()
        // Do any additional setup after loading the view.
        guard let _ = UserID.shared.token else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninVC") as? SigninVC {
                signinVC.returnDelegate = self
                self.navigationController!.pushViewController(signinVC, animated: true)
            }
            return
        }
    }


    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       audioButton.setImage(audioIcon, for: .normal)
        if segue.identifier == "post2Puzzles" {
           let puzzlesVC = segue.destination as? PuzzlesVC
    //        puzzlesVC?.geodata = self.geodata
            puzzlesVC?.prevPuzzles = self.puzzles
           puzzlesVC?.returnDelegate = self
        } else{
            let mapsVC = segue.destination as? MapsVC
            mapsVC?.puzzles = self.puzzles
            mapsVC?.isGames = false
            mapsVC?.returnDelegate = self
        }
    }
    
    func onReturn(_ result: Puzzle) {
        puzzles += [result]
//        tableView.reloadData()
        refreshTimeline()
    }
    
    func onReturnFromRoutes(_ result: Puzzle) {
        puzzles += [result]
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
    
    var refreshControl = UIRefreshControl()
    
    
    // MARK:- TableView handlers
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puzzles.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PuzzleCell", for: indexPath) as! PuzzleCell
        let puzzle = puzzles[indexPath.row]
        cell.indexLabel?.text = "#"+String(indexPath.row)
        cell.nameLabel?.text = puzzle.name
        cell.descriptionLabel?.text = puzzle.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    private func refreshTimeline() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
//        self.tableView.estimatedRowHeight = 140
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.reloadData()
        // stop the refreshing animation upon completion:
//        self.refreshControl.endRefreshing()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
         refreshTimeline()
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.puzzles[sourceIndexPath.row]
        puzzles.remove(at: sourceIndexPath.row)
        puzzles.insert(movedObject, at: destinationIndexPath.row)
        self.perform(#selector(reloadTable), with: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            puzzles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.perform(#selector(reloadTable), with: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    @objc func reloadTable(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

