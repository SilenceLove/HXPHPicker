//
//  EditorContentView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit
import AVFoundation

protocol EditorContentViewDelegate: AnyObject {
    func contentView(_ contentView: EditorContentView, videoDidPlayAt time: CMTime)
    func contentView(_ contentView: EditorContentView, videoDidPauseAt time: CMTime)
    func contentView(videoReadyForDisplay contentView: EditorContentView)
}

class EditorContentView: UIView {
    
    weak var delegate: EditorContentViewDelegate?
    
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
            type = .image
            imageView.setImage(newValue)
        }
    }
    
    var contentScale: CGFloat {
        switch type {
        case .image:
            if let image = imageView.image {
                return image.width / image.height
            }
        case .video:
            if let image = videoView.coverImageView.image {
                return image.width / image.height
            }
            if !videoView.videoSize.equalTo(.zero) {
                return videoView.videoSize.width / videoView.videoSize.height
            }
        }
        return 0
    }
    
    var videoCover: UIImage? {
        get { videoView.coverImageView.image }
        set { videoView.coverImageView.image = newValue }
    }
    
    var imageData: Data? {
        get { nil }
        set {
            type = .image
            imageView.setImageData(newValue)
        }
    }
    
    var avAsset: AVAsset? {
        get { videoView.avAsset }
        set {
            type = .video
            videoView.avAsset = newValue
        }
    }
    
    var mosaicOriginalImage: UIImage? {
        get { mosaicView.originalImage }
        set { mosaicView.originalImage = newValue }
    }

    /// 缩放比例
    var zoomScale: CGFloat = 1
    
    var type: EditorContentViewType = .image {
        willSet {
            if type == .video {
                videoView.clear()
            }
        }
        didSet {
            switch type {
            case .image:
                videoView.isHidden = true
                imageView.isHidden = false
                mosaicView.isHidden = false
            case .video:
                videoView.isHidden = false
                imageView.isHidden = true
                mosaicView.isHidden = true
            }
        }
    }
    
    // MARK: initialize
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(mosaicView)
        addSubview(videoView)
        addSubview(drawView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        mosaicView.frame = bounds
        if videoView.superview == self {
            if !bounds.size.equalTo(.zero) {
                videoView.frame = bounds
            }
        }
        drawView.frame = bounds
//        stickerView.frame = bounds
    }
    
    // MARK: SubViews
    lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var videoView: EditorVideoPlayerView = {
        let videoView = EditorVideoPlayerView()
        videoView.size = UIScreen.main.bounds.size
        videoView.delegate = self
        videoView.isHidden = true
        return videoView
    }()
    
    lazy var drawView: EditorDrawView = {
        let drawView = EditorDrawView()
        return drawView
    }()
    
    lazy var mosaicView: EditorMosaicView = {
        let mosaicView = EditorMosaicView()
        mosaicView.isHidden = true
        return mosaicView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorContentView: EditorVideoPlayerViewDelegate {
    var isPlaying: Bool {
        videoView.isPlaying
    }
    
    func loadAsset(_ completion: ((Bool) -> Void)? = nil) {
        videoView.configAsset(completion)
    }
    func seek(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        videoView.seek(to: time, comletion: comletion)
    }
    func play() {
        videoView.play()
    }
    func pause() {
        videoView.pause()
    }
    func resetPlay(completion: ((CMTime) -> Void)? = nil) {
        videoView.resetPlay(completion: completion)
    }
    
    func playerView(_ playerView: EditorVideoPlayerView, didPlayAt time: CMTime) {
        delegate?.contentView(self, videoDidPlayAt: time)
    }
    
    func playerView(_ playerView: EditorVideoPlayerView, didPauseAt time: CMTime) {
        delegate?.contentView(self, videoDidPauseAt: time)
    }
    
    func playerView(_ playerViewReadyForDisplay: EditorVideoPlayerView) {
        delegate?.contentView(videoReadyForDisplay: self)
    }
}
