//
//  EditorAdjusterView+Edit.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorAdjusterView {
    
    func startEdit(_ animated: Bool, completion: (() -> Void)? = nil) {
        if state == .edit {
            resetState()
            frameView.isControlEnable = true
            clipsToBounds = false
            return
        }
        delegate?.editorAdjusterView(editWillAppear: self)
        state = .edit
        resetState()
        frameView.isControlEnable = true
        clipsToBounds = false
        if let oldFactor = oldFactor {
            frameView.aspectRatio = oldFactor.aspectRatio
            isFixedRatio = oldFactor.fixedRatio
        }else {
            isFixedRatio = false
        }
        let minimumZoomScale: CGFloat
        let maximumZoomScale: CGFloat
        if let oldAdjustedData = oldAdjustedData {
            adjustedData = oldAdjustedData
            minimumZoomScale = oldAdjustedData.minimumZoomScale
            maximumZoomScale = oldAdjustedData.maximumZoomScale
            frameView.showBlackMask(animated: false)
        }else {
            minimumZoomScale = initialZoomScale
            maximumZoomScale = self.maximumZoomScale
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
                    animated: animated
                )
                self.frameView.show(animated)
                self.frameView.showImageMaskView(animated)
                self.frameView.showCustomMaskView(animated)
                self.frameView.showLinesShadow()
                self.delegate?.editorAdjusterView(editDidAppear: self)
                completion?()
            }
        }else {
            setupEdit(maskRect: maskRect)
            frameView.blackMask(
                isShow: false,
                animated: animated
            )
            frameView.show(animated)
            frameView.showImageMaskView(animated)
            frameView.showCustomMaskView(animated)
            frameView.showLinesShadow()
            delegate?.editorAdjusterView(editDidAppear: self)
            completion?()
        }
    }
    
    func finishEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if state != .edit {
            return
        }
        delegate?.editorAdjusterView(editWillDisappear: self)
        endEdit()
        
        let fromSize = getExactnessSize(contentView.size)
        let toSize = getExactnessSize(frameView.controlView.size)
        
        let isEqualSize = (
            !fromSize.equalTo(toSize)
            ||
            (fromSize.equalTo(toSize) &&
             frameView.isRoundCrop
            )
        )
        oldMaskImage = adjustedData.maskImage
        oldIsRound = frameView.isRoundCrop
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
            oldData.mirrorTransform = adjustedData.mirrorTransform
            oldData.transform = scrollView.transform
            oldData.rotateTransform = rotateView.transform
            oldAdjustedData = oldData
            
            oldFactor = .init(fixedRatio: frameView.isFixedRatio, aspectRatio: frameView.aspectRatio)
        }else {
            oldAdjustedData = nil
            oldFactor = nil
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
        if maskImage == nil {
            frameView.hideCustomMaskView(animated)
        }else {
            frameView.hideImageMaskView(animated)
        }
        updateFrameView(
            maskRect: maskRect,
            zoomScale: zoomScale,
            animated: animated
        ) { [weak self] () in
            completion?()
            guard let self = self else { return }
            self.delegate?.editorAdjusterView(editDidDisappear: self)
            self.clipsToBounds = true
        }
    }
    
    func cancelEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        delegate?.editorAdjusterView(editWillDisappear: self)
        endEdit()
        if let oldFactor = oldFactor {
            isFixedRatio = oldFactor.fixedRatio
            frameView.aspectRatio = oldFactor.aspectRatio
        }
        if let oldMaskImage = oldMaskImage {
            setMaskImage(oldMaskImage, animated: animated)
        }else {
            setMaskImage(nil, animated: animated)
            frameView.hideCustomMaskView(animated)
        }
        if oldIsRound {
            setRoundCrop(isRound: true, animated: animated)
        }
        if let oldAdjustedData = oldAdjustedData {
            frameView.show(false)
            adjustedData = oldAdjustedData
            setScrollViewTransform(
                transform: oldAdjustedData.transform,
                rotateTransform: oldAdjustedData.rotateTransform,
                angle: oldAdjustedData.angle,
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
            frameView.hideImageMaskView(animated)
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
        scrollView.minimumZoomScale = 1
        let scrollViewContentInset = getScrollViewContentInset(maskRect, true)
        let offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
        updateScrollViewContent(
            contentInset: nil,
            zoomScale: 1,
            contentOffset: offset,
            animated: animated,
            resetAngle: true,
            isCancel: true
        ) { [weak self] in
            guard let self = self else { return }
            completion?()
            self.delegate?.editorAdjusterView(editDidDisappear: self)
        }
    }
}

