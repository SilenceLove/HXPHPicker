//
//  PhotoEditResult.swift
//  HXPHPicker
//
//  Created by Slience on 2021/4/22.
//

import UIKit

public struct PhotoEditResult {
    
    /// 编辑后的图片
    public let editedImage: UIImage
    
    /// 编辑的状态数据
    let editedData: PhotoEditData
}

struct PhotoEditData {
    var cropSize: CGSize = .zero
    var zoomScale: CGFloat = 0
    var contentInset: UIEdgeInsets = .zero
    var offsetScale: CGPoint = .zero
    var minimumZoomScale: CGFloat = 0
    var maximumZoomScale: CGFloat = 0
    var maskRect: CGRect = .zero
    var angle: CGFloat = 0
    var transform: CGAffineTransform = .identity
    var mirrorType: EditorImageResizerView.MirrorType = .none
    var isPortrait: Bool = true
}

