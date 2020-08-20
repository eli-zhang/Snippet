//
//  TrackView.swift
//  Snippet
//
//  Created by Eli Zhang on 7/26/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import SnapKit

class TrackView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var reuseIdentifier = "trackViewReuseIdentifier"
    var addTrackReuseIdentifier = "addTrackReuseIdentifier"
    var tracks: [[Snippet]] = []
    var startTimes: [(Double, Snippet)] = []
    var zoomMultiplier: Double = 0.003  // Every millisecond is zoomMultiplier * location
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var currentPosition: Int = 0
    
    weak var delegate: AudioPlayerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(AddTrackCell.self, forCellWithReuseIdentifier: addTrackReuseIdentifier)
        collectionView.backgroundColor = Colors.RED
        collectionView.layer.cornerRadius = 8
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make -> Void in
            make.edges.equalTo(self)
        }
    }
    
    func beginPlayback() {
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func advanceTimer() {
        if currentPosition < startTimes.count {
            time = (Date().timeIntervalSinceReferenceDate - startTime) * 1000
            while currentPosition < startTimes.count && startTimes[currentPosition].0 <= time {
                delegate?.playRecording(url: startTimes[currentPosition].1.recording.path)
                currentPosition += 1
                print("playing \(currentPosition)")
            }
        } else {
            self.timer?.invalidate()
            currentPosition = 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return tracks.count + 1 // Extra track for adding tracks
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1    // One cell per track
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("PATH: \(indexPath.section)")
        print(tracks.count)
        print(collectionView.numberOfSections)
        if indexPath.section == tracks.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addTrackReuseIdentifier, for: indexPath) as! AddTrackCell
            cell.delegate = self
            cell.setNeedsUpdateConstraints()
            cell.backgroundColor = .purple
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackViewCell
            for snippet in tracks[indexPath.section] {
                cell.createDraggableSnippet(snippet: snippet, zoomMultiplier: zoomMultiplier)
            }
            cell.delegate = self
            cell.setNeedsUpdateConstraints()
            cell.backgroundColor = .yellow
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Sizing.Tracks.TRACK_WIDTH, height: collectionView.frame.height)
    }
}

extension TrackView: TrackViewCellDelegate {
    func addRecordingToTrack(recording: Recording) {
        let newSnippet = Snippet(id: GenerateId.generateSnippetId(), startTime: 0, endTime: recording.duration, recordingStartTime: 0, recordingEndTime: recording.duration, duration: recording.duration, recording: recording, track: 0)
        if tracks.count == 0 {
            tracks.append([newSnippet])
            startTimes.append((newSnippet.startTime, newSnippet))
            startTimes.sort(by: snippetTimeSorter)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            tracks[tracks.count - 1].append(newSnippet)
            DispatchQueue.main.async {
                self.collectionView.reloadSections([self.tracks.count - 1])
            }
        }
    }
    
    func snippetTimeSorter(first: (Double, Snippet), second: (Double, Snippet)) -> Bool {
        return first.0 < second.0
    }
    
    func changeZoom(value: Double) {
        zoomMultiplier = value
        collectionView.reloadData()
    }
    
    func changeTrack(snippetId: Int, left: Bool) -> Bool {
        for (trackIndex, track) in tracks.enumerated() {
            for snippet in track {
                if snippet.id == snippetId {
                    if left && trackIndex > 0 {
                        print("lefto")
                        let updatedSnippet = Snippet(id: snippet.id, startTime: snippet.startTime, endTime: snippet.endTime, recordingStartTime: snippet.recordingStartTime, recordingEndTime: snippet.recordingEndTime, duration: snippet.duration, recording: snippet.recording, track: trackIndex - 1)
                        tracks[trackIndex] = track.filter { $0.id != snippetId }
                        tracks[trackIndex - 1].append(updatedSnippet)
                        collectionView.reloadData()
                        return true
                    } else if !left && trackIndex < tracks.count - 1 {
                        print("righto")
                        let updatedSnippet = Snippet(id: snippet.id, startTime: snippet.startTime, endTime: snippet.endTime, recordingStartTime: snippet.recordingStartTime, recordingEndTime: snippet.recordingEndTime, duration: snippet.duration, recording: snippet.recording, track: trackIndex + 1)
                        tracks[trackIndex] = track.filter { $0.id != snippetId }
                        tracks[trackIndex + 1].append(updatedSnippet)
                        collectionView.reloadData()
                        return true
                    }
                    return false
                }
            }
        }
        return false
    }
    
    func translate(snippetId id: Int, newStartTime: Double, newEndTime: Double) {
        for (trackIndex, track) in tracks.enumerated() {
            for (index, snippet) in track.enumerated() {
                if snippet.id == id {
                    let updatedSnippet = Snippet(id: snippet.id, startTime: newStartTime, endTime: newEndTime, recordingStartTime: snippet.recordingStartTime, recordingEndTime: snippet.recordingEndTime, duration: snippet.duration, recording: snippet.recording)
                    tracks[trackIndex][index] = updatedSnippet
                    for (index, (_, oldSnippets)) in startTimes.enumerated() {
                        if snippet.id == oldSnippets.id {
                            startTimes.remove(at: index)
                            break
                        }
                    }
                    startTimes.append((updatedSnippet.startTime, updatedSnippet))
                    startTimes.sort(by: snippetTimeSorter)
                    return
                }
            }
        }
    }
    
    func addEmptyTrack() {
        print("BEFORE: \(collectionView.numberOfSections)")
        self.tracks.append([])
        print("AFTER: \(collectionView.numberOfSections)")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            print("AFTERAFTER: \(self.collectionView.numberOfSections)")
        }
    }
}

protocol TrackViewCellDelegate: class {
    func changeTrack(snippetId: Int, left: Bool) -> Bool
    func translate(snippetId: Int, newStartTime: Double, newEndTime: Double)
    func addEmptyTrack()
}
