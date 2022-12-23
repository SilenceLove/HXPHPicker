//
//  EditorAdjusterView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit
import AVFoundation

/// - EditorAdjusterView (self)
///     - containerView (容器)
///         - mirrorView (镜像处理)
///             - rotateView (旋转处理)
///             - scrollView (滚动视图)
///                 - contentView (内容视图)
///                     - imageView/videoView (图片/视频内容)
///                     - drawView (画笔绘图层)
///                     - mosaic (马赛克图层)
///         - frameView (遮罩、控制裁剪范围)
class EditorAdjusterView: UIView {
    
    weak var delegate: EditorAdjusterViewDelegate?
    
    var setContentInsets: (() -> UIEdgeInsets)?
    
    var contentType: EditorContentViewType {
        contentView.type
    }
    var isVideoPlaying: Bool {
        contentView.isPlaying
    }
    
    var maximumZoomScale: CGFloat = 20
    
    var animateDuration: TimeInterval = 0.3
    
    var contentInsets: UIEdgeInsets = .zero
    
    var state: EditorView.State = .normal
    
    var adjustedData: AdjustedData = .init()
    var oldAdjustedData: AdjustedData?
    
    var oldFactor: EditorControlView.Factor?
    
    var isOriginalRatio: Bool {
        let aspectRatio = frameView.aspectRatio
        if aspectRatio.equalTo(.zero) {
            return true
        }else {
            if aspectRatio.width / aspectRatio.height == contentScale {
                return true
            }
        }
        return false
    }
    
    var ignoreFixedRatio: Bool = true
    
    var baseContentSize: CGSize = .zero
    var zoomScale: CGFloat = 1 {
        didSet { contentView.zoomScale = zoomScale * scrollView.zoomScale }
    }
    var editSize: CGSize = .zero
    var superContentInset: UIEdgeInsets = .zero
    
    var isMaskBgViewShowing: Bool = false
    
    var currentAngle: CGFloat {
        if state == .normal {
            return oldAdjustedData?.angle ?? 0
        }
        return adjustedData.angle
    }
    
    var maskType: EditorView.MaskType {
        get {
            frameView.maskType
        }
        set {
            setMaskType(newValue, animated: false)
        }
    }
    func setMaskType(_ maskType: EditorView.MaskType, animated: Bool) {
        frameView.setMaskType(maskType, animated: animated)
    }
    
    var oldMaskImage: UIImage?
    var oldIsRound: Bool = false
    
    var maskImage: UIImage? {
        get {
            frameView.maskImage
        }
        set {
            setMaskImage(newValue, animated: false)
        }
    }
    func setMaskImage(_ image: UIImage?, animated: Bool) {
        adjustedData.maskImage = image
        frameView.setMaskImage(image, animated: animated)
    }
    
    var maskColor: UIColor? {
        didSet {
            frameView.maskColor = maskColor
        }
    }
    
    // MARK: initialize
    init(maskColor: UIColor?) {
        self.maskColor = maskColor
        super.init(frame: .zero)
        addSubview(containerView)
        resetState()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if state == .edit {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == containerView && state == .edit {
            let framePoint = convert(point, to: frameView)
            if let view = frameView.hitTest(framePoint, with: event) {
                return view
            }
            let rectX = -superContentInset.left
            let rectY = -superContentInset.top
            let rectW = containerView.width + superContentInset.left + superContentInset.right
            let rectH = containerView.height + superContentInset.top + superContentInset.bottom
            let rect = CGRect(x: rectX, y: rectY, width: rectW, height: rectH)
            if rect.contains(convert(point, to: superview)) {
                return scrollView
            }
        }
        return view
    }
    
    // MARK: views
    lazy var containerView: ContainerView = {
        let containerView = ContainerView()
        containerView.addSubview(mirrorView)
        containerView.addSubview(frameView)
        return containerView
    }()
    
    lazy var mirrorView: UIView = {
        let view = UIView()
        view.addSubview(rotateView)
        view.addSubview(scrollView)
        return view
    }()
    
    lazy var rotateView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.addSubview(contentView)
        return scrollView
    }()
    
    lazy var contentView: EditorContentView = {
        let contentView = EditorContentView()
        contentView.delegate = self
        return contentView
    }()
    
    lazy var frameView: EditorFrameView = {
        let frameView = EditorFrameView(maskColor: maskColor)
        frameView.delegate = self
        return frameView
    }()
}

extension EditorAdjusterView {
    
    var image: UIImage? {
        get {
            contentView.image
        }
        set {
            contentView.image = newValue
        }
    }
    
