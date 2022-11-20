//
//  EditorView+Public.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit
import AVFoundation

public extension EditorView {
    
    /// 当前编辑的类型
    var type: EditorContentViewType {
        adjusterView.contentType
    }
    
    var isVideoPlaying: Bool {
        adjusterView.isVideoPlaying
    }
    
    /// 编辑的图片
    var image: UIImage? {
        get { adjusterView.image }
        set { adjusterView.setImage(newValue) }
    }
    
    /// 马赛克图片
    var mosaicOriginalImage: UIImage? {
        get {
            adjusterView.mosaicOriginalImage
        }
        set {
            adjusterView.mosaicOriginalImage = newValue
        }
    }
    
    func setImage(_ image: UIImage?) {
        resetState()
        self.image = image
        updateContentSize()
        adjusterView.setContent()
    }
    
    func setImageData(_ imageData: Data?) {
        resetState()
        adjusterView.setImageData(imageData)
        updateContentSize()
        adjusterView.setContent()
    }
    
    func setVideoAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        resetState()
        adjusterView.setVideoAsset(avAsset, coverImage: coverImage)
        updateContentSize()
        adjusterView.setContent()
    }
    
    func loadVideoAsset() {
        adjusterView.loadVideoAsset()
    }
    func seekVideo(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        adjusterView.seekVideo(to: time, comletion: comletion)
    }
    func playVideo() {
        adjusterView.playVideo()
    }
    func pauseVideo() {
        adjusterView.pauseVideo()
    }
    func resetPlayVideo(completion: ((CMTime) -> Void)? = nil) {
        adjusterView.resetPlayVideo(completion: completion)
    }
}

public extension EditorView {
    
    func startEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        state = .edit
        isScrollEnabled = false
        resetZoomScale(animated)
        adjusterView.startEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
        }
    }
    
    func finishEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        state = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.finishEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
        }
        editSize = adjusterView.editSize
        updateContentSize()
    }
    
    func cancelEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        state = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.cancelEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
        }
    }
}

public extension EditorView {
    var canReset: Bool {
        adjusterView.canReset
    }
    
    func reset(_ animated: Bool) {
        adjusterView.reset(animated)
    }
}
