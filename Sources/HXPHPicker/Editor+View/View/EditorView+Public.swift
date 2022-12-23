//
//  EditorView+Public.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit
import AVFoundation

public extension EditorView {
    
    /// 当前视图状态
    var state: State {
        get { editState }
        set {
            if newValue == .edit {
                startEdit(false)
            }else {
                cancelEdit(false)
            }
        }
    }
    
    /// 当前编辑的类型
    var type: EditorContentViewType {
        adjusterView.contentType
    }
    
    /// 编辑的图片
    var image: UIImage? {
        get { adjusterView.image }
        set { adjusterView.setImage(newValue) }
    }
    
    /// 马赛克图片
    var mosaicImage: UIImage? {
        get { adjusterView.mosaicOriginalImage }
        set { adjusterView.mosaicOriginalImage = newValue }
    }
    
    /// 设置 image
    /// 每次都会重置编辑状态
    func setImage(_ image: UIImage?) {
        resetState()
        self.image = image
        setContent()
    }
    
    /// 更新 image
    /// 如果图片的宽高比不一致会重置编辑状态
    func updateImage(_ image: UIImage?) {
        var updateScale = false
        if let image = image, let lastImage = self.image {
            updateScale = image.width / image.height != lastImage.width / lastImage.height
        }
        if updateScale {
            resetState()
        }
        self.image = image
        if updateScale {
            setContent()
        }
    }
    
    /// 设置 imageData
    /// 支持gif
    func setImageData(_ imageData: Data?) {
        resetState()
        adjusterView.setImageData(imageData)
        setContent()
    }
    
    /// 设置 AVAsset
    /// - Parameters:
    ///   - avAsset: 对应的 AVAsset 对象
    ///   - coverImage: 视频封面图片，在没加载视频之前显示
    func setAVAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        resetState()
        adjusterView.setVideoAsset(avAsset, coverImage: coverImage)
        setContent()
    }
    
    /// 加载视频
    func loadVideo(_ completion: ((Bool) -> Void)? = nil) {
        adjusterView.loadVideoAsset(completion)
    }
    
    /// 视频是否正在播放
    var isVideoPlaying: Bool {
        adjusterView.isVideoPlaying
    }
    
    /// 调整视频播放时间
    func seekVideo(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        adjusterView.seekVideo(to: time, comletion: comletion)
    }
    
    /// 播放视频
    func playVideo() {
        adjusterView.playVideo()
    }
    
    /// 暂停视频
    func pauseVideo() {
        adjusterView.pauseVideo()
    }
    
    /// 重置视频播放时间
    func resetPlayVideo(completion: ((CMTime) -> Void)? = nil) {
        adjusterView.resetPlayVideo(completion: completion)
    }
}

public extension EditorView {
    
    /// 遮罩类型
    var maskType: MaskType {
        get {
            adjusterView.maskType
        }
        set {
            setMaskType(newValue, animated: false)
        }
    }
    
    /// 设置遮罩类型
    func setMaskType(_ maskType: EditorView.MaskType, animated: Bool) {
        adjusterView.setMaskType(maskType, animated: animated)
    }
    
    /// 蒙版图片
    var maskImage: UIImage? {
        get {
            adjusterView.maskImage
        }
        set {
            setMaskImage(newValue, animated: false)
        }
    }
    
    /// 设置蒙版图片
    func setMaskImage(_ image: UIImage?, animated: Bool) {
        adjusterView.setMaskImage(image, animated: animated)
    }
}

public extension EditorView {
    
    /// 重置时是否忽略固定比例的设置（默认：true）
    /// true    重置到原始比例
    /// false   重置到当前比例的中心位置
    var ignoreFixedRatio: Bool {
        get { adjusterView.ignoreFixedRatio }
        set { adjusterView.ignoreFixedRatio = newValue }
    }
    
    /// 固定裁剪框比例
    var isFixedRatio: Bool {
        get { adjusterView.isFixedRatio }
        set { adjusterView.isFixedRatio = newValue }
    }
    
    /// 设置裁剪框比例
    func setAspectRatio(_ ratio: CGSize, animated: Bool) {
        adjusterView.setAspectRatio(ratio, animated: animated)
    }
    
    /// 是否圆形裁剪框
    var isRoundMask: Bool {
        get { adjusterView.isRoundMask }
        set { setRoundMask(newValue, animated: false) }
    }
    
    /// 设置圆形裁剪框
    func setRoundMask(_ isRound: Bool, animated: Bool) {
        if layoutContent {
            operates.append(.setRoundMask(isRound))
            return
        }
        if isRoundMask == isRound {
            return
        }
        if isRound {
            setMaskImage(nil, animated: animated)
            isFixedRatio = true
            adjusterView.isRoundMask = true
            adjusterView.setAspectRatio(.init(width: 1, height: 1), resetRound: false, animated: animated)
        }else {
            isFixedRatio = false
            setAspectRatio(.zero, animated: animated)
        }
    }
    
    /// 开始编辑
    func startEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .edit {
            return
        }
        if layoutContent {
            operates.append(.startEdit)
            return
        }
        editState = .edit
        isScrollEnabled = false
        resetZoomScale(animated)
        setCustomMaskFrame(true)
        adjusterView.startEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
    }
    
    /// 完成编辑
    func finishEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .normal {
            return
        }
        if layoutContent {
            operates.append(.finishEdit)
            return
        }
        editState = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.finishEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
        editSize = adjusterView.editSize
        updateContentSize()
        setCustomMaskFrame(false)
    }
    
    /// 取消编辑
    func cancelEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .normal {
            return
        }
        if layoutContent {
            operates.append(.cancelEdit)
            return
        }
        editState = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.cancelEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
        setCustomMaskFrame(false)
    }
    
}

public extension EditorView {
    
    /// 当前旋转的角度
    var angle: CGFloat {
        adjusterView.currentAngle
    }
    
    /// Rotate custom angle
    /// 旋转自定义角度
    func rotate(_ angle: CGFloat, animated: Bool) {
        if layoutContent {
            operates.append(.rotate(angle))
            return
        }
        adjusterView.rotate(angle, animated: animated)
    }
    
    /// Rotate left 90°
    /// 向左旋转90°
    func rotateLeft(_ animated: Bool) {
        if layoutContent {
            operates.append(.rotateLeft)
            return
        }
        adjusterView.rotateLeft(animated)
    }
    
    /// Rotate right 90°
    /// 向右旋转90°
    func rotateRight(_ animated: Bool) {
        if layoutContent {
            operates.append(.rotateRight)
            return
        }
        adjusterView.rotateRight(animated)
    }
}

public extension EditorView {
    
    /// horizontal mirror
    /// 水平镜像
    func mirrorHorizontally(_ animated: Bool) {
        if layoutContent {
            operates.append(.mirrorHorizontally)
            return
        }
        adjusterView.mirrorHorizontally(animated: animated)
    }
    
    /// 垂直镜像
    func mirrorVertically(_ animated: Bool) {
        if layoutContent {
            operates.append(.mirrorVertically)
            return
        }
        adjusterView.mirrorVertically(animated: animated)
    }
}

public extension EditorView {
    
    /// Is it possible to reset edit
    /// 是否可以重置编辑
    var canReset: Bool {
        adjusterView.canReset
    }
    
    /// Reset edit
    /// 重置编辑
    func reset(_ animated: Bool) {
        if layoutContent {
            operates.append(.reset)
            return
        }
        adjusterView.reset(animated)
    }
}
