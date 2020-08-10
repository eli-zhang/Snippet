//
//  Snippet.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation

struct Snippet {
    var id: Int
    var startTime: Double  // Start time in milliseconds in timeline
    var endTime: Double    // End time in milliseconds in timeline
    var recordingStartTime: Double  // Start time in milliseconds from recording start time (default 0)
    var recordingEndTime: Double    // End time in milliseconds from recording end time (default recording duration)
    var duration: Double   // Duration of clip (recording end time - recording start time)
    var snippetName: String? // Optional name of snippet
    var recording: Recording
    var track: Int = 0
}