    var mosaicOriginalImage: UIImage? {
        get {
            contentView.mosaicOriginalImage
        }
        set {
            contentView.mosaicOriginalImage = newValue
        }
    }
    
    func setImage(_ image: UIImage?) {
        contentView.image = image
    }
    
    func setImageData(_ imageData: Data?) {
        contentView.imageData = imageData
    }
    
    func setVideoAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        contentView.videoCover = coverImage
        contentView.avAsset = avAsset
    }
    
    func loadVideoAsset(_ completion: ((Bool) -> Void)? = nil) {
        contentView.loadAsset(completion)
    }
    func seekVideo(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        contentView.seek(to: time, comletion: comletion)
    }
    func playVideo() {
        contentView.play()
    }
    func pauseVideo() {
        contentView.pause()
    }
    func resetPlayVideo(completion: ((CMTime) -> Void)? = nil) {
        contentView.resetPlay(completion: completion)
    }
    
    func setContent(_ isEnabled: Bool = false) {
        setScrollViewEnabled(isEnabled)
        setControllContentInsets()
        setContentFrame(contentViewFrame)
        frameView.maxControlRect = .init(
            x: contentInsets.left,
            y: contentInsets.top,
            width: containerView.width - contentInsets.left - contentInsets.right,
            height: containerView.height - contentInsets.top - contentInsets.bottom
        )
    }
    
    func setControllContentInsets() {
        contentInsets = setContentInsets?() ?? .zero
    }
    
    func setScrollViewEnabled(_ isEnabled: Bool) {
        scrollView.alwaysBounceVertical = isEnabled
        scrollView.alwaysBounceHorizontal = isEnabled
        scrollView.isScrollEnabled = isEnabled
        scrollView.pinchGestureRecognizer?.isEnabled = isEnabled
    }
    
    func setContentFrame(_ frame: CGRect) {
        contentView.size = frame.size
        baseContentSize = contentView.size
        scrollView.contentSize = contentView.size
        if contentView.height < containerView.height {
            let top = (containerView.height - contentView.height) * 0.5
            let left = (containerView.width - contentView.width) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        }else {
            scrollView.contentInset = .zero
        }
    }
    
    func setFrame(_ rect: CGRect, maxRect: CGRect, contentInset: UIEdgeInsets) {
        containerView.frame = rect
        if mirrorView.size.equalTo(containerView.size) {
            return
        }
        superContentInset = contentInset
        frameView.setMaskBgFrame(.init(x: -contentInset.left, y: -contentInset.top, width: maxRect.width, height: maxRect.height), insets: contentInset)
        frameView.frame = containerView.bounds
        let insets = setContentInsets?() ?? .zero
        let anchorX: CGFloat
        if insets.left == insets.right {
            anchorX = 0.5
        }else {
            anchorX = (insets.left + (containerView.width - insets.left - insets.right) * 0.5) / containerView.width
        }
        let anchorY: CGFloat
        if insets.top == insets.bottom {
            anchorY = 0.5
        }else {
            anchorY = (insets.top + (containerView.height - insets.top - insets.bottom) * 0.5) / containerView.height
        }
        mirrorView.layer.anchorPoint = .init(x: anchorX, y: anchorY)
        mirrorView.frame = containerView.bounds
        scrollView.layer.anchorPoint = .init(x: anchorX, y: anchorY)
        scrollView.frame = mirrorView.bounds
        rotateView.layer.anchorPoint = .init(x: anchorX, y: anchorY)
        rotateView.frame = mirrorView.bounds
    }
    
    func setCustomMaskFrame(_ rect: CGRect, maxRect: CGRect, contentInset: UIEdgeInsets) {
        frameView.setCustomMaskFrame(.init(x: -contentInset.left, y: -contentInset.top, width: maxRect.width, height: maxRect.height), insets: contentInset)
    }
    
    func setScrollViewContentInset(_ rect: CGRect) {
        scrollView.contentInset = getScrollViewContentInset(rect)
    }
    
    func setScrollViewTransform(
        transform: CGAffineTransform? = nil,
        rotateTransform: CGAffineTransform? = nil,
        angle: CGFloat = 0,
        animated: Bool = false
    ) {
        var _transform: CGAffineTransform
        var rotate_Transform: CGAffineTransform
        if let transform = transform {
            _transform = transform
        }else {
            let identityTransForm = CGAffineTransform.identity
            _transform = angle == 0 ? identityTransForm : identityTransForm.rotated(by: angle.radians)
        }
        if let rotateTransform = rotateTransform {
            rotate_Transform = rotateTransform
        }else {
            let identityTransForm = CGAffineTransform.identity
            rotate_Transform = angle == 0 ? identityTransForm : identityTransForm.rotated(by: angle.radians)
        }
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.rotateView.transform = rotate_Transform
                self.scrollView.transform = _transform
            }
        }else {
            rotateView.transform = rotate_Transform
            scrollView.transform = _transform
        }
    }
    
    var isFixedRatio: Bool {
        get {
            frameView.isFixedRatio
        }
        set {
            frameView.isFixedRatio = newValue
            if newValue {
                frameView.aspectRatio = .init(width: frameView.controlView.width, height: frameView.controlView.height)
            }else {
                frameView.aspectRatio = .zero
            }
        }
    }
    
    func setAspectRatio(_ ratio: CGSize, resetRound: Bool = true, animated: Bool) {
        if resetRound {
            frameView.isRoundCrop =  false
        }
        frameView.aspectRatio = ratio
        let controlBeforeRect = getControlInContentRect()
        updateMaskAspectRatio(animated)
        scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(frameView.controlView.frame)
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: [.curveEaseOut]
            ) {
                self.setScrollViewContentInset(self.frameView.controlView.frame)
                if self.scrollView.zoomScale < self.scrollView.minimumZoomScale {
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                }
                self.adjustedScrollContentOffset(controlBeforeRect)
            }
        }else {
            setScrollViewContentInset(frameView.controlView.frame)
            if scrollView.zoomScale < scrollView.minimumZoomScale {
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
            adjustedScrollContentOffset(controlBeforeRect)
        }
    }
    
    func updateMaskAspectRatio(_ animated: Bool) {
        let aspectRatio = frameView.aspectRatio
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var maskWidth = maxWidth
        var maskHeight: CGFloat
        if aspectRatio == .zero {
            let baseSize = getInitializationRatioMaskRect().size
            maskWidth = baseSize.width
            maskHeight = baseSize.height
        }else {
            maskHeight = maxWidth / aspectRatio.width * aspectRatio.height
            if maskHeight > maxHeight {
                maskWidth = maskWidth * (maxHeight / maskHeight)
                maskHeight = maxHeight
            }
        }
        let maskRect = CGRect(
            x: contentInsets.left + (maxWidth - maskWidth) * 0.5,
            y: contentInsets.top + (maxHeight - maskHeight) * 0.5,
            width: maskWidth,
            height: maskHeight
        )
        updateMaskRect(to: maskRect, animated: animated)
    }
    
    func updateMaskRect(to rect: CGRect, animated: Bool) {
        if rect.width.isNaN || rect.height.isNaN {
            return
        }
        frameView.updateFrame(to: rect, animated: animated)
//        if state == .edit {
//            scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
//        }
    }
    
    var isRoundMask: Bool {
        get {
            frameView.isRoundCrop
        }
        set {
            frameView.isRoundCrop = newValue
        }
    }
    
    func setRoundCrop(isRound: Bool, animated: Bool) {
        frameView.setRoundCrop(isRound: isRound, animated: animated)
    }
    
    func update() {
        let controlRect = getControlInContentRect()
        let beforeZoomScale = scrollView.zoomScale / scrollView.minimumZoomScale
        let xScale = controlRect.minX / baseContentSize.width
        let yScale = controlRect.minY / baseContentSize.height
        let ratio = frameView.aspectRatio
        setContent(state == .edit)
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var maskWidth = maxWidth
        var maskHeight = maskWidth * (controlRect.height / controlRect.width)
        if maskHeight > maxHeight {
            maskWidth = maskWidth * (maxHeight / maskHeight)
            maskHeight = maxHeight
        }
        let maskRect = CGRect(
            x: contentInsets.left + (maxWidth - maskWidth) * 0.5,
            y: contentInsets.top + (maxHeight - maskHeight) * 0.5,
            width: maskWidth,
            height: maskHeight
        )
        updateMaskRect(to: maskRect, animated: true)
        
        let controlView = frameView.controlView
        setScrollViewContentInset(controlView.frame)
        let minimumZoomScale = getScrollViewMinimumZoomScale(controlView.frame)
        scrollView.minimumZoomScale = minimumZoomScale
        let zoomScale = max(minimumZoomScale, minimumZoomScale * beforeZoomScale)
        scrollView.zoomScale = zoomScale
        adjustedScrollContentOffset(controlRect)
    }
}

