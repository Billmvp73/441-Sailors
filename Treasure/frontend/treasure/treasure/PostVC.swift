//
//  ViewController.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import UIKit

@available(iOS 14.0, *)
class PostVC: UIViewController, UITextViewDelegate, ReturnDelegate, UITableViewDelegate, UITableViewDataSource, sReturnDelegate {
    func onReturn(_ result: String?) {
        if result != "FAILED"{
            DispatchQueue.main.async{
                self.setLoginIndecator()
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!
    var timer: Timer?
    var secondsRemaining = 5
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
    @IBOutlet weak var countdownTimer: UILabel!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var tagTextView: UITextField!
    @IBOutlet weak var signinIndicator: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBAction func submitGames(_ sender: Any) {
        var game = GamePost(gamename: self.nameTextField.text, description: self.descriptionTextView.text, tag: self.tagTextView.text, location: self.geodata, puzzles: self.puzzles)
        if puzzles.count > 0{
            game.location = puzzles[0].location
            let store = GamesStore()
            var postResponse : Bool?=nil
            postResponse = store.postGames(game)
            if postResponse == true{
                responseLabel.text = "Post successfully!"
                self.retryButton.isHidden = true
                self.continueButton.isHidden = false
                self.countdownTimer.isHidden = false
                self.secondsRemaining = 5
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
            } else{
                responseLabel.text = "Failed. Please retry."
                self.continueButton.isHidden = true
                self.retryButton.isHidden = false
                self.countdownTimer.isHidden = true
                self.secondsRemaining = 3
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
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
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//            }
        } else{
            responseLabel.text = "Your Game has no puzzle."
            self.retryButton.isHidden = false
            self.continueButton.isHidden = true
            self.countdownTimer.isHidden = true
            popupView.isHidden = false
            popupView.center = self.view.center
            popupView.alpha = 1
            popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            self.view.addSubview(popupView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                self.popupView.transform = .identity
    //            self.viewDim.alpha = 0.8
            }, completion: nil)
        }
        
//        popupView.isHidden = false
//        popupView.center = self.view.center
//        popupView.alpha = 1
//        popupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
//        self.view.addSubview(popupView)
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
//            self.popupView.transform = .identity
////            self.viewDim.alpha = 0.8
//        }, completion: nil)
        puzzles = [Puzzle]()
    }
    
    
    @objc func updateCounting(){
        if self.secondsRemaining > 0{
            self.countdownTimer.text = "\(self.secondsRemaining)s"
            self.secondsRemaining -= 1
        }else{
            self.timer?.invalidate()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLoginIndecator()
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
            mapsVC?.isPlay = false
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
        cell.puzzletypeLabel?.text = puzzle.type
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
    @objc func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setLoginIndecator() {
        if ((UserID.shared.token) != nil) {
            signinIndicator.text = "Logged in as " + UserID.shared.username!
            submitButton.isEnabled = true
        } else {
            signinIndicator.text = "Not logged in"
            submitButton.isEnabled = false
        }
    }
}

