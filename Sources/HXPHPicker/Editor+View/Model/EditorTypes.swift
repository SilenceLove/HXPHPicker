//
//  EditorTypes.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

public extension EditorView {
    enum State {
        case normal
        case edit
    }
}

extension EditorAdjusterView {
    enum MirrorType: Int, Codable {
        case none
        case horizontal
    }
    
    enum ImageOrientation {
        case up
        case left
        case right
        case down
    }
    
    struct AdjustedData {
        var angle: CGFloat = 0
        var zoomScale: CGFloat = 1
        var contentOffset: CGPoint = .zero
        var contentInset: UIEdgeInsets = .zero
        var minimumZoomScale: CGFloat = 1
        var maximumZoomScale: CGFloat = 1
        var maskRect: CGRect = .zero
        var transform: CGAffineTransform = .identity
        var mirrorType: MirrorType = .none
        var aspectRatio: CGSize = .zero
        var isFixedRatio: Bool = false
    }
}

extension EditorMaskView {
    enum MaskType {
        /// 半透明黑色
        case blackColor
        /// 深色毛玻璃
        case darkBlurEffect
        /// 浅色毛玻璃
        case lightBlurEffect
    }
}

extension EditorControlView {
    struct Factor {
        var fixedRatio: Bool = false
        var aspectRatio: CGSize = .zero
    }
}

public enum EditorContentViewType {
    case image
    case video
}
