//
//  EditorFrameView+Control.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorFrameView: EditorControlViewDelegate {
    func controlView(beganChanged controlView: EditorControlView, _ rect: CGRect) {
        hideMaskBgView()
        stopControlTimer()
        delegate?.frameView(beganChanged: self, rect)
    }
    
    func controlView(didChanged controlView: EditorControlView, _ rect: CGRect) {
        stopControlTimer()
        maskBgView.updateLayers(rect, false)
        maskLinesView.updateLayers(rect, false)
        delegate?.frameView(didChanged: self, rect)
    }
    
    func controlView(endChanged controlView: EditorControlView, _ rect: CGRect) {
        startControlTimer()
    }
}
