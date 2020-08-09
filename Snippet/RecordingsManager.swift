//
//  RecordingsController.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation
import AVFoundation

class RecordingsManager {
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getRecordingNames() -> [String] {
        return getRecordingDirectories().map { $0.deletingPathExtension().lastPathComponent }
    }
    
    func getRecordingDirectories() -> [URL] {
        let documentsUrl = getDocumentsDirectory()

        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)

            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            return m4aFiles
        }
        catch {
            print(error)
        }
        return []
    }
    
    func getRecordings() -> [Snippet] {
        return getRecordingDirectories().map {
            let duration = AVAsset(url: $0).duration.seconds * 1000
            return Snippet(
                startTime: 0,
                endTime: duration,
                duration: duration,
                snippetName: $0.deletingPathExtension().lastPathComponent,
                path: $0,
                clipId: "0")
        }
    }
}
