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

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var rewindButton: UIButton!
    var playButton: UIButton!
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        recordingSession = AVAudioSession.sharedInstance()
        askForPermissions()
        
        rewindButton = UIButton()
        rewindButton.backgroundColor = Colors.RED
        rewindButton.layer.cornerRadius = Sizing.Buttons.SMALL / 2
        rewindButton.setImage(UIImage(named: "Rewind"), for: .normal)
        view.addSubview(rewindButton)
        
        playButton = UIButton()
        playButton.backgroundColor = Colors.RED
        playButton.layer.cornerRadius = Sizing.Buttons.LARGE / 2
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        view.addSubview(playButton)
        
        recordButton = UIButton()
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.backgroundColor = Colors.RED
        recordButton.layer.cornerRadius = Sizing.Buttons.SMALL / 2
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.layer.borderColor = UIColor.white.cgColor
        view.addSubview(recordButton)
        
        getDocuments()
        
        setupConstraints()
    }
    
    func setupConstraints() {
        recordButton.snp.makeConstraints({ make -> Void in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.trailing.equalTo(view).inset(20)
            make.width.height.equalTo(Sizing.Buttons.SMALL)
        })
        playButton.snp.makeConstraints({ make -> Void in
            make.bottom.equalTo(recordButton)
            make.trailing.equalTo(recordButton.snp.leading).offset(-20)
            make.width.height.equalTo(Sizing.Buttons.LARGE)
        })
        rewindButton.snp.makeConstraints({ make -> Void in
            make.bottom.equalTo(recordButton)
            make.trailing.equalTo(playButton.snp.leading).offset(-20)
            make.width.height.equalTo(Sizing.Buttons.SMALL)
        })
        
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
    
    func startRecording() {
        var fileName = "Snippet"
        var count = 1
        let filesInDocuments = getDocuments()
        while filesInDocuments.contains(fileName) {
            fileName = "\(fileName)_\(count)"
            count += 1
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")

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
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getDocuments() -> [String] {
        let documentsUrl =  getDocumentsDirectory()

        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)

            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            let m4aFileNames = m4aFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("m4a list:", m4aFileNames)
            return m4aFileNames

        } catch {
            print(error)
        }
        return []
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        UIView.animate(withDuration: 0.5, animations: { self.recordButton.layer.borderWidth = 0 })


        if success {
//            recordButton.setTitle("Tap to Re-record", for: .normal)
            print("Successfully recorded")
        } else {
//            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
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

