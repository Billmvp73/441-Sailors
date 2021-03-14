//
//  Games.swift
//  treasure
//
//  Created by pyhuang on 3/12/21.
//

import Foundation
struct Game {
    var gid: String?
    var username: String?
    var gamename: String?
    var description: String?
    var timestamp: String?
    var tag: String?
    var location: GeoData?
    static let nFields = 7
}

struct Puzzle {
    var location: GeoData?
    var name: String?
}

struct GamePost {
    var username: String?
    var gamename: String?
    var description: String?
    var tag: String?
    var location: GeoData?
    var puzzles: Array<Puzzle> = Array()
}
