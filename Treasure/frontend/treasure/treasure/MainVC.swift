//
//  MainVC.swift
//  swiftChatter
//
//  Created by pyhuang on 2/2/21.
//

import UIKit
import UserNotifications

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
    let userNotificationCenter = UNUserNotificationCenter.current()
    private var games = [Game]()  // array of Chatt
    private let geodata = GeoData()
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(startMap(_:)))
        swipeRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeRecognizer)
        refreshControl?.addTarget(self, action: #selector(MainVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        self.requestNotificationAuthorization()
        self.sendNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshTimeline()
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
        performSegue(withIdentifier: "gameinfoSegue", sender: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableCell", for: indexPath) as? GameTableCell else {
            fatalError("No reusable cell!")
        }
        
        let game = games[indexPath.row]
        
        cell.usernameLabel.text = game.username
        cell.usernameLabel.sizeToFit()
        cell.gamenameLabel.text = game.gamename
        cell.gamenameLabel.sizeToFit()
        cell.descriptionLabel.text = game.description
        cell.descriptionLabel.sizeToFit()
        cell.descriptionLabel.numberOfLines = 0
        cell.descriptionLabel.lineBreakMode = .byWordWrapping
        cell.timestampLabel.text = String(game.timestamp?.prefix(10) ?? "")
        cell.timestampLabel.sizeToFit()
        cell.tagLabel.text = game.tag
        cell.tagLabel.sizeToFit()
        cell.numPuzzle.text = "#Puzzles " + String(game.puzzles.count)
        cell.numPuzzle.sizeToFit()
        if let geodata = game.location {
            cell.mapButton.isHidden = false
            cell.locationLabel.text = "Posted from " + geodata.loc
            cell.locationLabel.sizeToFit()
            cell.locationLabel.highlight(searchedText: geodata.loc, geodata.facing, geodata.speed)
            cell.renderGames = {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let mapsVC = storyboard.instantiateViewController(withIdentifier: "MapsVC") as? MapsVC{
                    mapsVC.game = game
                    mapsVC.games = self.games
                    mapsVC.isGames = true
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
        var store = GamesStore()
        let geodata = self.geodata
        store.getLocation(geodata)
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
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }

    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Treasure!!"
        notificationContent.body = "Your friends uploaded new games! Come and try!"
        notificationContent.badge = NSNumber(value: 1)
        
        if let url = Bundle.main.url(forResource: "dune",
                                    withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                            url: url,
                                                            options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as! Int
//        let indexPath = self.tableView.indexPath(for: cell)
        
        let game = games[index]
        
        let gameInfo = segue.destination as! GameInfo
        
        gameInfo.gamenameString = game.gamename!
        gameInfo.gamedescriptionString = game.description!
        gameInfo.gameTagString = game.tag!
    }
    
    
}
