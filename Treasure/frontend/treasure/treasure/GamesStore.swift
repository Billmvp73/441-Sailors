//
//  ChattStore.swift
//  swiftChatter
//
//  Created by pyhuang on 2/2/21.
//

import Foundation

struct GamesStore {
    //private let serverUrl = "https://mobapp.eecs.umich.edu/"
    private let serverUrl = "https://174.138.33.66/"
    private var cur_geodata: GeoData? = nil
//
//    init(geodata: GeoData?) {
//        self.geodata = geodata
//    }
    
    func jsonToString(json: AnyObject)->String?{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
//            print(convertedString ?? "defaultvalue")
            return convertedString
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    func addUser(_ idToken: String?, completion: @escaping (String) -> Void) {
        guard let idToken = idToken else {
            completion("FAILED")
            return
        }
        
        let jsonObj = ["clientID": "447127907008-jaolt3qpes97ubd24d3te0plvcufo01r.apps.googleusercontent.com",
                    "idToken" : idToken]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("addUser: jsonData serialization error")
            completion("FAILED")
            return
        }

        guard let apiUrl = URL(string: serverUrl+"adduser/") else {
            print("addUser: Bad URL")
            completion("FAILED")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task =  URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("addUser: NETWORKING ERROR")
                completion("FAILED")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("addUser: HTTP STATUS: \(httpStatus.statusCode)")
                completion("FAILED")
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("addUser: failed JSON deserialization")
                completion("FAILED")
                return
            }

            UserID.shared.token = jsonObj["token"] as? String
            UserID.shared.username = jsonObj["username"] as? String
            UserID.shared.expiration = Date()+(jsonObj["lifetime"] as! TimeInterval)
            completion("OK")
        }
        task.resume()

    }
    
    
    func postGames(_ game: GamePost)->Bool? {
        
        var geoObj: Data?
        if let geodata = game.location {
            geoObj = try? JSONSerialization.data(withJSONObject: [geodata.lat, geodata.lon, geodata.loc, geodata.facing, geodata.speed])
        }
        let puzzles = game.puzzles
        var puzzleStrs = [Dictionary<String, String?>]()
        for puzzle in puzzles{
            var puzzleLoc: Data?
            if let geodata = puzzle.location{
                puzzleLoc = try? JSONSerialization.data(withJSONObject: [geodata.lat, geodata.lon, geodata.loc, geodata.facing, geodata.speed])
            }
            let jsonPuzzle = ["name": puzzle.name,
                              "description": puzzle.description,
                              "type": puzzle.type,
                              "location": (puzzleLoc == nil) ? nil:String(data: puzzleLoc!, encoding: .utf8)]
            puzzleStrs += [jsonPuzzle]
        }
        

        let puzzleStrAll = try?JSONSerialization.data(withJSONObject: puzzleStrs)
        let jsonObj = ["token": UserID.shared.token,
                       "gamename": game.gamename,
                       "location": (geoObj == nil) ? nil : String(data: geoObj!, encoding: .utf8),
                       "description": game.description,
                       "tag": game.tag, "puzzles": (puzzleStrAll == nil) ? nil : String(data: puzzleStrAll!, encoding: .utf8)]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postGames: jsonData serialization error")
            return false
        }
                
        guard let apiUrl = URL(string: serverUrl+"postgames/") else {
            print("postGames: Bad URL")
            return false
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("postGames: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("postGames: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
        }
        task.resume()
        return true
    }
    
    mutating func getLocation(_ geodata: GeoData) {
        self.cur_geodata = geodata
    }
    
    func getGames(refresh: @escaping ([Game]) -> (),
                       completion: @escaping () -> ()) {
//        let strURL = serverUrl + geodata!.loc + "/"
        var strURL = serverUrl + "getgames/"
        var city_name = ""
        if let location = self.cur_geodata?.loc {
            city_name = location
        }
        city_name = city_name.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        if (city_name != "") {
            strURL += city_name+"/"
            print(strURL)
        }
        else {
            strURL += "null/"
        }

        guard let apiUrl = URL(string: strURL) else {
            print("getGames: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { completion() }
            guard let data = data, error == nil else {
                print("getGames: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getGames: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getGames: failed JSON deserialization")
                return
            }
            var games = [Game]()
            var jsonPuzzle: [Dictionary<String, String?>]?
            let gamesReceived = jsonObj["games"] as? [[String?]] ?? []
            for gameEntry in gamesReceived {
                var puzzles = [Puzzle]()
                if let PuzzleObj = gameEntry[7]?.data(using: .utf8){
                    jsonPuzzle = try? JSONSerialization.jsonObject(with: PuzzleObj, options: .allowFragments) as?[Dictionary<String, String>]
                    if jsonPuzzle != nil{
                        for puzzleObj in jsonPuzzle!{
                            let puzzleArr = puzzleObj as Dictionary<String, String?>
                            let geoObj = puzzleArr[
                                "location"]!?.data(using: .utf8)
                            let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                            let puzzle = Puzzle(location: (geoArr == nil) ? nil :
                                                    GeoData(lat: geoArr![0] as! Double,
                                                            lon: geoArr![1] as! Double,
                                                            loc: geoArr![2] as! String,
                                                            facing: geoArr![3] as! String,
                                                            speed: geoArr![4] as! String),
                                                name: puzzleArr["name"]!!,
                                                type: puzzleArr["type"]!!,
                                                description: puzzleArr["description"]!!)
                            puzzles += [puzzle]
                        }
                    }
                } else{
                    print("puzzle: nil.")
                }
                let geoObj = gameEntry[4]?.data(using: .utf8)
                let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                games += [Game(username: gameEntry[0],
                                 gamename: gameEntry[1],
                                 description: gameEntry[2],
                                 tag: gameEntry[3],
                                 gid:gameEntry[5],
                                 location: (geoArr == nil) ? nil :
                                    GeoData(lat: geoArr![0] as! Double,
                                            lon: geoArr![1] as! Double,
                                            loc: geoArr![2] as! String,
                                            facing: geoArr![3] as! String,
                                            speed: geoArr![4] as! String)
                                 , puzzles: puzzles, timestamp: gameEntry[6])]
            }
            refresh(games)
        }
        task.resume()
    }
    
    func getAllGames(refresh: @escaping ([Game]) -> (),
                       completion: @escaping () -> ()) {
        let strURL = serverUrl + "getallgames/"

        guard let apiUrl = URL(string: strURL) else {
            print("getGames: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { completion() }
            guard let data = data, error == nil else {
                print("getGames: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getGames: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getGames: failed JSON deserialization")
                return
            }
            var games = [Game]()
            var jsonPuzzle: [Dictionary<String, String?>]?
            let gamesReceived = jsonObj["games"] as? [[String?]] ?? []
            for gameEntry in gamesReceived {
                var puzzles = [Puzzle]()
                if let PuzzleObj = gameEntry[7]?.data(using: .utf8){
                    jsonPuzzle = try? JSONSerialization.jsonObject(with: PuzzleObj, options: .allowFragments) as?[Dictionary<String, String>]
                    if jsonPuzzle != nil{
                        for puzzleObj in jsonPuzzle!{
                            let puzzleArr = puzzleObj as Dictionary<String, String?>
                            let geoObj = puzzleArr[
                                "location"]!?.data(using: .utf8)
                            let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                            let puzzle = Puzzle(location: (geoArr == nil) ? nil :
                                                    GeoData(lat: geoArr![0] as! Double,
                                                            lon: geoArr![1] as! Double,
                                                            loc: geoArr![2] as! String,
                                                            facing: geoArr![3] as! String,
                                                            speed: geoArr![4] as! String),
                                                name: puzzleArr["name"]!!,
                                                type: puzzleArr["type"]!!,
                                                description: puzzleArr["description"]!!)
                            puzzles += [puzzle]
                        }
                    }
                } else{
                    print("puzzle: nil.")
                }
                let geoObj = gameEntry[4]?.data(using: .utf8)
                let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                games += [Game(username: gameEntry[0],
                                 gamename: gameEntry[1],
                                 description: gameEntry[2],
                                 tag: gameEntry[3],
                                 gid:gameEntry[5],
                                 location: (geoArr == nil) ? nil :
                                    GeoData(lat: geoArr![0] as! Double,
                                            lon: geoArr![1] as! Double,
                                            loc: geoArr![2] as! String,
                                            facing: geoArr![3] as! String,
                                            speed: geoArr![4] as! String)
                                 , puzzles: puzzles, timestamp: gameEntry[6])]
            }
            refresh(games)
        }
        task.resume()
    }
}
