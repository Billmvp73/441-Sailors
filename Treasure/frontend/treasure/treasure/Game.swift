//
//  Games.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import Foundation
struct Game {
    var username: String?
    var gamename: String?
    var description: String?
    var tag: String?
    var gid: String?
    var location: GeoData?
    var puzzles: Array<Puzzle> = Array()
    var timestamp: String?
    static let nFields = 8
}

struct Puzzle {
    var location: GeoData?
    var name: String?
    var type: String?
    var description: String?
}

struct GamePost {
    var gamename: String?
    var description: String?
    var tag: String?
    var location: GeoData?
    var puzzles: Array<Puzzle> = Array()
    static let nFields = 5
}
