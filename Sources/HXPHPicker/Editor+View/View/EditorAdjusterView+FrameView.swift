//
//  EditorAdjusterView+FrameView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorAdjusterView: EditorFrameViewDelegate {
    func frameView(beganChanged frameView: EditorFrameView, _ rect: CGRect) {
        delegate?.editorAdjusterView(willBeginEditing: self)
    }
    
    func frameView(didChanged frameView: EditorFrameView, _ rect: CGRect) {
        scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
        let minSize = getMinimuzmControlSize(rect: rect)
        var changedZoomScale = false
        if minSize.height > contentView.height {
            let imageZoomScale = minSize.height / contentView.height
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
            changedZoomScale = true
        }
        if minSize.width > contentView.width {
            let imageZoomScale = minSize.width / contentView.width
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
            changedZoomScale = true
        }
        if !changedZoomScale {
            setScrollViewContentInset(rect)
        }
    }
    
    func frameView(endChanged frameView: EditorFrameView, _ rect: CGRect) {
        adjustmentViews(true)
    }
    
    func adjustmentViews(_ animated: Bool) {
        isMaskBgViewShowing = true
        /// 最大高度
        let maxHeight = containerView.height - contentInsets.top - contentInsets.bottom
        /// 裁剪框x
        var rectX = contentInsets.left
        /// 裁剪框的宽度
        var rectW = containerView.width - contentInsets.left - contentInsets.right
        let controlView = frameView.controlView
        /// 裁剪框高度
        var rectH = rectW / controlView.width * controlView.height
        if rectH > maxHeight {
            /// 裁剪框超过最大高度就进行缩放
            rectW = maxHeight / rectH *  rectW
            rectH = maxHeight
            rectX = controlView.maxImageresizerFrame.midX - rectW * 0.5
        }
        /// 裁剪框y
        let rectY = controlView.maxImageresizerFrame.midY - rectH * 0.5
        /// 裁剪框将需要更新坐标
        let rect = CGRect(x: rectX, y: rectY, width: rectW, height: rectH)
        /// 裁剪框当前的坐标
        let beforeRect = controlView.frame
        /// 裁剪框当前在imageView上的坐标
        let controlBeforeRect = getControlInContentRect()
        /// 更新裁剪框坐标
        frameView.updateFrame(to: rect, animated: animated)
        /// 裁剪框更新之后再imageView上的坐标
        let controlAfterRect = getControlInContentRect()
        let scrollCotentInset = getScrollViewContentInset(rect)
        
        let beforeRoateRect = getControlInRotateRect(beforeRect)
        let afterRoateRect = getControlInRotateRect(rect)
        /// 计算scrollView偏移量
        var offset = scrollView.contentOffset
        let offsetX = offset.x - (afterRoateRect.midX - beforeRoateRect.midX)
        let offsetY = offset.y - (afterRoateRect.midY - beforeRoateRect.midY)
        offset = getZoomOffset(
            CGPoint(x: offsetX, y: offsetY),
            scrollCotentInset
        )
        let zoomScale = getZoomScale(
            fromRect: controlBeforeRect,
            toRect: controlAfterRect
        )
        let needZoomScale = zoomScale != scrollView.zoomScale
        if animated {
            isUserInteractionEnabled = false
            let currentOffset = scrollView.contentOffset
            scrollView.setContentOffset(currentOffset, animated: false)
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.setScrollViewContentInset(rect)
                if needZoomScale {
                    /// 需要进行缩放
                    self.scrollView.zoomScale = zoomScale
                    offset = self.getZoomOffset(
                        fromRect: controlBeforeRect,
                        zoomScale: zoomScale,
                        scrollCotentInset: scrollCotentInset
                    )
                }
                self.scrollView.contentOffset = offset
            } completion: { (isFinished) in
                self.scrollView.minimumZoomScale = self.getScrollViewMinimumZoomScale(rect)
                self.frameView.showMaskBgView()
                self.isMaskBgViewShowing = false
                self.frameView.inControlTimer = false
                self.isUserInteractionEnabled = true
                self.delegate?.editorAdjusterView(didEndEditing: self)
            }
        }else {
            setScrollViewContentInset(rect)
            if needZoomScale {
                /// 需要进行缩放
                scrollView.zoomScale = zoomScale
                offset = getZoomOffset(
                    fromRect: controlBeforeRect,
                    zoomScale: zoomScale,
                    scrollCotentInset: scrollCotentInset
                )
            }
            scrollView.contentOffset = offset
            scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
            frameView.showMaskBgView(animated: false)
            isMaskBgViewShowing = false
            frameView.inControlTimer = false
            delegate?.editorAdjusterView(didEndEditing: self)
        }
    }
}
