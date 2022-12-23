//
//  EditorView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit

public protocol EditorViewDelegate: AnyObject {
    /// 编辑状态发生改变
    func editorView(willBeginEditing editorView: EditorView)
    /// 编辑状态改变结束
    func editorView(didEndEditing editorView: EditorView)
    /// 即将进入编辑状态
    func editorView(editWillAppear editorView: EditorView)
    /// 已经进入编辑状态
    func editorView(editDidAppear editorView: EditorView)
    /// 即将结束编辑状态
    func editorView(editWillDisappear editorView: EditorView)
    /// 已经结束编辑状态
    func editorView(editDidDisappear editorView: EditorView)
    /// 画笔/涂鸦/贴图发生改变
    func editorView(contentViewBeganDrag editorView: EditorView)
    /// 画笔/涂鸦/贴图结束改变
    func editorView(contentViewEndDraw editorView: EditorView)
    /// 点击的文字贴纸
//    func editorView(_ editorView: EditorView, didSelectedStickerText item: EditorStickerItem)
    /// 移除了音乐贴纸
    func editorView(didRemoveAudio editorView: EditorView)
}

/// 层级结构
/// - EditorView (self)
/// - adjusterView
///     - containerView (容器)
///         - mirrorView (镜像处理)
///             - rotateView (旋转处理)
///             - scrollView (滚动视图)
///                 - contentView (内容视图)
///                     - imageView/videoView (图片/视频内容)
///                     - drawView (画笔绘图层)
///                     - mosaic (马赛克图层)
///         - frameView (遮罩、控制裁剪范围)
open class EditorView: UIScrollView {
    
    // MARK: public
    public weak var editDelegate: EditorViewDelegate?
    
    /// 内容边距（进入/退出 编辑状态不会有 缩小/放大 动画）
    /// 每次设置都会重置编辑内容
    open override var contentInset: UIEdgeInsets {
        didSet {
            resetState()
            setContent()
        }
    }
    
    /// 编辑状态下的边距（进入/退出 编辑状态会有 缩小/放大 动画）
    /// 每次设置都会重置编辑内容 
    public var editContentInset: ((EditorView) -> UIEdgeInsets)? {
        didSet {
            resetState()
            setContent()
        }
    }
    
    /// 遮罩颜色，必须与父视图的背景一致
    public var maskColor: UIColor = .black {
        didSet {
            if maskColor != .clear {
                adjusterView.maskColor = maskColor
            }
        }
    }
    
