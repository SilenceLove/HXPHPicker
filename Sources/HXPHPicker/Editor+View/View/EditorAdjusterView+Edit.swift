//
//  EditorAdjusterView+Edit.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorAdjusterView {
    
    func startEdit(_ animated: Bool, completion: (() -> Void)? = nil) {
        state = .edit
        resetState()
        frameView.isControlEnable = true
        clipsToBounds = false
        let minimumZoomScale: CGFloat
        let maximumZoomScale: CGFloat
        if let oldAdjustedData = oldAdjustedData {
            adjustedData = oldAdjustedData
            minimumZoomScale = oldAdjustedData.minimumZoomScale
            maximumZoomScale = oldAdjustedData.maximumZoomScale
            frameView.showBlackMask(animated: false)
        }else {
            minimumZoomScale = initialZoomScale
            maximumZoomScale = 20
        }
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        let maskRect = oldAdjustedData?.maskRect ?? getMaskRect()
        updateMaskRect(to: maskRect, animated: animated)
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: [.curveEaseOut]
            ) {
                self.setupEdit(maskRect: maskRect)
            } completion: { _ in
                self.frameView.blackMask(
                    isShow: false,
                    animated: true
                )
                self.frameView.show(true)
                self.frameView.showLinesShadow()
                completion?()
            }
        }else {
            setupEdit(maskRect: maskRect)
            frameView.blackMask(
                isShow: false,
                animated: true
            )
            frameView.show(true)
            frameView.showLinesShadow()
            completion?()
        }
    }
    
    func finishEdit(
        isUpdateFrameView: Bool = true,
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if state != .edit {
            return
        }
        endEdit()
        
//        oldIsFixedRatio = controlView.fixedRatio
//        oldAspectRatio = controlView.aspectRatio
        
        let fromSize = getExactnessSize(contentView.size)
        let toSize = getExactnessSize(frameView.controlView.size)
        
        let isEqualSize = (
            !fromSize.equalTo(toSize)
//            ||
//            (fromSize.equalTo(toSize) &&
//             cropConfig.isRoundCrop
//            )
        )
        if canReset || (!canReset && isEqualSize ) {
            // 调整裁剪框至中心
            adjustmentViews(false)
            var oldData = AdjustedData()
            // 记录当前数据
            oldData.zoomScale = scrollView.zoomScale
            oldData.contentOffset = scrollView.contentOffset
            oldData.contentInset = scrollView.contentInset
            oldData.minimumZoomScale = scrollView.minimumZoomScale
            oldData.maximumZoomScale = scrollView.maximumZoomScale
            oldData.maskRect = frameView.controlView.frame
            oldData.angle = adjustedData.angle
            oldData.mirrorType = adjustedData.mirrorType
            oldData.transform = scrollView.transform
            oldAdjustedData = oldData
        }else {
            oldAdjustedData = nil
//            isDidFinishedClick = true
        }
        if !isUpdateFrameView {
            return
        }
        // 计算裁剪框的位置
        let maxWidth = containerView.width
        let rectW = maxWidth
        let scale = maxWidth / frameView.controlView.width
        let rectH = frameView.controlView.height * scale
        var rectY: CGFloat = 0
        if rectH < containerView.height {
            rectY = (containerView.height - rectH) * 0.5
        }
        let maskRect = CGRect(x: 0, y: rectY, width: rectW, height: rectH)
        let zoomScale = scrollView.zoomScale * scale
        if zoomScale > scrollView.maximumZoomScale {
            scrollView.maximumZoomScale = zoomScale
        }
        // 更新
        updateFrameView(
            maskRect: maskRect,
            zoomScale: zoomScale,
            animated: animated
        ) { [weak self] () in
            completion?()
            self?.clipsToBounds = true
        }
    }
    
    func cancelEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        endEdit()
        if let oldAdjustedData = oldAdjustedData {
            frameView.show(false)
            adjustedData = oldAdjustedData
            setScrollViewTransform(
                transform: oldAdjustedData.transform,
                angleInRadians: oldAdjustedData.angle,
                animated: false
            )
            updateMaskRect(to: oldAdjustedData.maskRect, animated: false)
            scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(oldAdjustedData.maskRect)
            scrollView.contentInset = oldAdjustedData.contentInset
            scrollView.zoomScale = oldAdjustedData.zoomScale
            scrollView.contentOffset = oldAdjustedData.contentOffset
            // 计算裁剪框的位置
            let maxWidth = containerView.width
            let rectW = maxWidth
            let scale = maxWidth / frameView.controlView.width
            let rectH = oldAdjustedData.maskRect.height * scale
            var rectY: CGFloat = 0
            if rectH < containerView.height {
                rectY = (containerView.height - rectH) * 0.5
            }
            let maskRect = CGRect(x: 0, y: rectY, width: rectW, height: rectH)
            let zoomScale = scrollView.zoomScale * scale
            if zoomScale > scrollView.maximumZoomScale {
                scrollView.maximumZoomScale = zoomScale
            }
            updateFrameView(
                maskRect: maskRect,
                zoomScale: zoomScale,
                animated: animated
            ) { [weak self] in
                self?.clipsToBounds = true
            }
            return
        }
        clipsToBounds = false
        adjustedData = .init()
        
        let maskRect = getContentBaseFrame()
        updateMaskRect(to: maskRect, animated: animated)
        frameView.hide(animated: animated)
