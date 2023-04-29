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
    
    /// 获取当前编辑数据
    var adjustmentData: EditResult.AdjustmentData {
        adjusterView.getData()
    }
    
    /// 设置编辑数据
    func setAdjustmentData(_ data: EditResult.AdjustmentData) {
        if layoutContent {
            adjusterView.isHidden = true
            operates.insert(.setData(data), at: 0)
            return
        }
        if !data.content.editSize.equalTo(.zero) {
            editSize = data.content.editSize
        }
        updateEditSize()
        updateContentSize()
        adjusterView.setData(data)
        if editState == .normal {
            setCustomMaskFrame(false)
        }
        adjusterView.isHidden = false
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
    
    var finalView: UIView {
        adjusterView.finalView
    }
}

// MARK: 绘画
public extension EditorView {
    
    /// 绘画功能，编辑状态下无法开启
    /// 进入编辑模式会自动关闭
    var isDrawEnabled: Bool {
        get { adjusterView.isDrawEnabled }
        set { adjusterView.isDrawEnabled = newValue }
    }
    
    /// 画笔宽度，默认 5
    var drawLineWidth: CGFloat {
        get { adjusterView.drawLineWidth }
        set { adjusterView.drawLineWidth = newValue }
    }
    
    /// 画笔颜色，默认白色
    var drawLineColor: UIColor {
        get { adjusterView.drawLineColor }
        set { adjusterView.drawLineColor = newValue }
    }
    
    /// 绘画是否可以撤销
    var isCanUndoDraw: Bool {
        adjusterView.isCanUndoDraw
    }
    
    /// 撤销上一次的绘画
    func undoDraw() {
        adjusterView.undoDraw()
    }
    
    /// 撤销所有绘画
    func undoAllDraw() {
        adjusterView.undoAllDraw()
    }
}

// MARK: 马赛克涂抹
/// 视频不支持马赛克涂抹
public extension EditorView {
    
    /// 内部生产马赛克图片的宽度，在`setImage`之前设置
    /// 可以自己设置马赛克图片 `mosaicImage`
    var mosaicImageWidth: CGFloat {
        get { adjusterView.mosaicImageWidth }
        set { adjusterView.mosaicImageWidth = newValue }
    }
    
    /// 马赛克图片
    var mosaicImage: UIImage? {
        get { adjusterView.mosaicOriginalImage }
        set { adjusterView.mosaicOriginalImage = newValue }
    }
    
    /// 马赛克涂抹功能，编辑状态下无法开启
    /// 进入编辑模式会自动关闭 
    var isMosaicEnabled: Bool {
        get { adjusterView.isMosaicEnabled }
        set { adjusterView.isMosaicEnabled = newValue }
    }
    
    /// 马赛克宽度，默认 25
    var mosaicWidth: CGFloat {
        get { adjusterView.mosaicWidth }
        set { adjusterView.mosaicWidth = newValue }
    }
    
    /// 涂抹宽度， 默认 30
    var smearWidth: CGFloat {
        get { adjusterView.smearWidth }
        set { adjusterView.smearWidth = newValue }
    }
    
    /// 马赛克涂抹类型，默认 马赛克
    var mosaicType: EditorMosaicType {
        get { adjusterView.mosaicType }
        set { adjusterView.mosaicType = newValue }
    }
    
    /// 是否可以撤销
    var isCanUndoMosaic: Bool {
        adjusterView.isCanUndoMosaic
    }
    
    /// 撤销上一次的马赛克涂抹
    func undoMosaic() {
        adjusterView.undoMosaic()
    }
    
    /// 撤销所有马赛克涂抹
    func undoAllMosaic() {
        adjusterView.undoAllMosaic()
    }
}

public extension EditorView {
    
    /// 是否允许拖动贴图
    var isStickerEnabled: Bool {
        get { adjusterView.isStickerEnabled }
        set { adjusterView.isStickerEnabled = newValue }
    }
    
    /// 拖动贴图时，是否显示删除View
    var isStickerShowTrash: Bool {
        get { adjusterView.isStickerShowTrash }
        set { adjusterView.isStickerShowTrash = newValue }
    }
    
    /// 添加贴图
    func addSticker(
        _ image: UIImage,
        isSelected: Bool = false
    ) {
        let item = EditorStickerItem.init(image: image, imageData: nil, text: nil)
        adjusterView.addSticker(item, isSelected: isSelected)
    }
    
