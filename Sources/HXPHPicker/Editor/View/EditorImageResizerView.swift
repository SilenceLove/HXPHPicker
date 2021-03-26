//
//  EditorImageResizerView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/19.
//

import UIKit
extension EditorImageResizerView {
    enum State {
        case normal
        case cropping
    }
}


class EditorImageResizerView: UIScrollView {
    deinit {
        print("deinit", self)
    }
    lazy var containerView: UIView = {
        let containerView = UIView.init()
        containerView.addSubview(scrollView)
        containerView.addSubview(maskBgView)
        containerView.addSubview(maskLinesView)
        containerView.addSubview(controlView)
        return containerView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: .zero)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.addSubview(imageView)
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var maskBgView: EditorImageResizerMaskView = {
        let maskBgView = EditorImageResizerMaskView.init(isMask: true)
        maskBgView.isUserInteractionEnabled = false
        return maskBgView
    }()
    
    lazy var maskLinesView: EditorImageResizerMaskView = {
        let maskLinesView = EditorImageResizerMaskView.init(isMask: false)
        maskLinesView.isUserInteractionEnabled = false
        return maskLinesView
    }()
    lazy var controlView: EditorImageResizerControlView = {
        let controlView = EditorImageResizerControlView.init()
        controlView.delegate = self
        return controlView
    }()
    var state: State = .normal
    var baseImageSize: CGSize = .zero
    var imageScale: CGFloat = 1
    var contentInsets: UIEdgeInsets = .zero
    var controlTimer: Timer?
    var maskBgViewisShowing: Bool = false
    var inControlTimer: Bool = false
    var maskBgShowTimer: Timer?
    init() {
        super.init(frame: .zero)
        addSubview(containerView)
    }
    
    func setImage(_ image: UIImage) {
        imageScale = image.size.width / image.size.height
        imageView.image = image
        updateScrollView(1, 20)
        updateImageViewFrame(getImageViewFrame())
    }
    
