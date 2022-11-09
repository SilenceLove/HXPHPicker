//
//  EditorAdjusterView.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import AVFoundation

/// - EditorAdjusterView (self)
///     - containerView (容器)
///         - scrollView (滚动视图)
///             - contentView (内容视图)
///                 - imageView (图片内容)
///                 - videoView (视频内容)
///                 - drawView  (画笔绘图层)
///                 - mosaic    (马赛克图层)
///         - frameView (遮罩、控制裁剪范围)
class EditorAdjusterView: UIView {
    
    /// 裁剪框的边距
    var contentInsets: UIEdgeInsets = .zero
    
    var imageInsets: UIEdgeInsets = .init(top: 20, left: 30, bottom: 165, right: 30)
    var videoInsets: UIEdgeInsets = .init(top: 10, left: 30, bottom: 155, right: 30)
    
    // MARK: initialize
    init() {
        super.init(frame: .zero)
        addSubview(containerView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        if state == .cropping {
//            return true
//        }
        return super.point(inside: point, with: event)
    }
    
    // MARK: private
    
    /// 原始大小
    var baseContentSize: CGSize = .zero
    
    // MARK: views
    lazy var containerView: ContainerView = {
        let containerView = ContainerView()
        containerView.addSubview(scrollView)
        containerView.addSubview(frameView)
        return containerView
    }()
    
    lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 20.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.addSubview(contentView)
        return scrollView
    }
    
    lazy var contentView: EditorContentView = {
        let contentView = EditorContentView(.image)
        
        return contentView
    }()
    
    lazy var frameView: EditorFrameView = {
        let frameView = EditorFrameView()
        return frameView
    }()
}

extension EditorAdjusterView {
    
    func setImage(_ image: UIImage?) {
        contentView.image = image
        setContent()
    }
    
    func setImageData(_ imageData: Data?) {
        contentView.imageData = imageData
        setContent()
    }
    
    func setAVAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        setImage(coverImage)
        contentView.avAsset = avAsset
    }
    
    func setContent() {
        setScrollViewEnabled(false)
        setControllContentInsets()
        setContentFrame(contentViewFrame)
        frameView.maxControlRect = .init(
            x: contentInsets.left,
            y: contentInsets.top,
            width: containerView.width - contentInsets.left - contentInsets.right,
            height: containerView.height - contentInsets.top - contentInsets.bottom
        )
    }
    
    func setControllContentInsets(_ type: EditorContentView.EditType = .image) {
        var insets: UIEdgeInsets
        switch type {
        case .image:
            insets = imageInsets
            if UIDevice.isPortrait {
                insets.top += UIDevice.generalStatusBarHeight
            }
        case .video:
            insets = videoInsets
            if UIDevice.isPortrait {
                insets.top += UIDevice.topMargin
            }
        }
        insets.left += UIDevice.leftMargin
        insets.right += UIDevice.rightMargin
        insets.bottom += UIDevice.bottomMargin
        contentInsets = insets
    }
    
    func setScrollViewEnabled(_ isEnabled: Bool) {
        scrollView.alwaysBounceVertical = isEnabled
        scrollView.alwaysBounceHorizontal = isEnabled
        scrollView.isScrollEnabled = isEnabled
        scrollView.pinchGestureRecognizer?.isEnabled = isEnabled
    }
    
    func setContentFrame(_ frame: CGRect) {
        contentView.size = frame.size
        baseContentSize = contentView.size
        if contentView.height < containerView.height {
            let top = (containerView.height - contentView.height) * 0.5
            let left = (containerView.width - contentView.width) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        }
    }
}

extension EditorAdjusterView {
    func setFrame(_ rect: CGRect) {
        containerView.frame = frame
        frameView.frame = containerView.bounds
        scrollView.frame = containerView.bounds
    }
}

extension EditorAdjusterView {
    var contentScale: CGFloat {
        guard let imageSize = contentView.image?.size else {
            return 1
        }
        return imageSize.width / imageSize.height
    }
    var contentViewFrame: CGRect {
        let maxWidth = containerView.width
        let maxHeight = containerView.height
        let imageWidth = maxWidth
        let imageHeight = imageWidth / contentScale
        var imageX: CGFloat = 0
        var imageY: CGFloat = 0
        if imageHeight < maxHeight {
            imageY = (maxHeight - imageHeight) * 0.5
        }
        if imageWidth < maxWidth {
            imageX = (maxWidth - imageWidth) * 0.5
        }
        return CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
    }
}

extension EditorAdjusterView {
    class ContainerView: UIView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            true
        }
    }
    class ScrollView: UIScrollView {
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            true
        }
    }
}
