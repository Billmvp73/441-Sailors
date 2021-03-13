//
//  Games.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import Foundation
struct Game {
    var username: String?
    var message: String?
    var timestamp: String?
    var tag: String?
    var location: GeoData?
    static let nFields = 5
}

struct Puzzle {
    var geodata: String?
    var name: String?
}

struct GamePost {
    var userid: String?
    var name: String?
    var disc: String?
    var timestamp: String?
    var tag: String?
    var puzzles: Array<Puzzle> = Array()
    static let nFields = 6
}
