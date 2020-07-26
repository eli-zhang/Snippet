//
//  RecordingsViewCell.swift
//  Snippet
//
//  Created by Eli Zhang on 7/22/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import SnapKit

class RecordingsViewCell: UICollectionViewCell {
    var snippetTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        snippetTitle = UILabel()
        contentView.addSubview(snippetTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        snippetTitle.snp.makeConstraints({ make -> Void in
            make.leading.trailing.equalTo(self.contentView)
        })
        super.updateConstraints()
    }
    
    func configure(title: String) {
        snippetTitle.text = title
    }
}
