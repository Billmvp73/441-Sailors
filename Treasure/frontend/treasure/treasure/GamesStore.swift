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
    
    func postGames(_ game: Game) {
        var geoObj: Data?
        if let geodata = game.location {
            geoObj = try? JSONSerialization.data(withJSONObject: [geodata.lat, geodata.lon, geodata.loc, geodata.facing, geodata.speed])
        }
        let jsonObj = ["username": game.username,
                       "message": game.message,
                       "location": (geoObj == nil) ? nil : String(data: geoObj!, encoding: .utf8),
                       "tag": game.tag]
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
    
    func getGames(refresh: @escaping ([Game]) -> (),
                       completion: @escaping () -> ()) {
        guard let apiUrl = URL(string: serverUrl+"getgames/") else {
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
            let gamesReceived = jsonObj["games"] as? [[String?]] ?? []
            for gameEntry in gamesReceived {
                if (gameEntry.count == Game.nFields) {
                    let geoObj = gameEntry[3]?.data(using: .utf8)
                    let geoArr = (geoObj == nil) ? nil : try? JSONSerialization.jsonObject(with: geoObj!) as? [Any]
                    games += [Game(username: gameEntry[0],
                                     message: gameEntry[1],
                                     timestamp: gameEntry[4],
                                     tag: gameEntry[2],
                                     location: (geoArr == nil) ? nil :
                                        GeoData(lat: geoArr![0] as! Double,
                                                lon: geoArr![1] as! Double,
                                                loc: geoArr![2] as! String,
                                                facing: geoArr![3] as! String,
                                                speed: geoArr![4] as! String)
                    )]
                } else {
                    print("getGames: Received unexpected number of fields: \(gameEntry.count) instead of \(Game.nFields).")
                }
            }
            refresh(games)
        }
        task.resume()
    }
}
