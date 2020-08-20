//
//  SignInTokens.swift
//  Snippet
//
//  Created by Eli Zhang on 8/18/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit

struct SignInTokens: Decodable {
    let session_token: String
    let update_token: String
}

struct SessionToken: Decodable {
    let session_token: String
}

