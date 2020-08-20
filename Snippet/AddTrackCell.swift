//
//  AddTrackCell.swift
//  Snippet
//
//  Created by Eli Zhang on 8/20/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import SnapKit

class AddTrackCell: UICollectionViewCell {
    var plusButton: UIButton!
    
    weak var delegate: TrackViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        plusButton = UIButton()
        plusButton.backgroundColor = Colors.LIGHTERGRAY
        plusButton.layer.cornerRadius = 8
        plusButton.addTarget(self, action: #selector(addEmptyTrack), for: .touchUpInside)
        contentView.addSubview(plusButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addEmptyTrack() {
        delegate?.addEmptyTrack()
    }
    
    override func updateConstraints() {
        plusButton.snp.makeConstraints { make -> Void in
            make.edges.equalTo(contentView).inset(Sizing.Tracks.SNIPPET_TO_TRACK_SPACING)
        }
        super.updateConstraints()
    }
}
