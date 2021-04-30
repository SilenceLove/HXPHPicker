//
//  PhotoEditResult.swift
//  HXPHPicker
//
//  Created by Slience on 2021/4/22.
//

import UIKit

public struct PhotoEditResult {
    
    public let editedImage: UIImage
    
    public let editedData: PhotoEditData
    
    public init(editedImage: UIImage, editedData: PhotoEditData) {
        self.editedImage = editedImage
        self.editedData = editedData
    }
}

public struct PhotoEditData {
    var cropSize: CGSize = .zero
    var zoomScale: CGFloat = 0
    var contentOffset: CGPoint = .zero
    var contentInset: UIEdgeInsets = .zero
    var minimumZoomScale: CGFloat = 0
    var maximumZoomScale: CGFloat = 0
    var maskRect: CGRect = .zero
    var angle: CGFloat = 0
    var transform: CGAffineTransform = .identity
    var mirrorType: EditorImageResizerView.MirrorType = .none
}

