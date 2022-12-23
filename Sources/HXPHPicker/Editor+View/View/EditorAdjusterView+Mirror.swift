//
//  EditorAdjusterView+Mirror.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/27.
//

import UIKit

extension EditorAdjusterView {
    
    func mirrorHorizontally(animated: Bool) {
//        if rotating {
//            return
//        }
//        mirroring = true
        delegate?.editorAdjusterView(willBeginEditing: self)
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.mirrorHorizontallyHandler()
            } completion: { (_) in
                self.changedMaskRectCompletion(animated)
//                self.mirroring = false
            }
        }else {
            mirrorHorizontallyHandler()
            changedMaskRectCompletion(animated)
//            mirroring = false
        }
    }
    
    func mirrorHorizontallyHandler() {
        let transform = adjustedData.mirrorTransform
        mirrorView.transform = transform.scaledBy(x: 1, y: -1)
        adjustedData.mirrorTransform = mirrorView.transform
    }
    
    func mirrorVertically(animated: Bool) {
//        if rotating {
//            return
//        }
//        mirroring = true
        delegate?.editorAdjusterView(willBeginEditing: self)
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.mirrorVerticallyHandler()
            } completion: { (_) in
                self.changedMaskRectCompletion(animated)
//                self.mirroring = false
            }
        }else {
            mirrorVerticallyHandler()
            changedMaskRectCompletion(animated)
//            mirroring = false
        }
    }
    
    func mirrorVerticallyHandler() {
        let transform = adjustedData.mirrorTransform
        mirrorView.transform = transform.scaledBy(x: -1, y: 1)
        adjustedData.mirrorTransform = mirrorView.transform
    }
}
