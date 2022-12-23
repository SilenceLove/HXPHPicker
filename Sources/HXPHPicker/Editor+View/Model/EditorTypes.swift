//
//  EditorTypes.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit

public extension EditorView {
    
    struct Config {
        
    }
    
    enum State {
        case normal
        case edit
    }
    
    enum MaskType: Equatable {
        /// 毛玻璃效果
        case blurEffect(style: UIBlurEffect.Style)
        /// 自定义颜色
        case customColor(color: UIColor)
    }
}

public enum EditorContentViewType {
    case image
    case video
}

extension EditorAdjusterView {
    
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
        var rotateTransform: CGAffineTransform = .identity
        var mirrorTransform: CGAffineTransform = .identity
        var maskImage: UIImage? = nil
        var isRound: Bool = false
    }
}

extension EditorMaskView {
    
    enum `Type` {
        case frame
        case mask
        case customMask
    }
}

extension EditorControlView {
    struct Factor {
        var fixedRatio: Bool = false
        var aspectRatio: CGSize = .zero
    }
}
extension EditorView {
    enum Operate {
        case startEdit
        case finishEdit
        case cancelEdit
        case rotate(CGFloat)
        case rotateLeft
        case rotateRight
        case mirrorHorizontally
        case mirrorVertically
        case reset
        case setRoundMask(Bool)
    }
}
