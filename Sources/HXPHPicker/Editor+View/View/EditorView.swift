//
//  EditorView.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit

/// 层级结构
/// - EditorView (self)
/// - adjusterView
///     - containerView (容器)
///         - scrollView (滚动视图)
///             - contentView (内容视图)
///                 - imageView (图片内容)
///                 - videoView (视频内容)
///                 - drawView  (画笔绘图层)
///                 - mosaic    (马赛克/涂抹)
///         - frameView (遮罩、控制裁剪范围)
open class EditorView: UIScrollView {
    
    // MARK: public
    
    
    // MARK: initialize
    open init() {
        super.init(frame: .zero)
        initView()
    }
    
    // MARK: private
    /// 是否允许缩放
    private var allowZoom: Bool = true
    /// 当前裁剪内容的大小
    var cropSize: CGSize = .zero
    
    var contentScale: CGFloat {
        adjusterView.contentScale
    }
    
    // MARK: views
    lazy var adjusterView: EditorAdjusterView = {
        let adjusterView = EditorAdjusterView()
        return adjusterView
    }()
    
    // MARK: layoutViews
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

// MARK: private
extension EditorView {
    
    private func initView() {
        delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 10.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        clipsToBounds = false
        scrollsToTop = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        addSubview(imageResizerView)
    }
    
    func updateContentSize() {
        let contentWidth = width
        var contentHeight: CGFloat
        if cropSize.equalTo(.zero) {
            contentHeight = contentWidth / contentScale
        }else {
            contentHeight = cropSize.height
        }
        let contentX: CGFloat = 0
        var contentY: CGFloat = 0
        if contentHeight < height {
            contentY = (height - contentHeight) * 0.5
            adjusterView.setFrame(CGRect(x: 0, y: -contentY, width: width, height: height))
        }else {
            adjusterView.setFrame(bounds)
        }
        contentSize = CGSize(width: contentWidth, height: contentHeight)
        adjusterView.frame = CGRect(x: contentX, y: contentY, width: contentWidth, height: contentHeight)
    }
}

extension EditorView: UIGestureRecognizerDelegate {
    
}

extension EditorView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        allowZoom ? adjusterView : nil
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !allowZoom {
            return
        }
        let offsetX = (scrollView.width > scrollView.contentSize.width) ?
            (scrollView.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.height > scrollView.contentSize.height) ?
            (scrollView.height - scrollView.contentSize.height) * 0.5 : 0
        let centerX = scrollView.contentSize.width * 0.5 + offsetX
        let centerY = scrollView.contentSize.height * 0.5 + offsetY
        adjusterView.center = CGPoint(x: centerX, y: centerY)
    }
    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
//        adjusterView.zoomScale = scale
    }
}