//        hiddenMaskView(cropConfig.isRoundCrop ? false : animated)
        scrollView.minimumZoomScale = 1
        let scrollViewContentInset = getScrollViewContentInset(maskRect)
        let offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
        updateScrollViewContent(
            contentInset: nil,
            zoomScale: 1,
            contentOffset: offset,
            animated: animated,
            resetAngle: true
        ) {
            completion?()
        }
    }
}

extension EditorAdjusterView {
    var canReset: Bool {
//        if currentAngle != 0 || mirrorType != .none {
//            return true
//        }
        if frameView.controlView.size.equalTo(.zero) {
            // 裁剪框大小还未初始化时
            return false
        }
//        if (isFixedRatio && cropConfig.aspectRatios.isEmpty && !cropConfig.resetToOriginal) || cropConfig.isRoundCrop {
//            // 开启了固定比例
//            let zoomScale = getInitialZoomScale()
//            let maskViewFrame = getMaskViewFrame(true)
//            let scrollViewContentInset = getScrollViewContentInset(maskViewFrame)
//            var offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
//            if !isOriginalRatio {
//                // 不是原始比例,需要判断中心点
//                let leftMargin = baseImageSize.width * zoomScale * 0.5 - maskViewFrame.width * 0.5
//                let rightMargin = baseImageSize.height * zoomScale * 0.5 - maskViewFrame.height * 0.5
//                offset = CGPoint(
//                    x: -scrollViewContentInset.left + leftMargin,
//                    y: -scrollViewContentInset.top + rightMargin
//                )
//            }
//            let currentOffset = scrollView.contentOffset
//            // 允许0.18以内的误差
//            let difference = max(
//                fabsf(Float(currentOffset.x - offset.x)),
//                fabsf(Float(currentOffset.y - offset.y))
//            )
//            let zoomScaleDifference = fabsf(Float(scrollView.zoomScale - zoomScale))
//            if zoomScaleDifference > 0.0000001 ||
//                !controlView.frame.equalTo(maskViewFrame) ||
//                difference > 0.18 {
//                /// 缩放大小不一致、裁剪框位置大小不一致、不在中心点位置、角度不为0都可以还原
//                return true
//            }
//            return false
//        }
        let fromSize = getExactnessSize(contentView.size)
        let toSize = getExactnessSize(frameView.controlView.size)
        return !fromSize.equalTo(toSize)
    }
    
