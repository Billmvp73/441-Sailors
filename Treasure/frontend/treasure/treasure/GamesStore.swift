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
    
    func postGames(_ game: GamePost) {
        
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
//            let puzzleObj = try? JSONSerialization.data(withJSONObject: jsonPuzzle)
//            let strPuzzle = (puzzleObj == nil) ? nil : String(data: puzzleObj!, encoding:  .utf8)
//            puzzleStrs += [strPuzzle]
            puzzleStrs += [jsonPuzzle]
        }
        
//        var puzzleStrAll: String
//        puzzleStrAll = ""
//        for puzzleStr in puzzleStrs{
//            puzzleStrAll += puzzleStr!
//        }
        let puzzleStrAll = try?JSONSerialization.data(withJSONObject: puzzleStrs)
        let jsonObj = ["username": game.username,
                       "gamename": game.gamename,
                       "location": (geoObj == nil) ? nil : String(data: geoObj!, encoding: .utf8),
                       "description": game.description,
                       //"puzzles": game.puzzles, //TODO: may need to encode like geodata
                       "tag": game.tag, "puzzles": (puzzleStrAll == nil) ? nil : String(data: puzzleStrAll!, encoding: .utf8)]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postGames: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: serverUrl+"postgames/") else {
            print("postGames: Bad URL")
            return
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
    }
    
    mutating func getLocation(_ geodata: GeoData) {
        self.cur_geodata = geodata
    }
    
    func getGames(refresh: @escaping ([GamePost]) -> (),
                       completion: @escaping () -> ()) {
//        let strURL = serverUrl + geodata!.loc + "/"
        var strURL = serverUrl + "getgames/"
        print("in the getGames")
        print(self.cur_geodata?.loc)
        if let location = self.cur_geodata?.loc {
            strURL += location + "/"
        }
        print(strURL)
//        guard let apiUrl = URL(string: serverUrl+"getgames/") else {
//            print("getGames: Bad URL")
//            return
//        }
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
            var games = [GamePost]()
            var jsonPuzzle: [Dictionary<String, String?>]?
            let gamesReceived = jsonObj["games"] as? [[String?]] ?? []
            for gameEntry in gamesReceived {
                if (gameEntry.count == Game.nFields) {
                    // TODO: change to json type, do not use gameEntry[xxxx]
                    var puzzles = [Puzzle]()
                    if let PuzzleObj = gameEntry[7]?.data(using: .utf8){
                        jsonPuzzle = try? JSONSerialization.jsonObject(with: PuzzleObj, options: .allowFragments) as?[Dictionary<String, String>]
                        if jsonPuzzle != nil{
                            for puzzleObj in jsonPuzzle!{
                                let puzzleArr = puzzleObj as Dictionary<String, String?>
//                                let puzzleArrs = try? JSONSerialization.jsonObject(with: puzzleArr!) as? [Any]
//                                let puzzle = Puzzle(location: puzzleArrs![0]as!String, name: puzzleArrs![1]as!String, type: puzzleArrs![2]as!String, description: puzzleArrs![3]as!String)
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
//                        print(jsonPuzzle)
                    } else{
                        print("puzzle: nil.")
                    }
                    let geoObj = gameEntry[4]?.data(using: .utf8)
                    let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                    games += [GamePost(username: gameEntry[0],
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
                } else {
                    print("getGames: Received unexpected number of fields: \(gameEntry.count) instead of \(Game.nFields).")
                }
            }
            refresh(games)
        }
        task.resume()
    }
}
