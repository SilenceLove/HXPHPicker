//
//  EditorView+ScrollView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

extension EditorView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        allowZoom ? adjusterView : nil
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !allowZoom {
            return
        }
        let offsetX = (scrollView.width > scrollView.contentSize.width) ?
            (scrollView.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.height > scrollView.contentSize.height) ?
            (scrollView.height - scrollView.contentSize.height) * 0.5 : 0
        let centerX = scrollView.contentSize.width * 0.5 + offsetX
        let centerY = scrollView.contentSize.height * 0.5 + offsetY
        adjusterView.center = CGPoint(x: centerX, y: centerY)
    }
    public func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        adjusterView.zoomScale = scale
    }
}
