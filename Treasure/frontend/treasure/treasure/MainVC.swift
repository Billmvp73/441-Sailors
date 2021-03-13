//
//  MainVC.swift
//  swiftChatter
//
//  Created by pyhuang on 2/2/21.
//

import UIKit
extension UILabel {
    func highlight(searchedText: String?..., color: UIColor = .systemBlue) {
        guard let txtLabel = self.text else { return }
        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        searchedText.forEach {
            if let searchedText = $0?.lowercased() {
                let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)
                attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
                attributeTxt.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: self.font.pointSize), range: range)
            }
        }
        self.attributedText = attributeTxt
    }
}

class MainVC: UITableViewController {
    private var games = [Game]()  // array of Chatt

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup refreshControl here later
                
        refreshTimeline()
        // add swipe (left) gesture recorgnizer
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(startMap(_:)))
        swipeRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeRecognizer)
        refreshControl?.addTarget(self, action: #selector(MainVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    @objc func startMap(_ sender: UISwipeGestureRecognizer) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if let mapsVC = storyBoard.instantiateViewController(withIdentifier: "MapsVC") as? MapsVC {
            mapsVC.games = self.games
            self.navigationController!.pushViewController(mapsVC, animated: true)
        }
    }
    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableCell", for: indexPath) as? GameTableCell else {
            fatalError("No reusable cell!")
        }
        
        let game = games[indexPath.row]
        
        cell.usernameLabel.text = game.username
        cell.usernameLabel.sizeToFit()
        cell.messageLabel.text = game.description
        cell.messageLabel.sizeToFit()
        cell.timestampLabel.text = game.timestamp
        cell.timestampLabel.sizeToFit()
        cell.tagLabel.text = game.tag
        cell.tagLabel.sizeToFit()
        if let geodata = game.location {
            cell.mapButton.isHidden = false
            cell.locationLabel.text = "Posted from " + geodata.loc
                + ", while facing " + geodata.facing + " moving at " + geodata.speed + " speed."
            cell.locationLabel.sizeToFit()
            cell.locationLabel.highlight(searchedText: geodata.loc, geodata.facing, geodata.speed)
            cell.renderGames = {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let mapsVC = storyboard.instantiateViewController(withIdentifier: "MapsVC") as? MapsVC{
                    mapsVC.game = game
                    self.present(mapsVC, animated: true, completion: nil)
                }
            }
        } else {
            cell.locationLabel.text = nil
            cell.mapButton.isHidden = true
            cell.renderGames = nil
        }
        return cell
    }
    
    private func refreshTimeline() {
        let store = GamesStore()
        store.getGames(refresh: { games in
            self.games = games
            DispatchQueue.main.async {
                self.tableView.estimatedRowHeight = 140
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        }) {
            DispatchQueue.main.async {
                // stop the refreshing animation upon completion:
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
         refreshTimeline()
    }
}