extension EditorAdjusterView {
    var contentScale: CGFloat {
        contentView.contentScale
    }
    var contentViewFrame: CGRect {
        let maxWidth = containerView.width
        let maxHeight = containerView.height
        let imageWidth = maxWidth
        let imageHeight = imageWidth / contentScale
        var imageX: CGFloat = 0
        var imageY: CGFloat = 0
        if imageHeight < maxHeight {
            imageY = (maxHeight - imageHeight) * 0.5
        }
        if imageWidth < maxWidth {
            imageX = (maxWidth - imageWidth) * 0.5
        }
        return CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
    }
    
    var initialZoomScale: CGFloat {
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var imageWidth = maxWidth
        var imageHeight = imageWidth / contentScale
        if imageHeight > maxHeight {
            imageHeight = maxHeight
            imageWidth = imageHeight * contentScale
        }
        
        if !isOriginalRatio {
            let maskRect = getInitializationRatioMaskRect()
            if imageHeight < maskRect.height {
                imageWidth = imageWidth * (maskRect.height / imageHeight)
            }
            if imageWidth < maskRect.width {
                imageWidth = maskRect.width
            }
        }
        let minimumZoomScale = imageWidth / baseContentSize.width
        return minimumZoomScale
    }
}

extension EditorAdjusterView {
     