    func reset(_ animated: Bool) {
        if !canReset {
            return
        }
//        delegate?.imageResizerView(willChangedMaskRect: self)
        stopTimer()
//        if (!isFixedRatio || !cropConfig.aspectRatios.isEmpty || cropConfig.resetToOriginal) && !cropConfig.isRoundCrop {
//            // 没有固定比例的时候重置需要还原原始比例
//            controlView.fixedRatio = false
//            controlView.aspectRatio = .zero
//            currentAspectRatio = .zero
//            isOriginalRatio = true
//        }
        adjustedData = .init()
        // 初始的缩放比例
        let zoomScale = getInitialZoomScale()
        let minimumZoomScale = zoomScale
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = 20
        // 获取遮罩位置大小
        let maskViewFrame = getMaskRect(true)
        updateMaskRect(to: maskViewFrame, animated: animated)
        // 获取原始的contentInset
        let scrollViewContentInset = getScrollViewContentInset(maskViewFrame)
        var offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
        if !isOriginalRatio {
            // 如果不是原始比例，说明开启了固定比例，重置时需要将移动到中心点
            offset = CGPoint(
                x: -scrollViewContentInset.left +
                    (
                        baseContentSize.width * zoomScale * 0.5 - maskViewFrame.width * 0.5
                    ),
                y: -scrollViewContentInset.top +
                    (
                        baseContentSize.height * zoomScale * 0.5 - maskViewFrame.height * 0.5
                    )
            )
        }
        updateScrollViewContent(
            contentInset: scrollViewContentInset,
            zoomScale: zoomScale,
            contentOffset: offset,
            animated: animated,
            resetAngle: true
        ) { [weak self] in
            guard let self = self else { return }
//            self.delegate?.imageResizerView(didEndChangedMaskRect: self)
            if self.frameView.maskBgShowTimer == nil &&
                self.frameView.maskBgView.alpha == 0 {
                self.frameView.showMaskBgView()
            }
        }
    }
}

extension EditorAdjusterView {
    
    func endEdit() {
        state = .normal
        resetState()
        frameView.hideLinesShadow()
        frameView.hideGridlinesLayer()
        frameView.isControlEnable = false
    }
    
    func setupEdit(maskRect: CGRect) {
        let zoomScale = oldAdjustedData?.zoomScale ?? initialZoomScale
        if let oldAdjustedData = self.oldAdjustedData {
            self.scrollView.contentInset = oldAdjustedData.contentInset
        }
        self.scrollView.zoomScale = zoomScale
        if let oldAdjustedData = self.oldAdjustedData {
            self.scrollView.contentInset = oldAdjustedData.contentInset
            self.scrollView.contentOffset = self.getZoomOffset(
                oldAdjustedData.contentOffset,
                oldAdjustedData.contentInset
            )
        }else {
            if !self.isOriginalRatio {
                let offset = CGPoint(
                    x: -self.scrollView.contentInset.left +
                        (
                        self.contentView.width * 0.5 - maskRect.width * 0.5
                        ),
                    y: -self.scrollView.contentInset.top +
                        (
                        self.contentView.height * 0.5 - maskRect.height * 0.5
                        )
                )
                self.scrollView.contentOffset = offset
            }
        }
    }
    
    func updateFrameView(
        maskRect: CGRect,
        zoomScale: CGFloat,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        editSize = maskRect.size
        let controlBeforeRect = frameView.convert(frameView.controlView.frame, to: contentView)
        updateMaskRect(to: maskRect, animated: animated)
        frameView.hide(isMaskBg: false, animated: animated)
        frameView.blackMask(isShow: true, animated: false)
        let scrollCotentInset = getScrollViewContentInset(maskRect)
        func animatedAction() {
            setScrollViewContentInset(maskRect)
            scrollView.zoomScale = zoomScale
            scrollView.contentOffset = getZoomOffset(
                fromRect: controlBeforeRect,
                zoomScale: zoomScale,
                scrollCotentInset: scrollCotentInset
            )
        }
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                animatedAction()
            } completion: { (_) in
                completion?()
                self.frameView.blackMask(isShow: false, animated: false)
                self.frameView.hide(isLines: false, animated: animated)
            }
        }else {
            animatedAction()
            completion?()
            frameView.blackMask(isShow: false, animated: false)
            frameView.hide(isLines: false, animated: animated)
        }
    }
    
    func updateScrollViewContent(
        contentInset: UIEdgeInsets?,
        zoomScale: CGFloat,
        contentOffset: CGPoint,
        animated: Bool,
        resetAngle: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        func animatedAction() {
            if resetAngle {
                setScrollViewTransform()
            }
            if let contentInset = contentInset {
                scrollView.contentInset = contentInset
            }
            scrollView.zoomScale = zoomScale
            scrollView.contentOffset = contentOffset
        }
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                animatedAction()
            } completion: { (isFinished) in
                completion?()
            }
        }else {
            animatedAction()
            completion?()
        }
    }
    
    func stopTimer() {
        // 停止定时器
        frameView.stopTimer()
        // 停止滑动
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
}