extension EditorAdjusterView {
    var canReset: Bool {
        let isUpDirection = adjustedData.angle.truncatingRemainder(dividingBy: 360) == 0
        let isIdentityMirror = adjustedData.mirrorTransform == .identity
        if !isUpDirection || !isIdentityMirror {
            return true
        }
        if frameView.controlView.size.equalTo(.zero) {
            // 裁剪框大小还未初始化时
            return false
        }
        if isFixedRatio && !ignoreFixedRatio {
            // 开启了固定比例
            let zoomScale = initialZoomScale
            let maskViewFrame = getMaskRect(true)
            let scrollViewContentInset = getScrollViewContentInset(maskViewFrame)
            var offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
            if !isOriginalRatio {
                // 不是原始比例,需要判断中心点
                let leftMargin = baseContentSize.width * zoomScale * 0.5 - maskViewFrame.width * 0.5
                let rightMargin = baseContentSize.height * zoomScale * 0.5 - maskViewFrame.height * 0.5
                offset = CGPoint(
                    x: -scrollViewContentInset.left + leftMargin,
                    y: -scrollViewContentInset.top + rightMargin
                )
            }
            let currentOffset = scrollView.contentOffset
            // 允许0.18以内的误差
            let difference = max(
                fabsf(Float(currentOffset.x - offset.x)),
                fabsf(Float(currentOffset.y - offset.y))
            )
            let zoomScaleDifference = fabsf(Float(scrollView.zoomScale - zoomScale))
            let controlFrame = frameView.controlView.frame
            var frameIsEqual = true
            if abs(controlFrame.minX - maskViewFrame.minX) > 0.00001 {
                frameIsEqual = false
            }
            if abs(controlFrame.minY - maskViewFrame.minY) > 0.00001 {
                frameIsEqual = false
            }
            if abs(controlFrame.width - maskViewFrame.width) > 0.00001 {
                frameIsEqual = false
            }
            if abs(controlFrame.height - maskViewFrame.height) > 0.00001 {
                frameIsEqual = false
            }
            
            if zoomScaleDifference > 0.0000001 ||
                !frameIsEqual ||
                difference > 0.18 {
                /// 缩放大小不一致、裁剪框位置大小不一致、不在中心点位置、角度不为0都可以还原
                return true
            }
            return false
        }
        let fromSize = getExactnessSize(contentView.size)
        let toSize = getExactnessSize(frameView.controlView.size)
        return !fromSize.equalTo(toSize)
    }
    
    func reset(_ animated: Bool) {
        if !canReset {
            return
        }
        delegate?.editorAdjusterView(willBeginEditing: self)
        stopTimer()
        if ignoreFixedRatio {
            isFixedRatio = false
        }else {
            if !isFixedRatio {
                frameView.aspectRatio = .zero
            }
        }
        let mask_Image = adjustedData.maskImage
        adjustedData = .init()
        adjustedData.maskImage = mask_Image
        // 初始的缩放比例
        let zoomScale = initialZoomScale
        let minimumZoomScale = zoomScale
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        // 获取遮罩位置大小
        let maskViewFrame = getMaskRect(true)
        updateMaskRect(to: maskViewFrame, animated: animated)
        // 获取原始的contentInset
        let scrollViewContentInset = getScrollViewContentInset(maskViewFrame, true)
        var offset =  CGPoint(x: -scrollViewContentInset.left, y: -scrollViewContentInset.top)
        if !isOriginalRatio {
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
            self.changedMaskRectCompletion(animated)
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
        if let oldAdjustedData = oldAdjustedData {
            scrollView.contentInset = oldAdjustedData.contentInset
        }
        scrollView.zoomScale = zoomScale
        if let oldAdjustedData = oldAdjustedData {
            scrollView.contentInset = oldAdjustedData.contentInset
            scrollView.contentOffset = getZoomOffset(
                oldAdjustedData.contentOffset,
                oldAdjustedData.contentInset
            )
        }else {
            if !isOriginalRatio {
                let rect = getControlInRotateRect(maskRect)
                let offset = CGPoint(
                    x: -scrollView.contentInset.left +
                        (
                        contentView.width * 0.5 - rect.width * 0.5
                        ),
                    y: -scrollView.contentInset.top +
                        (
                        contentView.height * 0.5 - rect.height * 0.5
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
        let controlBeforeRect = getControlInContentRect()
        updateMaskRect(to: maskRect, animated: animated)
        frameView.hide(isMaskBg: false, animated: animated)
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
        frameView.blackMask(isShow: true, animated: animated)
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                animatedAction()
            } completion: { (_) in
                completion?()
//                self.frameView.blackMask(isShow: false, animated: false)
//                self.frameView.hide(isLines: false, animated: animated)
            }
        }else {
            animatedAction()
            completion?()
//            frameView.blackMask(isShow: false, animated: false)
//            frameView.hide(isLines: false, animated: animated)
        }
    }
    
    func updateScrollViewContent(
        contentInset: UIEdgeInsets?,
        zoomScale: CGFloat,
        contentOffset: CGPoint,
        animated: Bool,
        resetAngle: Bool = false,
        isCancel: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        func animatedAction() {
            if resetAngle {
                setScrollViewTransform()
                if let mirrorTransform = oldAdjustedData?.mirrorTransform, isCancel {
                    mirrorView.transform = mirrorTransform
                }else {
                    mirrorView.transform = .identity
                }
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
     
    func changedMaskRectCompletion(_ animated: Bool) {
        delegate?.editorAdjusterView(didEndEditing: self)
        if frameView.maskBgShowTimer == nil &&
            frameView.maskBgViewIsHidden {
            frameView.showMaskBgView(animated: animated)
        }
    }
}
