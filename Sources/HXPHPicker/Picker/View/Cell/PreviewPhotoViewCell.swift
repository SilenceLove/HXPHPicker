//
//  PreviewPhotoViewCell.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/12.
//

import UIKit

class PreviewPhotoViewCell: PhotoPreviewViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollContentView = PhotoPreviewContentView.init(type: PhotoPreviewContentViewType.photo)
        initView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
