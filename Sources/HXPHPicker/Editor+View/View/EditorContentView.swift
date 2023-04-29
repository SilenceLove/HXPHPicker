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
    
    func contentView(drawViewBeganDraw contentView: EditorContentView)
    func contentView(drawViewEndDraw contentView: EditorContentView)
//    func contentView(_ contentView: EditorContentView, updateStickerText item: EditorStickerItem)
     
    func contentView(_ contentView: EditorContentView, stickersView: EditorStickersView, moveToCenter itemView: EditorStickersItemView) -> Bool
    func contentView(_ contentView: EditorContentView, stickerMaxScale itemSize: CGSize) -> CGFloat
    func contentView(_ contentView: EditorContentView, updateStickerText item: EditorStickerItem)
    func contentView(_ contentView: EditorContentView, stickerItemCenter stickersView: EditorStickersView) -> CGPoint?
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
            default:
                return nil
            }
        }
        set {
            type = .image
            imageView.setImage(newValue)
            setMosaicImage()
        }
    }
    
    var contentSize: CGSize {
        switch type {
        case .image:
            if let image = imageView.image {
                return image.size
            }
        case .video:
            if !videoView.videoSize.equalTo(.zero) {
                return videoView.videoSize
            }
        default:
            break
        }
        return .zero
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
        default:
            break
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
            setMosaicImage()
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
        set {
            mosaicView.originalImage = newValue
            mosaicImageQueue.cancelAllOperations()
        }
    }

    /// 缩放比例
    var zoomScale: CGFloat = 1 {
        didSet {
            drawView.scale = zoomScale
            mosaicView.scale = zoomScale
            stickerView.scale = zoomScale
        }
    }
    
    var isDrawEnabled: Bool {
        get { drawView.isEnabled }
        set {
            drawView.isEnabled = newValue
            stickerView.deselectedSticker()
        }
    }
    
    var drawLineWidth: CGFloat {
        get { drawView.lineWidth }
        set { drawView.lineWidth = newValue }
    }
    
    var drawLineColor: UIColor {
        get { drawView.lineColor }
        set { drawView.lineColor = newValue }
    }
    
    var isCanUndoDraw: Bool {
        drawView.isCanUndo
    }
    
    func undoDraw() {
        drawView.undo()
    }
    
    func undoAllDraw() {
        drawView.undoAll()
    }
    
    var isMosaicEnabled: Bool {
        get { mosaicView.isEnabled }
        set {
            mosaicView.isEnabled = newValue
            stickerView.deselectedSticker()
        }
    }
    var mosaicWidth: CGFloat {
        get { mosaicView.mosaicLineWidth }
        set { mosaicView.mosaicLineWidth = newValue }
    }
    var smearWidth: CGFloat {
        get { mosaicView.imageWidth }
        set { mosaicView.imageWidth = newValue }
    }
    var mosaicType: EditorMosaicType {
        get { mosaicView.type }
        set { mosaicView.type = newValue }
    }
    var isCanUndoMosaic: Bool {
        mosaicView.isCanUndo
    }
    func undoMosaic() {
        mosaicView.undo()
    }
    func undoAllMosaic() {
        mosaicView.undoAll()
    }
    
    var isStickerEnabled: Bool {
        get { stickerView.isEnabled }
        set { stickerView.isEnabled = newValue }
    }
    
    var isStickerShowTrash: Bool {
        get { stickerView.isShowTrash }
        set { stickerView.isShowTrash = newValue }
    }
    
    var stickerMirrorScale: CGPoint {
        get { stickerView.mirrorScale }
        set { stickerView.mirrorScale = newValue }
    }
    
    func addSticker(
        _ item: EditorStickerItem,
        isSelected: Bool = false
    ) {
        stickerView.add(sticker: item, isSelected: isSelected)
    }
    
    func deselectedSticker() {
        stickerView.deselectedSticker()
    }
    
    var mosaicImageWidth: CGFloat = 20
    
    lazy var mosaicImageQueue: OperationQueue = {
        let mosaicImageQueue = OperationQueue()
        mosaicImageQueue.maxConcurrentOperationCount = 1
        return mosaicImageQueue
    }()
    
    func setMosaicImage() {
        guard var image = image else {
            return
        }
        mosaicImageQueue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock { [unowned operation] in
            if operation.isCancelled { return }
            let minSize: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            if image.width > minSize {
                let thumbnailScale = minSize / image.width
                if let img = image
                    .scaleImage(toScale: thumbnailScale)?
                    .mosaicImage(level: self.mosaicImageWidth) {
                    image = img
                }
            }else {
                if let img = image.mosaicImage(level: self.mosaicImageWidth) {
                    image = img
                }
            }
            if operation.isCancelled { return }
            DispatchQueue.main.async {
                self.mosaicOriginalImage = image
            }
        }
        mosaicImageQueue.addOperation(operation)
    }
    
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
            default:
                break
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
        addSubview(stickerView)
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
        stickerView.frame = bounds
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
        drawView.delegate = self
        return drawView
    }()
    
    lazy var mosaicView: EditorMosaicView = {
        let mosaicView = EditorMosaicView()
        mosaicView.delegate = self
        mosaicView.isHidden = true
        return mosaicView
    }()
    
    lazy var stickerView: EditorStickersView = {
        let mosaicView = EditorStickersView()
        mosaicView.delegate = self
//        mosaicView.isHidden = true
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
    
    func playerView(readyForDisplay playerView: EditorVideoPlayerView) {
        delegate?.contentView(videoReadyForDisplay: self)
    }
}

