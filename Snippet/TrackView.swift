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
    var recordings: [[Snippet]] = []
    var zoomMultiplier: Double = 0.003  // Every millisecond is zoomMultiplier * location
    weak var delegate: RecordingsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = Colors.RED
        collectionView.layer.cornerRadius = 8
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make -> Void in
            make.edges.equalTo(self)
        }
    }
    
    func addRecordingToTrack(snippet: Snippet) {
        if recordings.count == 0 {
            recordings.append([snippet])
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            recordings[recordings.count - 1].append(snippet)
            DispatchQueue.main.async {
                self.collectionView.reloadSections([self.recordings.count - 1])
            }
        }
    }
    
    func changeZoom(value: Double) {
        zoomMultiplier = value
        collectionView.reloadData()
    }
    
    func changeTrack(snippet: Snippet) {
        
    }
    
    func translate(snippet: Snippet) {
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
//        return recordings.count
        return recordings.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return recordings[section].count
        if recordings.count == 0 {
            return 0
        }
        return 1    // One cell per track
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackViewCell
        for snippet in recordings[indexPath.section] {
            cell.createDraggableSnippet(snippet: snippet, zoomMultiplier: zoomMultiplier)
        }
        cell.setNeedsUpdateConstraints()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width / 4, height: collectionView.frame.height)
    }
}

protocol TrackViewCellDelegate: class {
    func changeTrack(snippet: Snippet) -> Bool
    func translate(snippet: Snippet)
}
