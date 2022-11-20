//
//  EditorAdjusterView+ScrollView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit

extension EditorAdjusterView: UIScrollViewDelegate {
    func didScroll() {
        if state != .edit || frameView.isControlPanning {
            return
        }
        frameView.stopControlTimer()
        if !isMaskBgViewShowing {
            frameView.hideMaskBgView()
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        didScroll()
//        delegate?.imageResizerView(willBeginDragging: self)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        didScroll()
//        delegate?.imageResizerView(willBeginDragging: self)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDidEnd()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEnd()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setScrollViewContentInset(frameView.controlView.frame)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if state != .edit {
            return
        }
        frameView.stopControlTimer()
        if !isMaskBgViewShowing {
            frameView.hideMaskBgView()
        }
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if state != .edit {
            return
        }
        zoomScale = scale
        scrollDidEnd()
    }
    
    func scrollDidEnd() {
        if state != .edit || frameView.isControlPanning {
            return
        }
        if frameView.inControlTimer {
            frameView.startControlTimer()
        }else {
            frameView.startShowMaskBgTimer()
        }
    }
    
    func resetState() {
        setScrollViewEnabled(state == .edit)
    }
}