extension EditorContentView: EditorDrawViewDelegate {
    func drawView(beganDraw drawView: EditorDrawView) {
        delegate?.contentView(drawViewBeganDraw: self)
    }
    
    func drawView(endDraw drawView: EditorDrawView) {
        delegate?.contentView(drawViewEndDraw: self)
    }
}

extension EditorContentView: EditorMosaicViewDelegate {
    func mosaicView(_  mosaicView: EditorMosaicView, splashColor atPoint: CGPoint) -> UIColor? {
        imageView.color(for: atPoint)
    }
    func mosaicView(beganDraw mosaicView: EditorMosaicView) {
        delegate?.contentView(drawViewBeganDraw: self)
    }
    func mosaicView(endDraw mosaicView: EditorMosaicView) {
        delegate?.contentView(drawViewEndDraw: self)
    }
}

extension EditorContentView: EditorStickersViewDelegate {
    func stickerView(touchBegan stickerView: EditorStickersView) {
        delegate?.contentView(drawViewBeganDraw: self)
    }
    func stickerView(touchEnded stickerView: EditorStickersView) {
        delegate?.contentView(drawViewEndDraw: self)
    }
    func stickerView(_ stickerView: EditorStickersView, moveToCenter itemView: EditorStickersItemView) -> Bool {
        delegate?.contentView(self, stickersView: stickerView, moveToCenter: itemView) ?? false
    }
    func stickerView(_ stickerView: EditorStickersView, minScale itemSize: CGSize) -> CGFloat {
        min(35 / itemSize.width, 35 / itemSize.height)
    }
    func stickerView(_ stickerView: EditorStickersView, maxScale itemSize: CGSize) -> CGFloat {
        delegate?.contentView(self, stickerMaxScale: itemSize) ?? 5
    }
    func stickerView(_ stickerView: EditorStickersView, updateStickerText item: EditorStickerItem) {
        delegate?.contentView(self, updateStickerText: item)
    }
    func stickerView(didRemoveAudio stickerView: EditorStickersView) {
        
    }
    func stickerView(itemCenter stickerView: EditorStickersView) -> CGPoint? {
        delegate?.contentView(self, stickerItemCenter: stickerView)
    }
}