    func setState(_ state: State, animated: Bool) {
        self.state = state
        stopControlTimer()
        stopShowMaskBgTimer()
        inControlTimer = false
        if state == .normal {
            maskLinesView.setupShadow(true)
            controlView.isUserInteractionEnabled = false
            contentInsets = .zero
            scrollView.minimumZoomScale = 1
            let imageFrame = getImageViewFrame()
            updateMaskViewFrame(to: imageFrame, animated: animated)
            hiddenMaskView(animated)
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                    self.scrollView.setContentOffset(.zero, animated: false)
                    self.scrollView.setZoomScale(1, animated: false)
                    self.updateScrollView()
                    self.updateImageViewFrame(imageFrame)
                    self.setImageViewContentInset()
                } completion: { (isFinished) in
                }
            }else {
                scrollView.setContentOffset(.zero, animated: false)
                scrollView.setZoomScale(1, animated: false)
                updateScrollView()
                updateImageViewFrame(imageFrame)
                setImageViewContentInset()
            }
        }else {
            controlView.isUserInteractionEnabled = true
            contentInsets = UIEdgeInsets(top: 30 + UIDevice.generalStatusBarHeight, left: 30, bottom: 80 + UIDevice.bottomMargin, right: 30)
            let imageFrame = getImageViewFrame()
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                    self.scrollView.setContentOffset(.zero, animated: false)
                    self.scrollView.setZoomScale(1, animated: false)
                    self.updateScrollView()
                    self.updateImageViewFrame(imageFrame)
                    self.setImageViewContentInset()
                } completion: { (isFinished) in
                    let maskViewFrame = self.getMaskViewFrame(for: self.imageView.frame)
                    self.updateMaskViewFrame(to: maskViewFrame, animated: false)
                    self.showMaskView(animated)
                    self.maskLinesView.setupShadow(false)
                }
            }else {
                scrollView.setContentOffset(.zero, animated: false)
                scrollView.setZoomScale(1, animated: false)
                updateScrollView()
                updateImageViewFrame(imageFrame)
                setImageViewContentInset()
                let maskViewFrame = getMaskViewFrame(for: imageFrame)
                updateMaskViewFrame(to: maskViewFrame, animated: false)
                showMaskView(animated)
                maskLinesView.setupShadow(false)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
        maskBgView.frame = bounds
        maskLinesView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK: ScrollView Action
extension EditorImageResizerView {
    func updateScrollView(_ minimumZoomScale: CGFloat = 0, _ maximumZoomScale: CGFloat = 0) {
        if state == .cropping {
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
        }else {
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = false
        }
        let contentWidth = width - contentInsets.left - contentInsets.right
        let contentHeight = height - contentInsets.top - contentInsets.bottom
        scrollView.frame = CGRect(x: contentInsets.left, y: contentInsets.top, width: contentWidth, height: contentHeight)
        if maximumZoomScale != 0 {
            scrollView.maximumZoomScale = maximumZoomScale > 1 ? maximumZoomScale : 1
        }
        if minimumZoomScale != 0 {
            scrollView.minimumZoomScale = minimumZoomScale
        }
    }
    func getScrollViewContentInset(_ rect: CGRect) -> UIEdgeInsets {
        let top: CGFloat = rect.minY - contentInsets.top
        let bottom: CGFloat = height - rect.maxY - contentInsets.bottom
        let left = rect.minX - contentInsets.left
        let right = width - rect.maxX - contentInsets.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    func updateSrollViewContentInset(_ rect: CGRect) {
        scrollView.contentInset = getScrollViewContentInset(rect)
    }
    
    /// 根据线框大小获取最小缩放比例
    /// - Parameter rect: 线框大小
    /// - Returns: 最小缩放比例
    func getScrollViewMinimumZoomScale(_ rect: CGRect) -> CGFloat {
        var minZoomScale: CGFloat
        let rectW = rect.width
        let rectH = rect.height
        if rectW >= rectH {
            minZoomScale = rectW / baseImageSize.width
            let scaleHeight = baseImageSize.height * minZoomScale
            if scaleHeight < rectH {
                minZoomScale *= rectH / scaleHeight
            }
        }else {
            minZoomScale = rectH / baseImageSize.height
            let scaleWidth = baseImageSize.width * minZoomScale
            if scaleWidth < rectW {
                minZoomScale *= rectW / scaleWidth
            }
        }
        return minZoomScale
    }
}
// MARK: ImageView Action
extension EditorImageResizerView {
    func getImageViewFrame() -> CGRect {
        let maxWidth = width - contentInsets.left - contentInsets.right
        let maxHeight = height - contentInsets.top - contentInsets.bottom
        var imageWidth = maxWidth
        var imageHeight = imageWidth / imageScale
        var rect: CGRect
        if state == .cropping {
            if imageHeight > maxHeight {
                imageHeight = maxHeight
                imageWidth = imageHeight * imageScale
            }
            rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }else {
            var imageX: CGFloat = 0
            var imageY: CGFloat = 0
            if imageHeight < maxHeight {
                imageY = (maxHeight - imageHeight) * 0.5
            }
            if imageWidth < maxWidth {
                imageX = (maxWidth - imageWidth) * 0.5
            }
            rect = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        }
        return rect
    }
    func updateImageViewFrame(_ imageFrame: CGRect) {
        imageView.frame = imageFrame
        baseImageSize = imageView.size
        if state == .cropping {
            scrollView.contentSize = imageView.size
        }else {
            if imageView.height > scrollView.height {
                scrollView.contentSize = imageView.size
            }else {
                scrollView.contentSize = scrollView.size
            }
        }
    }
    func setImageViewContentInset() {
        if state == .normal {
            scrollView.contentInset = .zero
        }else {
            let top = (scrollView.height - imageView.height) * 0.5
            let left = (scrollView.width - imageView.width) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        }
    }
}
// MARK: MaskView Action
extension EditorImageResizerView {
    /// 显示遮罩界面
    func hiddenMaskView(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                self.maskBgView.alpha = 0
                self.maskLinesView.alpha = 0
            } completion: { (isFinished) in
                self.maskBgView.isHidden = true
                self.maskLinesView.isHidden = true
            }
        }else {
            self.maskBgView.isHidden = true
            self.maskLinesView.isHidden = true
            self.maskBgView.alpha = 0
            self.maskLinesView.alpha = 0
        }
    }
    
    /// 隐藏遮罩界面
    func showMaskView(_ animated: Bool) {
        if animated {
            self.maskBgView.isHidden = false
            self.maskLinesView.isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                self.maskBgView.alpha = 1
                self.maskLinesView.alpha = 1
            } completion: { (isFinished) in
            }
        }else {
            self.maskBgView.isHidden = false
            self.maskLinesView.isHidden = false
            self.maskBgView.alpha = 1
            self.maskLinesView.alpha = 1
        }
    }
    func getMaskViewFrame(for imageFrame: CGRect) -> CGRect {
        return imageView.convert(imageFrame, to: self)
    }
    /// 更新遮罩界面位置大小
    /// - Parameters:
    ///   - rect: 指定位置
    ///   - animated: 是否需要动画效果
    func updateMaskViewFrame(to rect: CGRect, animated: Bool) {
        /// 手势控制视图
        controlView.frame = rect
        /// 手势最大范围
        let maxControlRect = scrollView.convert(scrollView.bounds, to: self)
        controlView.maxImageresizerFrame = maxControlRect
        /// 更新遮罩位置大小
        maskBgView.updateLayers(rect, animated)
        /// 更新线框位置大小
        maskLinesView.updateLayers(rect, animated)
        if state == .cropping {
            // 修改最小缩放比例
            scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
        }
    }
    func startShowMaskBgTimer() {
        maskBgShowTimer?.invalidate()
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showMaskBgView), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        maskBgShowTimer = timer
    }
    func stopShowMaskBgTimer() {
        maskBgShowTimer?.invalidate()
        maskBgShowTimer = nil
    }
    /// 显示遮罩背景
    @objc func showMaskBgView() {
        if maskBgView.alpha == 1 {
            return
        }
        maskBgView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2) {
            self.maskBgView.alpha = 1
        }
    }
    /// 隐藏遮罩背景
    func hideMaskBgView() {
        stopShowMaskBgTimer()
        if maskBgView.alpha == 0 {
            return
        }
        maskBgView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2) {
            self.maskBgView.alpha = 0
        }
    }
}
// MARK: UIScrollViewDelegate
extension EditorImageResizerView: UIScrollViewDelegate {
    func didScrollAction() {
        if state != .cropping || controlView.panning {
            return
        }
        stopControlTimer()
        if !maskBgViewisShowing {
            hideMaskBgView()
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        didScrollAction()
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        didScrollAction()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if state != .cropping || controlView.panning {
            return
        }
        if !decelerate {
            if inControlTimer {
                startControlTimer()
            }else {
                startShowMaskBgTimer()
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if state != .cropping || controlView.panning {
            return
        }
        if inControlTimer {
            startControlTimer()
        }else {
            startShowMaskBgTimer()
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if state == .cropping {
            updateSrollViewContentInset(controlView.frame)
        }else {
            let offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0.0;
            let offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0.0;
            imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY);
        }
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if state != .cropping {
            return
        }
        stopControlTimer()
        if !maskBgViewisShowing {
            hideMaskBgView()
        }
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if state != .cropping {
            return
        }
        if inControlTimer {
            startControlTimer()
        }else {
            startShowMaskBgTimer()
        }
    }
}
// MARK: EditorImageResizerControlViewDelegate
extension EditorImageResizerView: EditorImageResizerControlViewDelegate {
    
    func controlView(beganChanged controlView: EditorImageResizerControlView, _ rect: CGRect) {
        hideMaskBgView()
        stopControlTimer()
    }
    func controlView(didChanged controlView: EditorImageResizerControlView, _ rect: CGRect) {
        stopControlTimer()
        if state == .normal {
            return
        }
        maskBgView.updateLayers(rect, false)
        maskLinesView.updateLayers(rect, false)
        
        scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
        if rect.height > imageView.height {
            let imageZoomScale = rect.height / imageView.height
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
        }
        if rect.width > imageView.width {
            let imageZoomScale = rect.width / imageView.width
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
        }
        updateSrollViewContentInset(controlView.frame)
    }
    func controlView(endChanged controlView: EditorImageResizerControlView, _ rect: CGRect) {
        startControlTimer()
    }
    func startControlTimer() {
        controlTimer?.invalidate()
        let timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(controlTimerAction), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        controlTimer = timer
        inControlTimer = true
    }
    
    func stopControlTimer() {
        controlTimer?.invalidate()
        controlTimer = nil
    }
    
    @objc func controlTimerAction() {
        maskBgViewisShowing = true
        /// 显示遮罩背景
        showMaskBgView()
        /// 停止定时器
        stopControlTimer()
        /// 最大高度
        let maxHeight = height - contentInsets.top - contentInsets.bottom
        /// 裁剪框x
        var rectX = contentInsets.left
        /// 裁剪框的宽度
        var rectW = width - contentInsets.left - contentInsets.right
        /// 裁剪框高度
        var rectH = rectW / controlView.width * controlView.height
        if rectH > maxHeight {
            /// 裁剪框超过最大高度就进行缩放
            rectW = maxHeight / rectH *  rectW
            rectX = scrollView.centerX - rectW * 0.5
            rectH = maxHeight
        }
        /// 裁剪框y
        let rectY = scrollView.centerY - rectH * 0.5
        /// 裁剪框将需要更新坐标
        let rect = CGRect(x: rectX, y: rectY, width: rectW, height: rectH)
        /// 裁剪框当前的坐标
        let beforeRect = controlView.frame
        /// 裁剪框当前在imageView上的坐标
        let controlBeforeRect = maskBgView.convert(controlView.frame, to: imageView)
        /// 隐藏阴影
        maskLinesView.setupShadow(true)
        /// 更新裁剪框坐标
        updateMaskViewFrame(to: rect, animated: true)
        /// 裁剪框更新之后再imageView上的坐标
        let controlAfterRect = maskBgView.convert(controlView.frame, to: imageView)
        /// imageView需要缩放的坐标
        let zoomRect = getZoomRect(fromRect: controlBeforeRect, toRect: controlAfterRect)
        /// 计算scrollView偏移量
        let offset = scrollView.contentOffset
        var offsetX = offset.x - (rect.midX - beforeRect.midX)
        var offsetY = offset.y - (rect.midY - beforeRect.midY)
        let scrollCotentInset = getScrollViewContentInset(rect)
        let maxOffsetX = scrollView.contentSize.width - scrollView.width + scrollCotentInset.left
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        if offsetX < 0 {
            offsetX = 0
        }
        let maxOffsetY = scrollView.contentSize.height - scrollView.height + scrollCotentInset.bottom
        if offsetY > maxOffsetY {
            offsetY = maxOffsetY
        }
        if offsetY < -scrollCotentInset.top {
            offsetY = -scrollCotentInset.top
        }
        /// 是否需要缩放
        let needZoom = !zoomRect.1
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveLinear]) {
            self.updateSrollViewContentInset(rect)
            if needZoom {
                /// 需要进行缩放
                self.scrollView.zoom(to: zoomRect.0, animated: false)
            }else {
                /// 不要缩放时，只是更改偏移量即可
                self.scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
            }
        } completion: { (isFinished) in
            self.maskLinesView.setupShadow(false)
            self.maskBgViewisShowing = false
            self.inControlTimer = false
        }
    }
    func getZoomRect(fromRect: CGRect, toRect: CGRect) -> (CGRect, Bool) {
        var zoomWidth = fromRect.width
        var zoomHeight = fromRect.height
        let widthScale = toRect.width / fromRect.width
        func getExactnessSize(_ size: CGSize) -> CGSize {
            CGSize(width: CGFloat(Float(String(format: "%.2f", size.width))!), height: CGFloat(Float(String(format: "%.2f", size.height))!))
        }
        let fromSize = getExactnessSize(fromRect.size)
        let toSize = getExactnessSize(toRect.size)
        /// 大小一样也不需要缩放
        var isMaxZoom = fromSize.equalTo(toSize)
        if scrollView.zoomScale + widthScale > scrollView.maximumZoomScale {
            let scale = scrollView.maximumZoomScale - scrollView.zoomScale
            if scale > 0 {
                zoomWidth = toRect.width * scale
                zoomHeight = toRect.height * scale
            }else {
                isMaxZoom = true
            }
        }
        let toCenterX = fromRect.midX
        let toCenterY = fromRect.midY
        return (CGRect(x: toCenterX - zoomWidth * 0.5, y: toCenterY - zoomHeight * 0.5, width: zoomWidth, height: zoomHeight), isMaxZoom)
    }
    
}
