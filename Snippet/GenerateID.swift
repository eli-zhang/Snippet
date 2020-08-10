//
//  GenerateID.swift
//  Snippet
//
//  Created by Eli Zhang on 8/9/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation

struct GenerateId {
    static var recordingCount: Int = 0
    static var snippetCount: Int = 0
    static func generateRecordingId() -> Int {
        let id = recordingCount
        recordingCount += 1
        return id
    }
    static func generateSnippetId() -> Int {
        let id = snippetCount
        snippetCount += 1
        return id
    }
}