    func getContentBaseFrame() -> CGRect {
        let maxWidth = containerView.width
        let maxHeight = containerView.height
        let imageWidth = maxWidth
        let imageHeight = imageWidth / contentScale
        var imageX: CGFloat = 0
        var imageY: CGFloat = 0
        if imageHeight < maxHeight {
            imageY = (maxHeight - imageHeight) * 0.5
        }
        if imageWidth < maxWidth {
            imageX = (maxWidth - imageWidth) * 0.5
        }
        return CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
    }
    
    func getControlInRotateRect(_ rect: CGRect? = nil) -> CGRect {
        let controlFrame: CGRect
        if let rect = rect {
            controlFrame = rect
        }else {
            controlFrame = frameView.controlView.frame
        }
        var _rect = frameView.convert(controlFrame, to: rotateView)
        if isRoundMask {
            _rect = .init(
                x: _rect.midX - controlFrame.width * 0.5,
                y: _rect.midY - controlFrame.height * 0.5,
                width: controlFrame.width,
                height: controlFrame.height
            )
        }
        return _rect
    }
    
    func getControlInContentRect() -> CGRect {
        let controlFrame = frameView.controlView.frame
        var rect = frameView.convert(controlFrame, to: contentView)
        if isRoundMask {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let currentTransform = scrollView.transform
            scrollView.transform = .identity
            let tmpRect = frameView.convert(controlFrame, to: contentView)
            scrollView.transform = currentTransform
            CATransaction.commit()
            rect = CGRect(
                x: rect.midX - tmpRect.width * 0.5,
                y: rect.midY - tmpRect.height * 0.5,
                width: tmpRect.width, height: tmpRect.height
            )
        }
        return rect
    }
    
    func getZoomOffset(
        _ offset: CGPoint,
        _ scrollCotentInset: UIEdgeInsets
    ) -> CGPoint {
        var offsetX = offset.x
        var offsetY = offset.y
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollCotentInset.left
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height + scrollCotentInset.bottom
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        if offsetX < -scrollCotentInset.left {
            offsetX = -scrollCotentInset.left
        }
        if offsetY > maxOffsetY {
            offsetY = maxOffsetY
        }
        if offsetY < -scrollCotentInset.top {
            offsetY = -scrollCotentInset.top
        }
        return CGPoint(x: offsetX, y: offsetY)
    }
    
    func getZoomOffset(
        fromRect: CGRect,
        zoomScale: CGFloat,
        scrollCotentInset: UIEdgeInsets
    ) -> CGPoint {
        let offsetX = fromRect.minX * zoomScale - scrollView.contentInset.left
        let offsetY = fromRect.minY * zoomScale - scrollView.contentInset.top
        return getZoomOffset(
            CGPoint(x: offsetX, y: offsetY),
            scrollCotentInset
        )
    }
    
    func getScrollViewContentInset(
        _ rect: CGRect,
        _ isBase: Bool = false
    ) -> UIEdgeInsets {
        let rotateRect: CGRect
        if isBase {
            rotateRect = rect
        }else {
            let rotate_Rect = getControlInRotateRect(rect)
            if isRoundMask {
                rotateRect = .init(x: rotate_Rect.midX - rect.width * 0.5, y: rotate_Rect.midY - rect.height * 0.5, width: rect.width, height: rect.height)
            }else {
                rotateRect = rotate_Rect
            }
        }
        let top = rotateRect.minY
        let bottom = containerView.height - rotateRect.maxY
        let left = rotateRect.minX
        let right = containerView.width - rotateRect.maxX
        return .init(top: top, left: left, bottom: bottom, right: right)
    }
    
