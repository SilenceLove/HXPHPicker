//
//  EditorAdjusterView+ContentView.swift
//  Example
//
//  Created by Slience on 2023/1/19.
//

import UIKit
import AVFoundation

extension EditorAdjusterView {
    var isDrawEnabled: Bool {
        get { contentView.isDrawEnabled }
        set {
            if state == .edit, newValue {
                contentView.isDrawEnabled = false
                return
            }
            contentView.isDrawEnabled = newValue
        }
    }
    var drawLineWidth: CGFloat {
        get { contentView.drawLineWidth }
        set { contentView.drawLineWidth = newValue }
    }
    
    var drawLineColor: UIColor {
        get { contentView.drawLineColor }
        set { contentView.drawLineColor = newValue }
    }
    
    var isCanUndoDraw: Bool {
        contentView.isCanUndoDraw
    }
    
    func undoDraw() {
        contentView.undoDraw()
    }
    
    func undoAllDraw() {
        contentView.undoAllDraw()
    }
    
    var isMosaicEnabled: Bool {
        get { contentView.isMosaicEnabled }
        set {
            if state == .edit, newValue {
                contentView.isMosaicEnabled = false
                return
            }
            contentView.isMosaicEnabled = newValue
        }
    }
    var mosaicImageWidth: CGFloat {
        get { contentView.mosaicImageWidth }
        set { contentView.mosaicImageWidth = newValue }
    }
    var mosaicWidth: CGFloat {
        get { contentView.mosaicWidth }
        set { contentView.mosaicWidth = newValue }
    }
    var smearWidth: CGFloat {
        get { contentView.smearWidth }
        set { contentView.smearWidth = newValue }
    }
    var mosaicType: EditorMosaicType {
        get { contentView.mosaicType }
        set { contentView.mosaicType = newValue }
    }
    var isCanUndoMosaic: Bool {
        contentView.isCanUndoMosaic
    }
    func undoMosaic() {
        contentView.undoMosaic()
    }
    func undoAllMosaic() {
        contentView.undoAllMosaic()
    }
    
    var isStickerEnabled: Bool {
        get { contentView.isStickerEnabled }
        set {
            if state == .edit, newValue {
                contentView.isStickerEnabled = false
                return
            }
            contentView.isStickerEnabled = newValue
        }
    }
    
    var isStickerShowTrash: Bool {
        get { contentView.isStickerShowTrash }
        set { contentView.isStickerShowTrash = newValue }
    }
    
    func addSticker(
        _ item: EditorStickerItem,
        isSelected: Bool = false
    ) {
        contentView.addSticker(item, isSelected: isSelected)
    }
    
    func deselectedSticker() {
        contentView.deselectedSticker()
    }
}

extension EditorAdjusterView: EditorContentViewDelegate {
    func contentView(_ contentView: EditorContentView, videoDidPlayAt time: CMTime) {
        delegate?.editorAdjusterView(self, videoDidPlayAt: time)
    }
    func contentView(_ contentView: EditorContentView, videoDidPauseAt time: CMTime) {
        delegate?.editorAdjusterView(self, videoDidPauseAt: time)
    }
    func contentView(videoReadyForDisplay contentView: EditorContentView) {
        delegate?.editorAdjusterView(videoReadyForDisplay: self)
        updateControlScaleSize()
    }
    
    func contentView(drawViewBeganDraw contentView: EditorContentView) {
        
    }
    func contentView(drawViewEndDraw contentView: EditorContentView) {
        
    }
    func contentView(
        _ contentView: EditorContentView,
        stickersView: EditorStickersView,
        moveToCenter itemView: EditorStickersItemView
    ) -> Bool {
        guard let inControlRect = itemView.superview?.convert(itemView.frame, to: frameView.controlView) else {
            return true
        }
        let controlRect = frameView.controlView.bounds
        if inControlRect.minX > controlRect.width - 40 {
            return true
        }
        if inControlRect.minX < -(inControlRect.width - 40) {
            return true
        }
        if inControlRect.minY > controlRect.height - 40 {
            return true
        }
        if inControlRect.minY < -(inControlRect.height - 40) {
            return true
        }
        return false
    }
    
    func contentView(_ contentView: EditorContentView, stickerMaxScale itemSize: CGSize) -> CGFloat {
        let rect = frameView.controlView.frame.inset(by: .init(top: -30, left: -30, bottom: -30, right: -30))
        let maxScale = max(rect.width / itemSize.width, rect.height / itemSize.height)
        return maxScale
    }
    
    func contentView(_ contentView: EditorContentView, updateStickerText item: EditorStickerItem) {
        
    }
    
    func contentView(_ contentView: EditorContentView, stickerItemCenter stickersView: EditorStickersView) -> CGPoint? {
//        if let window = UIApplication._keyWindow {
//            let windowRect = window.convert(contentView.frame, from: self)
//            let centerHeight: CGFloat
//            if windowRect.height < window.height {
//                centerHeight = windowRect.height
//            }else {
//                centerHeight = window.height
//            }
//            let centerRect = CGRect(x: 0, y: windowRect.minY, width: window.width, height: centerHeight)
//            let contentRect = contentView.convert(centerRect, from: window)
//            return .init(x: contentRect.midX, y: contentRect.midY)
//        }
        return frameView.convert(frameView.controlView.center, to: stickersView)
    }
    
}
