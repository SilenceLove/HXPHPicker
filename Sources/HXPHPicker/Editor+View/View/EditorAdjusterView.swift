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
///         - scrollView (滚动视图)
///             - contentView (内容视图)
///                 - imageView/videoView (图片/视频内容)
///                 - drawView (画笔绘图层)
///                 - mosaic (马赛克图层)
///         - frameView (遮罩、控制裁剪范围)
class EditorAdjusterView: UIView {
    
    var setContentInsets: (() -> UIEdgeInsets)?
    
    var contentType: EditorContentViewType {
        contentView.type
    }
    var isVideoPlaying: Bool {
        contentView.isPlaying
    }
    
    var animateDuration: TimeInterval = 0.3
    
    var contentInsets: UIEdgeInsets = .zero
    
    var state: EditorView.State = .normal
    
    var adjustedData: AdjustedData = .init()
    var oldAdjustedData: AdjustedData?
    
    var isOriginalRatio: Bool {
        let aspectRatio = frameView.factor.aspectRatio
        if aspectRatio.equalTo(.zero) {
            return true
        }else {
            if aspectRatio.width / aspectRatio.height == contentScale {
                return true
            }
        }
        return false
    }
    
    /// 原始大小
    var baseContentSize: CGSize = .zero
    var zoomScale: CGFloat = 1 {
        didSet { contentView.zoomScale = zoomScale * scrollView.zoomScale }
    }
    var editSize: CGSize = .zero
    
    var isMaskBgViewShowing: Bool = false
    
    // MARK: initialize
    init() {
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
    
    // MARK: views
    lazy var containerView: ContainerView = {
        let containerView = ContainerView()
        containerView.addSubview(scrollView)
        containerView.addSubview(frameView)
        return containerView
    }()
    
    lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 20.0
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
        
        return contentView
    }()
    
