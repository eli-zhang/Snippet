//
//  RecordingsView.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import SnapKit

class RecordingsView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: These should be draggable into the timelineView, look into drag and drop
    
//    lazy var collectionView : UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//        //If you set it false, you have to add constraints.
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        cv.delegate = self
//        cv.dataSource = self
//        cv.register(HeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
//        cv.backgroundColor = .yellow
//        return cv
//    }()
    
    var collectionView: UICollectionView!
    var reuseIdentifier = "recordingsViewReuseIdentifier"
    var recordings: [Snippet] = []
    weak var delegate: RecordingsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .red
        
        let layout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecordingsViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make -> Void in
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecordingsViewCell
        cell.layer.cornerRadius = 15
        cell.configure(title: recordings[indexPath.item].snippetName)
        cell.backgroundColor = .cyan
        cell.setNeedsUpdateConstraints()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let audioUrl = recordings[indexPath.item].path
        delegate?.playRecording(url: audioUrl)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: 60)
    }
}
