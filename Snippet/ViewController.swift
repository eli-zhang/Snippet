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

class ViewController: UIViewController, AVAudioRecorderDelegate, UIGestureRecognizerDelegate, RecordingsViewDelegate {
    
    var coreButtons: UIStackView!
    var rewindButton: UIButton!
    var playButton: UIButton!
    var recordButton: UIButton!
    var recordingsView = RecordingsView()
    var audioPlayer = AVAudioPlayer()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var draggableSnippet: UIView!
    
    var recordingsManager = RecordingsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        recordingSession = AVAudioSession.sharedInstance()
        askForPermissions()
        
        rewindButton = UIButton()
        rewindButton.backgroundColor = Colors.RED
        rewindButton.layer.cornerRadius = Sizing.Buttons.SMALL / 2
        rewindButton.setImage(UIImage(named: "Rewind"), for: .normal)
        
        playButton = UIButton()
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
        
        draggableSnippet = UIView()
        draggableSnippet.backgroundColor = .green
        view.addSubview(draggableSnippet)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        draggableSnippet.addGestureRecognizer(gesture)
        draggableSnippet.isUserInteractionEnabled = true
        gesture.delegate = self
                
        setupConstraints()
    }
    
    func setupConstraints() {
        coreButtons.snp.makeConstraints({ make -> Void in
            make.leading.equalTo(view).offset(150)
            make.trailing.equalTo(view).offset(-30)
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
            make.leading.equalTo(view)
            make.trailing.equalTo(coreButtons.snp.leading).offset(-30)
            make.bottom.equalTo(view)
            make.top.equalTo(view)  // to change
        })
        draggableSnippet.snp.makeConstraints({ make -> Void in
            make.center.equalTo(view)
            make.height.width.equalTo(100)
        })
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)
            if gestureRecognizer.view!.frame.minY < 0 && translation.y < 0 {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y)
            } else if gestureRecognizer.view!.frame.maxY > view.frame.maxY && translation.y > 0 {
                
            } else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            }

            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }
    
    @objc func askForPermissions() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Permission granted!")
                    } else {
                        print("User did not grant permission.")
                    }
                }
            }
        } catch {
            print("Failed to request recording session")
        }
    }
    
    func playRecording(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print(error)
        }
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
            recordingsView.collectionView.reloadData()
        } else {
            print("Failed recording")
        }
    }
    
    @objc func recordTapped() {
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

protocol RecordingsViewDelegate: class {
    func playRecording(url: URL)
}