    func getMaskRect(_ isBase: Bool = false) -> CGRect {
        if !isOriginalRatio {
            return getInitializationRatioMaskRect()
        }
        let zoomScale = scrollView.minimumZoomScale
        let maskWidth = isBase ? baseContentSize.width * zoomScale : contentView.width * zoomScale
        let maskHeight = isBase ? baseContentSize.height * zoomScale : contentView.height * zoomScale
        let maskX = (
            containerView.width - contentInsets.left - contentInsets.right - maskWidth
        ) * 0.5 + contentInsets.left
        let maskY = (
            containerView.height - contentInsets.top - contentInsets.bottom - maskHeight
        ) * 0.5 + contentInsets.top
        return CGRect(x: maskX, y: maskY, width: maskWidth, height: maskHeight)
    }
    
    func getInitializationRatioMaskRect() -> CGRect {
        let aspectRatio = frameView.aspectRatio
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var maskWidth = maxWidth
        var maskHeight: CGFloat
        if aspectRatio.equalTo(.zero) {
            maskHeight = maskWidth / contentScale
        }else {
            maskHeight = maskWidth * (aspectRatio.height / aspectRatio.width)
        }
        if maskHeight > maxHeight {
            maskWidth = maskWidth * (maxHeight / maskHeight)
            maskHeight = maxHeight
        }
        let maskX = (maxWidth - maskWidth) * 0.5 + contentInsets.left
        let maskY = (maxHeight -  maskHeight) * 0.5 + contentInsets.top
        return CGRect(x: maskX, y: maskY, width: maskWidth, height: maskHeight)
    }
    
    func getMinimuzmControlSize(rect: CGRect) -> CGSize {
        let minRect = getControlInRotateRect(rect)
        return minRect.size
    }
    
    func getScrollViewMinimumZoomScale(_ rect: CGRect) -> CGFloat {
        var minZoomScale: CGFloat
        let minSize = getMinimuzmControlSize(rect: rect)
        let rectW = minSize.width
        let rectH = minSize.height
        if rectW >= rectH {
            minZoomScale = rectW / baseContentSize.width
            let scaleHeight = baseContentSize.height * minZoomScale
            if scaleHeight < rectH {
                minZoomScale *= rectH / scaleHeight
            }
        }else {
            minZoomScale = rectH / baseContentSize.height
            let scaleWidth = baseContentSize.width * minZoomScale
            if scaleWidth < rectW {
                minZoomScale *= rectW / scaleWidth
            }
        }
        return minZoomScale
    }
    
    func getZoomScale(fromRect: CGRect, toRect: CGRect) -> CGFloat {
        var widthScale = toRect.width / fromRect.width
        let fromSize = getExactnessSize(fromRect.size)
        let toSize = getExactnessSize(toRect.size)
        /// 大小一样不需要缩放
        var isMaxZoom = fromSize.equalTo(toSize)
        if scrollView.zoomScale * widthScale > scrollView.maximumZoomScale {
            let scale = scrollView.maximumZoomScale - scrollView.zoomScale
            if scale > 0 {
                widthScale = scrollView.maximumZoomScale
            }else {
                isMaxZoom = true
            }
        }else {
            widthScale *= scrollView.zoomScale
        }
        return isMaxZoom ? scrollView.zoomScale : widthScale
    }
    
    func getExactnessSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: CGFloat(Float(String(format: "%.2f", size.width))!),
            height: CGFloat(Float(String(format: "%.2f", size.height))!)
        )
    }
}

extension EditorAdjusterView {
    func resetAll() {
        reset(false)
        oldAdjustedData = nil
        adjustedData = .init()
        if !containerView.frame.equalTo(.zero) {
            cancelEdit(false)
        }
    }
    
    func resetScrollContent() {
        scrollView.contentOffset.y = -scrollView.contentInset.top
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
    }
}

extension EditorAdjusterView {
    class ContainerView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            true
        }
    }
    class ScrollView: UIScrollView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            true
        }
    }
}

extension CGFloat {
    var angle: CGFloat {
        self * (180 / .pi)
    }
    var radians: CGFloat {
        self / 180 * .pi
    }
}
