//
//  UserId.swift
//  treasure
//
//  Created by Yang Du on 3/21/21.
//

import Foundation
final class UserID {
    static let shared = UserID() // create one instance of the class to be shared
    private init(){}                // and make the constructor private so no other
                                    // instances can be created
    
    var expiration = Date(timeIntervalSince1970: 0.0)
    private var field: String?
    var token: String? {
        get { Date() >= expiration ? nil : field }
        set(newValue) { field = newValue }
    }
    private var field2: String?
    var username: String? {
        get { Date() >= expiration ? nil : field2 }
        set(newValue) { field2 = newValue }
    }
}
