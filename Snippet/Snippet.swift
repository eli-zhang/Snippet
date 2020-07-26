//
//  Snippet.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation

struct Snippet {
    var startTime: Int  // Start time in milliseconds from clip
    var endTime: Int    // End time in milliseconds from clip
    var snippetName: String
    var path: URL
    var clipId: String
}
