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
    public let editedData: PhotoEditData
    
    public init(editedImage: UIImage, editedData: PhotoEditData) {
        self.editedImage = editedImage
        self.editedData = editedData
    }
}

public struct PhotoEditData {
    public var cropSize: CGSize = .zero
    public var zoomScale: CGFloat = 0
    public var contentOffset: CGPoint = .zero
    public var contentInset: UIEdgeInsets = .zero
    public var minimumZoomScale: CGFloat = 0
    public var maximumZoomScale: CGFloat = 0
    public var maskRect: CGRect = .zero
    public var angle: CGFloat = 0
    public var transform: CGAffineTransform = .identity
    public var mirrorType: EditorImageResizerView.MirrorType = .none
}