    func addSticker(
        _ music: VideoEditorMusicInfo,
        isSelected: Bool = false
    ) {
        let _music = VideoEditorMusic(audioURL: music.audioURL, lrc: music.lrc)
        _music.parseLrc()
        let item = EditorStickerItem(
            image: .init(),
            imageData: nil,
            text: nil,
            music: _music
        )
        adjusterView.addSticker(item, isSelected: isSelected)
    }
    
    func deselectedSticker() {
        adjusterView.deselectedSticker()
    }
}

// MARK: 自定义遮罩
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

// MARK: 编辑调整
public extension EditorView {
    
    /// 是否显示比例大小
    var isShowScaleSize: Bool {
        get { adjusterView.isShowScaleSize }
        set { adjusterView.isShowScaleSize = newValue }
    }
    
    /// 重置时是否忽略固定比例的设置（默认：true）
    /// true    重置到原始比例
    /// false   重置到当前比例的中心位置
    var isResetIgnoreFixedRatio: Bool {
        get { adjusterView.isResetIgnoreFixedRatio }
        set { adjusterView.isResetIgnoreFixedRatio = newValue }
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
            setAspectRatio(.init(width: 1, height: 1), animated: animated)
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
            operates.append(.startEdit(completion))
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
            operates.append(.finishEdit(completion))
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
            operates.append(.cancelEdit(completion))
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
    
    /// 图片是否需要裁剪
    var isCropedImage: Bool {
        adjusterView.isCropedImage
    }
    
    /// 裁剪图片
    func cropImage(
        _ completion: @escaping (Result<EditResult.Image, EditorError>) -> Void
    ) {
        adjusterView.cropImage(completion: completion)
    }
    
    /// 视频是否需要裁剪
    var isCropedVideo: Bool {
        adjusterView.isCropedVideo
    }
    
    /// 裁剪视频
    func cropVideo(
        factor: EditorVideoFactor,
        progress: ((CGFloat) -> Void)? = nil,
        completion: @escaping (Result<EditResult.Video, EditorError>) -> Void
    ) {
        adjusterView.cropVideo(
            factor: factor,
            progress: progress,
            completion: completion
        )
    }
    
    /// 取消视频裁剪
    func cancelVideoCroped() {
        adjusterView.cancelVideoCroped()
    }
    
    /// 清空上一次裁剪视频时的url缓存
    func removeVideoURLCache() {
        adjusterView.lastVideoFator = nil
    }
}

// MARK: 旋转
public extension EditorView {
    
    /// 当前旋转的角度
    var angle: CGFloat {
        adjusterView.currentAngle
    }
    
    /// Rotate custom angle
    /// 旋转自定义角度
    /// angle > 0 顺时针
    /// angle < 0 逆时针
    func rotate(_ angle: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotate(angle, completion))
            return
        }
        adjusterView.rotate(angle, animated: animated, completion: completion)
    }
    
    /// Rotate left 90°
    /// 向左旋转90°
    func rotateLeft(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotateLeft(completion))
            return
        }
        adjusterView.rotateLeft(animated, completion: completion)
    }
    
    /// Rotate right 90°
    /// 向右旋转90°
    func rotateRight(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotateRight(completion))
            return
        }
        adjusterView.rotateRight(animated, completion: completion)
    }
}

// MARK: 镜像
public extension EditorView {
    
    /// horizontal mirror
    /// 水平镜像
    func mirrorHorizontally(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.mirrorHorizontally(completion))
            return
        }
        adjusterView.mirrorHorizontally(animated: animated, completion: completion)
    }
    
    /// 垂直镜像
    func mirrorVertically(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.mirrorVertically(completion))
            return
        }
        adjusterView.mirrorVertically(animated: animated, completion: completion)
    }
}

// MARK: 重置编辑
public extension EditorView {
    
    /// Is it possible to reset edit
    /// 是否可以重置编辑
    var canReset: Bool {
        adjusterView.canReset
    }
    
    /// Reset edit
    /// 重置编辑
    func reset(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.reset(completion))
            return
        }
        adjusterView.reset(animated, completion: completion)
    }
}

// MARK: 屏幕旋转后更新视图
public extension EditorView {
    
    /// Update Views
    /// 更新视图
    func update() {
        resetZoomScale(false)
        adjusterView.prepareUpdate()
        updateEditSize()
        updateContentSize()
        adjusterView.update()
        if editState == .normal {
            setCustomMaskFrame(false)
        }
    }
}
