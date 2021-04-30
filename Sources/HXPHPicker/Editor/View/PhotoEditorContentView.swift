//
//  PhotoEditorContentView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/26.
//

import UIKit

protocol PhotoEditorContentViewDelegate: AnyObject {
    
}

class PhotoEditorContentView: UIView {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var image: UIImage? {
        get {
            imageView.image
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
    }
    
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
