//
//  EditorView+AdjusterView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/30.
//

import UIKit
import AVFoundation

extension EditorView: EditorAdjusterViewDelegate {
    func editorAdjusterView(willBeginEditing adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(willBeginEditing: self)
    }
    
    func editorAdjusterView(didEndEditing adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(didEndEditing: self)
    }
    
    func editorAdjusterView(editWillAppear adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(editWillAppear: self)
    }
    
    func editorAdjusterView(editDidAppear adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(editDidAppear: self)
    }
    
    func editorAdjusterView(editWillDisappear adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(editWillDisappear: self)
    }
    
    func editorAdjusterView(editDidDisappear adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(editDidDisappear: self)
    }
    
    func editorAdjusterView(contentViewBeganDrag adjusterView: PhotoEditorView) {
        editDelegate?.editorView(contentViewBeganDrag: self)
    }
    
    func editorAdjusterView(contentViewEndDraw adjusterView: PhotoEditorView) {
        editDelegate?.editorView(contentViewEndDraw: self)
    }
    
    func editorAdjusterView(_ adjusterView: EditorAdjusterView, didSelectedStickerText item: EditorStickerItem) {
        
    }
    
    func editorAdjusterView(didRemoveAudio adjusterView: EditorAdjusterView) {
        editDelegate?.editorView(didRemoveAudio: self)
    }
    
    func editorAdjusterView(_ editorAdjusterView: EditorAdjusterView, videoDidPlayAt time: CMTime) {
        
    }
    func editorAdjusterView(_ editorAdjusterView: EditorAdjusterView, videoDidPauseAt time: CMTime) {
        
    }
    func editorAdjusterView(videoReadyForDisplay editorAdjusterView: EditorAdjusterView) {
        if reloadContent {
            layoutContent = true
            layoutSubviews()
            reloadContent = false
        }
    }
}