    open override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor, backgroundColor != .clear {
                maskColor = backgroundColor
            }
        }
    }
    
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
    var allowZoom: Bool = true
    var editSize: CGSize = .zero
    var editState: State = .normal
    var contentScale: CGFloat {
        adjusterView.contentScale
    }
    var animateDuration: TimeInterval = 0.3
    var layoutContent: Bool = true
    var reloadContent: Bool = false
    var operates: [Operate] = []
    
    // MARK: views
    lazy var adjusterView: EditorAdjusterView = {
        let adjusterView = EditorAdjusterView(maskColor: maskColor)
        adjusterView.delegate = self
        adjusterView.setContentInsets = { [weak self] in
            guard let self = self else { return .zero }
            return self.editContentInset?(self) ?? .zero
        }
        return adjusterView
    }()
    
    // MARK: layoutViews
    open override func layoutSubviews() {
        super.layoutSubviews()
        if layoutContent {
            if contentScale == 0 {
                reloadContent = true
                layoutContent = false
                return
            }
            setContent()
            if !operates.isEmpty {
                adjusterView.layoutIfNeeded()
            }
            operatesHandler()
            layoutContent = false
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update() {
        updateContentSize()
        adjusterView.update()
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
        let viewWidth = width - contentInset.left - contentInset.right
        let viewHeight = height - contentInset.top - contentInset.bottom
        let contentWidth = viewWidth
        var contentHeight: CGFloat
        if editSize.equalTo(.zero) {
            contentHeight = contentWidth / contentScale
        }else {
            contentHeight = editSize.height
        }
        let contentX: CGFloat = 0
        var contentY: CGFloat = 0
        if contentHeight < viewHeight {
            contentY = (viewHeight - contentHeight) * 0.5
            adjusterView.setFrame(CGRect(x: 0, y: -contentY, width: viewWidth, height: viewHeight), maxRect: bounds, contentInset: contentInset)
        }else {
            adjusterView.setFrame(.init(x: 0, y: 0, width: viewWidth, height: viewHeight), maxRect: bounds, contentInset: contentInset)
        }
        contentSize = CGSize(width: contentWidth, height: contentHeight)
        adjusterView.frame = CGRect(x: contentX, y: contentY, width: contentWidth, height: contentHeight)
    }
    
    func setCustomMaskFrame(_ isReset: Bool) {
        let viewWidth = width - contentInset.left - contentInset.right
        let viewHeight = height - contentInset.top - contentInset.bottom
        let contentWidth = viewWidth
        var contentHeight: CGFloat
        if editSize.equalTo(.zero) {
            contentHeight = contentWidth / contentScale
        }else {
            contentHeight = editSize.height
        }
        var contentY: CGFloat = 0
        if contentHeight < viewHeight {
            contentY = (viewHeight - contentHeight) * 0.5
            adjusterView.setCustomMaskFrame(CGRect(x: 0, y: -contentY, width: viewWidth, height: viewHeight), maxRect: bounds, contentInset: contentInset)
        }else {
            if !isReset {
                adjusterView.setCustomMaskFrame(.init(x: 0, y: 0, width: viewWidth, height: contentHeight), maxRect: .init(x: 0, y: 0, width: width, height: contentHeight), contentInset: contentInset)
            }else {
                adjusterView.setCustomMaskFrame(.init(x: 0, y: 0, width: viewWidth, height: viewHeight), maxRect: bounds, contentInset: contentInset)
            }
        }
    }
    
    func setContent() {
        if size.equalTo(.zero) || contentScale == 0 {
            layoutContent = true
            return
        }
        layoutContent = false
        updateContentSize()
        adjusterView.setContent()
        resetEdit()
        
        if !operates.isEmpty {
            operatesHandler()
        }
    }
    
    func resetZoomScale(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .normal {
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
                self.allowZoom = self.editState == .normal
                completion?()
            }
        }else {
            if zoomScale != 1 {
                zoomScale = 1
            }
            allowZoom = editState == .normal
            completion?()
        }
        setContentOffset(
            CGPoint(x: -contentInset.left, y: -contentInset.top),
            animated: false
        )
    }
    
    func resetState() {
        if maskImage != nil {
            maskImage = nil
        }
        editSize = .zero
        adjusterView.state = .edit
        adjusterView.resetAll()
        if editState == .normal {
            adjusterView.state = .normal
            resetZoomScale(false)
        }
    }
    
    func resetEdit() {
        if editState == .edit {
            adjusterView.startEdit(false)
            if adjusterView.isRoundMask {
                isFixedRatio = true
                adjusterView.setAspectRatio(.init(width: 1, height: 1), resetRound: false, animated: false)
            }
        }else {
            adjusterView.resetScrollContent()
        }
    }
    
    func operatesHandler() {
        for operate in operates {
            switch operate {
            case .startEdit:
                startEdit(false)
            case .finishEdit:
                finishEdit(false)
            case .cancelEdit:
                cancelEdit(false)
            case .rotate(let angle):
                rotate(angle, animated: false)
            case .rotateLeft:
                rotateLeft(false)
            case .rotateRight:
                rotateRight(false)
            case .mirrorHorizontally:
                mirrorHorizontally(false)
            case .mirrorVertically:
                mirrorVertically(false)
            case .reset:
                reset(false)
            case .setRoundMask(let isRound):
                setRoundMask(isRound, animated: false)
            }
        }
        operates.removeAll()
    }
}


