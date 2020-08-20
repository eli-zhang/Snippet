//
//  UserInfo.swift
//  Snippet
//
//  Created by Eli Zhang on 8/18/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation
import UIKit

class UserInfo {
    static func getGoogleID() -> String {
        return "101010101010"
//        return UserDefaults.standard.string(forKey: "googleID") ?? ""
    }
    
    static func getName() -> String {
        return UserDefaults.standard.string(forKey: "name") ?? ""
    }
    
    static func getProfilePhoto() -> String {
        return UserDefaults.standard.string(forKey: "profilePhoto") ?? ""
    }
    
    static func getSessionToken() -> String {
        return UserDefaults.standard.string(forKey: "sessionToken") ?? ""
    }
    
    static func getUpdateToken() -> String {
        return UserDefaults.standard.string(forKey: "updateToken") ?? ""
    }
    
    static func setSessionToken(newToken: String) {
        UserDefaults.standard.set(newToken, forKey: "sessionToken")
    }
    
    static func setUpdateToken(newToken: String) {
        UserDefaults.standard.set(newToken, forKey: "updateToken")
    }
}
