//
//  Snippet.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation

struct Snippet {
    var startTime: Double  // Start time in milliseconds from clip
    var endTime: Double    // End time in milliseconds from clip
    var duration: Double
    var snippetName: String
    var path: URL
    var clipId: String
    var track: Int = 0
}
