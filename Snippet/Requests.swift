//
//  Requests.swift
//  Snippet
//
//  Created by Eli Zhang on 8/18/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Alamofire

class Requests {
    static let serverURL = "http://ec2-13-59-222-251.us-east-2.compute.amazonaws.com:8000"
    
    static func signIn(idToken: String, deviceToken: String, completion: @escaping (SignInTokens) -> Void) {
        let endpoint = "\(serverURL)/api/tokensignin/"
        let parameters: Parameters = ["idtoken": idToken, "deviceToken": deviceToken]
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                let decoder = JSONDecoder()
                if let tokens = try? decoder.decode(SignInTokens.self, from: data) {
                    completion(tokens)
                }
            case let .failure(error):
                if let data = response.data {
                    let decoder = JSONDecoder()
                    if let errorMessage = try? decoder.decode(String.self, from: data) {
                        print(errorMessage)
                    }
                }
                else {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func signOut(googleID: String, deviceToken: String, completion: @escaping () -> Void) {
        UserDefaults.standard.removeObject(forKey: "googleID")
        let endpoint = "\(serverURL)/api/signout/"
        let parameters: Parameters = ["deviceToken": deviceToken, "googleID": googleID]
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                completion()
            case let .failure(error):
                if let data = response.data {
                    let decoder = JSONDecoder()
                    if let errorMessage = try? decoder.decode(String.self, from: data) {
                        print(errorMessage)
                    }
                }
                else {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func updateSessionToken(updateToken: String, completion: @escaping (String) -> Void, failure: @escaping() -> Void) {
        print("Updating session token...")
        let endpoint = "\(serverURL)/api/updatetoken/"
        let parameters: Parameters = ["googleID": UserInfo.getGoogleID(), "updateToken": updateToken]
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case let .success(data):
                print("success")
                let decoder = JSONDecoder()
                if let sessionToken = try? decoder.decode(SessionToken.self, from: data) {
                    completion(sessionToken.session_token)
                }
            case let .failure(error):
                print("failure")
                if let data = response.data {
                    let decoder = JSONDecoder()
                    if let errorMessage = try? decoder.decode(String.self, from: data) {
                        print(errorMessage)
                    }
                }
                else {
                    print(error.localizedDescription)
                }
                failure()
            }
        }
    }
}

