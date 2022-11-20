//
//  EditorAdjusterView+FrameView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorAdjusterView: EditorFrameViewDelegate {
    func frameView(beganChanged frameView: EditorFrameView, _ rect: CGRect) {
        
    }
    
    func frameView(didChanged frameView: EditorFrameView, _ rect: CGRect) {
        scrollView.minimumZoomScale = getScrollViewMinimumZoomScale(rect)
        var imageViewHeight: CGFloat
        var imageViewWidth: CGFloat
        switch getImageOrientation() {
        case .up, .down:
            imageViewWidth = contentView.width
            imageViewHeight = contentView.height
        case .left, .right:
            imageViewWidth = contentView.height
            imageViewHeight = contentView.width
        }
        var changedZoomScale = false
        if rect.height > imageViewHeight {
            let imageZoomScale = rect.height / imageViewHeight
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
            changedZoomScale = true
        }
        if rect.width > imageViewWidth {
            let imageZoomScale = rect.width / imageViewWidth
            let zoomScale = scrollView.zoomScale
            scrollView.setZoomScale(zoomScale * imageZoomScale, animated: false)
            changedZoomScale = true
        }
        if !changedZoomScale {
            setScrollViewContentInset(frameView.controlView.frame)
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
        let controlBeforeRect = frameView.convert(controlView.frame, to: contentView)
        /// 更新裁剪框坐标
        frameView.updateFrame(to: rect, animated: animated)
        /// 裁剪框更新之后再imageView上的坐标
        let controlAfterRect = frameView.convert(controlView.frame, to: contentView)
        let scrollCotentInset = getScrollViewContentInset(rect)
        /// 计算scrollView偏移量
        var offset = scrollView.contentOffset
        var offsetX: CGFloat
        var offsetY: CGFloat
        switch getImageOrientation() {
        case .up:
            if adjustedData.mirrorType == .horizontal {
                offsetX = offset.x + (rect.midX - beforeRect.midX)
            }else {
                offsetX = offset.x - (rect.midX - beforeRect.midX)
            }
            offsetY = offset.y - (rect.midY - beforeRect.midY)
        case .left:
            offsetX = offset.x + (rect.midY - beforeRect.midY)
            if adjustedData.mirrorType == .horizontal {
                offsetY = offset.y + (rect.midX - beforeRect.midX)
            }else {
                offsetY = offset.y - (rect.midX - beforeRect.midX)
            }
        case .down:
            if adjustedData.mirrorType == .horizontal {
                offsetX = offset.x - (rect.midX - beforeRect.midX)
            }else {
                offsetX = offset.x + (rect.midX - beforeRect.midX)
            }
            offsetY = offset.y + (rect.midY - beforeRect.midY)
        case .right:
            offsetX = offset.x - (rect.midY - beforeRect.midY)
            if adjustedData.mirrorType == .horizontal {
                offsetY = offset.y - (rect.midX - beforeRect.midX)
            }else {
                offsetY = offset.y + (rect.midX - beforeRect.midX)
            }
        }
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
                options: [.curveEaseOut]
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
                self.isMaskBgViewShowing = false
                self.frameView.inControlTimer = false
                self.isUserInteractionEnabled = true
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
            isMaskBgViewShowing = false
            frameView.inControlTimer = false
        }
    }
}