    lazy var frameView: EditorFrameView = {
        let frameView = EditorFrameView()
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
    
    func loadVideoAsset() {
        contentView.loadAsset()
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
    
    func setContent() {
        setScrollViewEnabled(false)
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
        if contentView.height < containerView.height {
            let top = (containerView.height - contentView.height) * 0.5
            let left = (containerView.width - contentView.width) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        }else {
            scrollView.contentInset = .zero
        }
    }
    
    func setFrame(_ rect: CGRect) {
        containerView.frame = rect
        frameView.frame = containerView.bounds
        scrollView.frame = containerView.bounds
    }
    
    func setScrollViewContentInset(_ rect: CGRect) {
        scrollView.contentInset = getScrollViewContentInset(rect)
    }
    
    func setScrollViewTransform(
        transform: CGAffineTransform? = nil,
        angleInRadians: CGFloat = 0,
        animated: Bool = false
    ) {
        let scrollViewFrame = scrollView.frame
        var rotateTransform: CGAffineTransform
        if let transform = transform {
            rotateTransform = transform
        }else {
            var identityTransForm = CGAffineTransform.identity
            if adjustedData.mirrorType == .horizontal {
                identityTransForm = identityTransForm.scaledBy(x: -1, y: 1)
            }
            rotateTransform = angleInRadians == 0 ? identityTransForm : identityTransForm.rotated(by: angleInRadians)
        }
        if animated {
            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut) {
                self.scrollView.transform = rotateTransform
                self.scrollView.frame = scrollViewFrame
            }
        }else {
            scrollView.transform = rotateTransform
            scrollView.frame = scrollViewFrame
        }
    }
    
    func updateMaskRect(to rect: CGRect, animated: Bool) {
        if rect.width.isNaN || rect.height.isNaN {
            return
        }
        frameView.updateFrame(to: rect, animated: animated)
        if state == .edit {
            scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
        }
    }
}

extension EditorAdjusterView {
    var contentScale: CGFloat {
        guard let imageSize = contentView.image?.size else {
            return 1
        }
        return imageSize.width / imageSize.height
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
        var imageWidth: CGFloat
        var imageHeight: CGFloat
        
        switch getImageOrientation() {
        case .up, .down:
            imageWidth = maxWidth
            imageHeight = imageWidth / contentScale
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
        case .left, .right:
            imageHeight = maxWidth
            imageWidth = imageHeight * contentScale
            if imageWidth > maxHeight {
                imageWidth = maxHeight
                imageHeight = imageWidth / contentScale
            }
            
            if !isOriginalRatio {
                let maskRect = getInitializationRatioMaskRect()
                if imageWidth < maskRect.height {
                    imageHeight = imageHeight * (maskRect.height / imageWidth)
                }
                if imageHeight < maskRect.width {
                    imageHeight = maskRect.width
                }
                imageWidth = imageHeight * contentScale
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
    
    func getImageOrientation(_ isOld: Bool = false) -> ImageOrientation {
        let angle: CGFloat
        if let oldAdjustedData = oldAdjustedData, isOld {
            angle = oldAdjustedData.angle
        }else {
            angle = adjustedData.angle
        }
        switch angle {
        case 90, -270:
            return .right
        case 180, -180:
            return .down
        case 270, -90:
            return .left
        default:
            return .up
        }
    }
    
    func getZoomOffset(
        _ offset: CGPoint,
        _ scrollCotentInset: UIEdgeInsets
    ) -> CGPoint {
        var offsetX = offset.x
        var offsetY = offset.y
        var maxOffsetX: CGFloat
        var maxOffsetY: CGFloat
        switch getImageOrientation() {
        case .up:
            maxOffsetX = scrollView.contentSize.width - scrollView.width + scrollCotentInset.left
            maxOffsetY = scrollView.contentSize.height - scrollView.height + scrollCotentInset.bottom
        case .right:
            maxOffsetX = scrollView.contentSize.width - scrollView.height + scrollCotentInset.right
            maxOffsetY = scrollView.contentSize.height - scrollView.width + scrollCotentInset.bottom
        case .down:
            maxOffsetX = scrollView.contentSize.width - scrollView.width + scrollCotentInset.left
            maxOffsetY = scrollView.contentSize.height - scrollView.height + scrollCotentInset.bottom
        case .left:
            maxOffsetX = scrollView.contentSize.width - scrollView.height + scrollCotentInset.right
            maxOffsetY = scrollView.contentSize.height - scrollView.width + scrollCotentInset.top
        }
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
        _ isOld: Bool = false
    ) -> UIEdgeInsets {
        let mirrorType: MirrorType
        if let oldAdjustedData = oldAdjustedData, isOld {
            mirrorType = oldAdjustedData.mirrorType
        }else {
            mirrorType = adjustedData.mirrorType
        }
        switch getImageOrientation(isOld) {
        case .up:
            let top: CGFloat = rect.minY
            let bottom: CGFloat = containerView.height - rect.maxY
            var left: CGFloat
            var right: CGFloat
            if mirrorType == .horizontal {
                left = containerView.width - rect.maxX
                right = rect.minX
            }else {
                left = rect.minX
                right = containerView.width - rect.maxX
            }
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        case .left:
            var top = rect.minX
            var bottom = containerView.width - rect.maxX
            let left = containerView.height - rect.maxY
            let right = rect.minY
            if mirrorType == .horizontal {
                top = containerView.width - rect.maxX
                bottom = rect.minX
            }else {
                top = rect.minX
                bottom = containerView.width - rect.maxX
            }
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        case .down:
            let top = containerView.height - rect.maxY
            let bottom = rect.minY
            var left = containerView.width - rect.maxX
            var right = rect.minX
            if mirrorType == .horizontal {
                left = rect.minX
                right = containerView.width - rect.maxX
            }else {
                left = containerView.width - rect.maxX
                right = rect.minX
            }
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        case .right:
            var top = containerView.width - rect.maxX
            var bottom = rect.minX
            let left = rect.minY
            let right = containerView.height - rect.maxY
            if mirrorType == .horizontal {
                top = rect.minX
                bottom = containerView.width - rect.maxX
            }else {
                top = containerView.width - rect.maxX
                bottom = rect.minX
            }
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
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
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var maskWidth = maxWidth
        var maskHeight = maskWidth * (adjustedData.aspectRatio.height / adjustedData.aspectRatio.width)
        if maskHeight > maxHeight {
            maskWidth = maskWidth * (maxHeight / maskHeight)
            maskHeight = maxHeight
        }
        let maskX = (maxWidth - maskWidth) * 0.5 + contentInsets.left
        let maskY = (maxHeight -  maskHeight) * 0.5 + contentInsets.top
        return CGRect(x: maskX, y: maskY, width: maskWidth, height: maskHeight)
    }
    
    func getScrollViewMinimumZoomScale(_ rect: CGRect) -> CGFloat {
        var minZoomScale: CGFloat
        let rectW = rect.width
        let rectH = rect.height
        if rectW >= rectH {
            switch getImageOrientation() {
            case .up, .down:
                minZoomScale = rectW / baseContentSize.width
                let scaleHeight = baseContentSize.height * minZoomScale
                if scaleHeight < rectH {
                    minZoomScale *= rectH / scaleHeight
                }
            case .right, .left:
                minZoomScale = rectW / baseContentSize.height
                let scaleHeight = baseContentSize.width * minZoomScale
                if scaleHeight < rectH {
                    minZoomScale *= rectH / scaleHeight
                }
            }
        }else {
            switch getImageOrientation() {
            case .up, .down:
                minZoomScale = rectH / baseContentSize.height
                let scaleWidth = baseContentSize.width * minZoomScale
                if scaleWidth < rectW {
                    minZoomScale *= rectW / scaleWidth
                }
            case .right, .left:
                minZoomScale = rectH / baseContentSize.width
                let scaleWidth = baseContentSize.height * minZoomScale
                if scaleWidth < rectW {
                    minZoomScale *= rectW / scaleWidth
                }
            }
        }
        return minZoomScale
    }
    
    /// 获取初始缩放比例
    func getInitialZoomScale() -> CGFloat {
        let maxWidth = containerView.width - contentInsets.left - contentInsets.right
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        var imageWidth: CGFloat
        var imageHeight: CGFloat
        
        switch getImageOrientation() {
        case .up, .down:
            imageWidth = maxWidth
            imageHeight = imageWidth / contentScale
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
        case .left, .right:
            imageHeight = maxWidth
            imageWidth = imageHeight * contentScale
            if imageWidth > maxHeight {
                imageWidth = maxHeight
                imageHeight = imageWidth / contentScale
            }
            
            if !isOriginalRatio {
                let maskRect = getInitializationRatioMaskRect()
                if imageWidth < maskRect.height {
                    imageHeight = imageHeight * (maskRect.height / imageWidth)
                }
                if imageHeight < maskRect.width {
                    imageHeight = maskRect.width
                }
                imageWidth = imageHeight * contentScale
            }
        }
        let minimumZoomScale = imageWidth / baseContentSize.width
        return minimumZoomScale
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
