//
//  TrackViewCell.swift
//  Snippet
//
//  Created by Eli Zhang on 7/26/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import UIKit
import SnapKit

class TrackViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    var draggableSnippets: [UIView] = []
    var zoomMultiplier: Double!
    var startPanLocation: CGPoint?
    weak var delegate: TrackViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        draggableSnippets = []
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func createDraggableSnippet(snippet: Snippet, zoomMultiplier: Double) {
        let draggableSnippet = UIView()
        self.zoomMultiplier = zoomMultiplier
        draggableSnippet.tag = snippet.id   // This may be dangerous with cell reuse
        draggableSnippet.backgroundColor = Colors.LIGHTGRAY
        draggableSnippet.layer.cornerRadius = 5
        draggableSnippets.append(draggableSnippet)
        contentView.addSubview(draggableSnippet)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        draggableSnippet.addGestureRecognizer(gesture)
        draggableSnippet.isUserInteractionEnabled = true
        gesture.delegate = self
        
        draggableSnippet.frame = CGRect(x: Double(self.contentView.frame.minX + Sizing.Tracks.SNIPPET_TO_TRACK_SPACING),
                                        y: snippet.startTime * zoomMultiplier,
                                        width: Double(self.contentView.frame.width - Sizing.Tracks.SNIPPET_TO_TRACK_SPACING * 2),
                                        height: snippet.duration * zoomMultiplier)
    }
    
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            startPanLocation = gestureRecognizer.location(in: self.contentView)
        }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.contentView)
            let xTranslation = gestureRecognizer.location(in: self.contentView).x - (startPanLocation?.x ?? 0)
            if xTranslation > Sizing.Tracks.TRACK_WIDTH + Sizing.Tracks.SNIPPET_TO_TRACK_SPACING {
                print("right")
                if (delegate?.changeTrack(snippetId: gestureRecognizer.view!.tag, left: false))! { // Boolean represents success
                    draggableSnippets = draggableSnippets.filter { $0 == gestureRecognizer.view! }
                }
            } else if xTranslation < -(Sizing.Tracks.TRACK_WIDTH + Sizing.Tracks.SNIPPET_TO_TRACK_SPACING) {
                print("left")
                if (delegate?.changeTrack(snippetId: gestureRecognizer.view!.tag, left: true))! { // Boolean represents success
                    draggableSnippets = draggableSnippets.filter { $0 == gestureRecognizer.view! }
                }
            }
            if gestureRecognizer.view!.frame.minY < 0 || gestureRecognizer.view!.frame.minY == 0 && translation.y <= 0 {
                gestureRecognizer.view!.frame = CGRect(x: gestureRecognizer.view!.frame.minX,
                                                       y: 0,
                                                       width: gestureRecognizer.view!.frame.width,
                                                       height: gestureRecognizer.view!.frame.height)
            } else if gestureRecognizer.view!.frame.maxY >= contentView.frame.maxY && translation.y >= 0 {
                gestureRecognizer.view!.frame = CGRect(x: gestureRecognizer.view!.frame.minX,
                                                       y: contentView.frame.maxY - gestureRecognizer.view!.frame.height,
                                                       width: gestureRecognizer.view!.frame.width,
                                                       height: gestureRecognizer.view!.frame.height)
            } else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            }
            delegate?.translate(snippetId: gestureRecognizer.view!.tag,
                                newStartTime: Double(gestureRecognizer.view!.frame.minY) / zoomMultiplier,
                                newEndTime: Double(gestureRecognizer.view!.frame.maxY) / zoomMultiplier)
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.contentView)
        }
    }
}
