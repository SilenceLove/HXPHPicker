//
//  EditorContentView.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import AVFoundation

class EditorContentView: UIView {
    
    var image: UIImage? {
        get {
            switch type {
            case .image:
                return imageView.image
            case .video:
                return videoView.coverImageView.image
            }
        }
        set {
            switch type {
            case .image:
                imageView.setImage(image)
            case .video:
                videoView.coverImageView.image = image
            }
        }
    }
    
    var imageData: Data? {
        set {
            imageView.setImageData(imageData)
        }
    }
    
    var avAsset: AVAsset? {
        set {
            videoView.avAsset? = avAsset
        }
    }

    /// 缩放比例
    var zoomScale: CGFloat = 1
    
    
    let type: EditType
    
    // MARK: initialize
    init(_ type: EditType) {
        self.type = type
        super.init(frame: .zero)
        switch type {
        case .image:
            addSubview(imageView)
            addSubview(mosaicView)
        case .video:
            addSubview(videoView)
        }
        addSubview(drawView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if editType == .image {
            imageView.frame = bounds
            mosaicView.frame = bounds
        }else {
            if videoView.superview == self {
                videoView.frame = bounds
            }
        }
        drawView.frame = bounds
        stickerView.frame = bounds
    }
    
    // MARK: SubViews
    lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var videoView: EditorVideoPlayerView = {
        let videoView = EditorVideoPlayerView()
        return videoView
    }()
    
    lazy var drawView: EditorDrawView = {
        let drawView = EditorDrawView()
        return drawView
    }()
    
    lazy var mosaicView: EditorMosaicView = {
        let mosaicView = EditorMosaicView()
        return mosaicView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorContentView {
    enum EditType {
        case image
        case video
    }
}
