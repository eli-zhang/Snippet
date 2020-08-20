//
//  ViewController.swift
//  Snippet
//
//  Created by Eli Zhang on 7/19/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import Foundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AudioPlayerDelegate {
    
    var coreButtons: UIStackView!
    var zoomSlider: UISlider!
    var rewindButton: UIButton!
    var playButton: UIButton!
    var recordButton: UIButton!
    var recordingsView = RecordingsView()
    var trackView = TrackView()
    
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var draggableSnippet: UIView!
    
    var recordingsManager = RecordingsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        recordingSession = AVAudioSession.sharedInstance()
        askForPermissions()
        setVolume()
        
        zoomSlider = UISlider()
        zoomSlider.minimumTrackTintColor = Colors.RED
        zoomSlider.thumbTintColor = Colors.RED
        zoomSlider.addTarget(self, action: #selector(changeZoom), for: .valueChanged)
        view.addSubview(zoomSlider)
        
        rewindButton = UIButton()
        rewindButton.backgroundColor = Colors.RED
        rewindButton.layer.cornerRadius = Sizing.Buttons.SMALL / 2
        rewindButton.setImage(UIImage(named: "Rewind"), for: .normal)
        
        playButton = UIButton()
        playButton.addTarget(self, action: #selector(beginPlayback), for: .touchUpInside)
        playButton.backgroundColor = Colors.RED
        playButton.layer.cornerRadius = Sizing.Buttons.LARGE / 2
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        
        recordButton = UIButton()
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.backgroundColor = Colors.RED
        recordButton.layer.cornerRadius = Sizing.Buttons.SMALL / 2
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.layer.borderColor = UIColor.white.cgColor
        
        coreButtons = UIStackView()
        coreButtons.axis = .horizontal
        coreButtons.alignment = .center
        coreButtons.distribution = .equalSpacing
        coreButtons.addArrangedSubview(rewindButton)
        coreButtons.addArrangedSubview(playButton)
        coreButtons.addArrangedSubview(recordButton)
        coreButtons.backgroundColor = .black
        view.addSubview(coreButtons)
        
        recordingsView.recordings = recordingsManager.getRecordings()
        recordingsView.delegate = self
        view.addSubview(recordingsView)
        
        trackView = TrackView()
        trackView.delegate = self
        view.addSubview(trackView)
                
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Sockets.connect(completion: {
            print("Connected! YEEE")
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Sockets.disconnect(completion: {
            print("Disconnected.")
        })
    }
    
    func setupConstraints() {
        zoomSlider.snp.makeConstraints({ make -> Void in
            make.leading.trailing.equalTo(coreButtons)
            make.bottom.equalTo(coreButtons.snp.top).offset(-20)
        })
        coreButtons.snp.makeConstraints({ make -> Void in
            make.leading.equalTo(view).offset(150)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(Sizing.Buttons.LARGE)
        })
        recordButton.snp.makeConstraints({ make -> Void in
            make.width.height.equalTo(Sizing.Buttons.SMALL)
        })
        playButton.snp.makeConstraints({ make -> Void in
            make.width.height.equalTo(Sizing.Buttons.LARGE)
        })
        rewindButton.snp.makeConstraints({ make -> Void in
            make.width.height.equalTo(Sizing.Buttons.SMALL)
        })
        recordingsView.snp.makeConstraints({ make -> Void in
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(coreButtons.snp.leading).offset(-30)
            make.bottom.equalTo(view)
            make.top.equalTo(view).offset(40)
        })
        trackView.snp.makeConstraints({ make -> Void in
            make.leading.equalTo(recordingsView.snp.trailing).offset(20)
            make.trailing.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(zoomSlider.snp.top).offset(-20)
        })
    }
    
    @objc func checkPermissions() -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    @objc func askForPermissions() {
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("Permission granted!")
                } else {
                    print("User did not grant permission.")
                }
            }
        }
    }
    
    func setVolume() {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("Couldn't set audio to play from main speaker.")
        }
    }
    
    @objc func changeZoom() {
        trackView.changeZoom(value: Double(zoomSlider.value) * 0.03 + 0.003)
    }
    
    func playRecording(url: URL) {
        do {
            print(url)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    func addRecordingToTrack(recording: Recording) {
        trackView.addRecordingToTrack(recording: recording)
    }
    
    func startRecording() {
        var fileName = "Snippet"
        var count = 1
        let filesInDocuments = recordingsManager.getRecordingNames()
        while filesInDocuments.contains(fileName) {
            fileName = "Snippet_\(count)"
            count += 1
        }
        
        let audioFilename = recordingsManager.getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            UIView.animate(withDuration: 0.5, animations: { self.recordButton.layer.borderWidth = 5 })
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        UIView.animate(withDuration: 0.5, animations: { self.recordButton.layer.borderWidth = 0 })

        if success {
            print("Successfully recorded")
            recordingsView.recordings = recordingsManager.getRecordings()
            recordingsView.collectionView.reloadData()
        } else {
            print("Failed recording")
        }
    }
    
    @objc func beginPlayback() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        }
        catch {
            print("Failed to start AVAudioSession; most likely already started")
        }
        self.trackView.beginPlayback()
    }
    
    @objc func recordTapped() {
        let permissionGranted = checkPermissions()
        if !permissionGranted {
            askForPermissions()
        }
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        }
        catch {
            print("Failed to start AVAudioSession; most likely already started")
        }
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

protocol AudioPlayerDelegate: class {
    func playRecording(url: URL)
    func addRecordingToTrack(recording: Recording)
}
