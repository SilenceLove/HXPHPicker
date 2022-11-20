//
//  EditorView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit

/// 层级结构
/// - EditorView (self)
/// - adjusterView
///     - containerView (容器)
///         - scrollView (滚动视图)
///             - contentView (内容视图)
///                 - imageView/videoView (图片/视频内容)
///                 - drawView (画笔绘图层)
///                 - mosaic (马赛克图层)
///         - frameView (遮罩、控制裁剪范围)
open class EditorView: UIScrollView {
    
    // MARK: public
    /// 当前视图状态
    public var state: State = .normal
    /// 编辑状态下的边距
    public var contentInsets: ((EditorView) -> UIEdgeInsets)?
    
    var animateDuration: TimeInterval = 0.3
    
    
    // MARK: initialize
    public init() {
        super.init(frame: .zero)
        initView()
    }
    
    open override var zoomScale: CGFloat {
        didSet {
            adjusterView.zoomScale = zoomScale
        }
    }
    
    // MARK: private
    /// 是否允许缩放
    var allowZoom: Bool = true
    /// 当前裁剪内容的大小
    var editSize: CGSize = .zero
    
    var contentScale: CGFloat {
        adjusterView.contentScale
    }
    
    // MARK: views
    lazy var adjusterView: EditorAdjusterView = {
        let adjusterView = EditorAdjusterView()
        adjusterView.setContentInsets = { [weak self] in
            guard let self = self else { return .zero }
            return self.contentInsets?(self) ?? .zero
        }
        return adjusterView
    }()
    
    // MARK: layoutViews
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required public init?(coder: NSCoder) {
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
        addSubview(adjusterView)
    }
    
    func updateContentSize() {
        let contentWidth = width
        var contentHeight: CGFloat
        if editSize.equalTo(.zero) {
            contentHeight = contentWidth / contentScale
        }else {
            contentHeight = editSize.height
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
    
    func resetZoomScale(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if state == .normal {
            allowZoom = true
        }
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: [.curveLinear]
            ) {
                if self.zoomScale != 1 {
                    self.zoomScale = 1
                }
            } completion: { _ in
                self.allowZoom = self.state == .normal
                completion?()
            }
        }else {
            if zoomScale != 1 {
                zoomScale = 1
            }
            allowZoom = state == .normal
            completion?()
        }
        setContentOffset(
            CGPoint(x: -contentInset.left, y: -contentInset.top),
            animated: false
        )
    }
    
    func resetState() {
        reset(false)
        adjusterView.oldAdjustedData = nil
        resetZoomScale(false)
    }
}


