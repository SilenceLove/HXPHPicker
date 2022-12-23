//
//  EditorFrameView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit

protocol EditorFrameViewDelegate: AnyObject {
    func frameView(beganChanged frameView: EditorFrameView, _ rect: CGRect)
    func frameView(didChanged frameView: EditorFrameView, _ rect: CGRect)
    func frameView(endChanged frameView: EditorFrameView, _ rect: CGRect)
}

class EditorFrameView: UIView {
    weak var delegate: EditorFrameViewDelegate?
    
    var animateDuration: TimeInterval = 0.3
    var maskBgShowTimer: Timer?
    var controlTimer: Timer?
    var inControlTimer: Bool = false
    
    
    var maskType: EditorView.MaskType {
        get {
            maskBgView.maskType
        }
        set {
            setMaskType(newValue, animated: false)
        }
    }
    func setMaskType(_ maskType: EditorView.MaskType, animated: Bool) {
        maskBgView.setMaskType(maskType, animated: animated)
        customMaskView.setMaskType(maskType, animated: animated)
    }
    
    var maskImage: UIImage? {
        get {
            customMaskView.maskImage
        }
        set {
            setMaskImage(newValue, animated: false)
        }
    }
    
    func setMaskImage(_ image: UIImage?, animated: Bool) {
        let maskImage = image?.convertBlackImage()
        customMaskView.setMaskImage(maskImage, animated: animated)
        setRoundCrop(isRound: false, animated: animated)
    }
    
    lazy var maskBgView: EditorMaskView = {
        let view = EditorMaskView(type: .mask, maskColor: maskColor)
        view.alpha = 0
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var customMaskView: EditorMaskView = {
        let view = EditorMaskView(type: .customMask, maskColor: maskColor)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var maskLinesView: EditorMaskView = {
        let view = EditorMaskView(type: .frame)
        view.isUserInteractionEnabled = false
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    
    lazy var controlView: EditorControlView = {
        let view = EditorControlView()
        view.delegate = self
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var maskColor: UIColor? {
        didSet {
            maskBgView.maskColor = maskColor
            customMaskView.maskColor = maskColor
        }
    }
    
    init(maskColor: UIColor?) {
        self.maskColor = maskColor
        super.init(frame: .zero)
        addSubview(maskBgView)
        addSubview(customMaskView)
        addSubview(maskLinesView)
        addSubview(controlView)
    }
    
    func setMaskBgFrame(_ rect: CGRect, insets: UIEdgeInsets) {
        maskBgView.maskInsets = insets
        maskBgView.frame = rect
        
        setCustomMaskFrame(rect, insets: insets)
    }
    
    func setCustomMaskFrame(_ rect: CGRect, insets: UIEdgeInsets) {
        customMaskView.maskInsets = insets
        customMaskView.frame = rect
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        let controlPoint = convert(point, to: controlView)
        if let cView = controlView.canUserEnabled(controlPoint) {
            if let view = view {
                return view
            }
            return cView
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLinesView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EditorFrameView {
    
    var isFixedRatio: Bool {
        get {
            controlView.factor.fixedRatio
        }
        set {
            controlView.factor.fixedRatio = newValue
        }
    }
    var aspectRatio: CGSize {
        get {
            controlView.factor.aspectRatio
        }
        set {
            controlView.factor.aspectRatio = newValue
        }
    }
    
    var isControlPanning: Bool {
        controlView.panning
    }
    var isControlEnable: Bool {
        get { controlView.isUserInteractionEnabled }
        set { controlView.isUserInteractionEnabled = newValue }
    }
    
    var maxControlRect: CGRect {
        get { controlView.maxImageresizerFrame }
        set { controlView.maxImageresizerFrame = newValue }
    }
    
    var isHide: Bool {
        maskBgView.isHidden
    }
    
    func show(_ animated: Bool) {
        if animated {
            maskBgView.isHidden = false
            maskLinesView.isHidden = false
            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut) {
                self.maskBgView.alpha = 1
                self.maskLinesView.alpha = 1
            }
        }else {
            maskBgView.isHidden = false
            maskLinesView.isHidden = false
            maskBgView.alpha = 1
            maskLinesView.alpha = 1
        }
    }
    
    func hide(isLines: Bool = true, isMaskBg: Bool = true, animated: Bool) {
        if animated {
            UIView.animate(
                withDuration: animateDuration,
                delay: 0,
                options: .curveEaseOut
            ) {
                if isLines {
                    self.maskLinesView.alpha = 0
                }
                if isMaskBg {
                    self.maskBgView.alpha = 0
                }
            } completion: { (isFinished) in
                if isLines {
                    self.maskLinesView.isHidden = true
                }
                if isMaskBg {
                    self.maskBgView.isHidden = true
                }
            }
        }else {
            if isLines {
                maskLinesView.isHidden = true
                maskLinesView.alpha = 0
            }
            if isMaskBg {
                maskBgView.isHidden = true
                maskBgView.alpha = 0
            }
        }
    }
    
    func showLinesShadow() {
        maskLinesView.showShadow(true)
    }
    func hideLinesShadow() {
        maskLinesView.showShadow(false)
    }
    func showGridlinesLayer() {
        maskLinesView.showGridlinesLayer(true, animated: true)
    }
    func hideGridlinesLayer() {
        maskLinesView.showGridlinesLayer(false, animated: true)
    }
    
    func showBlackMask(animated: Bool = true, completion: (() -> Void)? = nil) {
        maskBgView.alpha = 1
        maskBgView.isHidden = false
        blackMask(
            isShow: true,
            animated: animated,
            completion: completion
        )
    }
    
    func blackMask(
        isShow: Bool,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        maskBgView.updateBlackMask(
            isShow: isShow,
            animated: animated,
            completion: completion
        )
    }
    
    func showImageMaskView(_ animated: Bool) {
        customMaskView.showImageMaskView(animated)
    }
    
    func hideImageMaskView(_ animated: Bool) {
        customMaskView.hideImageMaskView(animated)
    }
    
    func showCustomMaskView(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut) {
                self.customMaskView.alpha = 1
            }
        }else {
            customMaskView.alpha = 1
        }
    }
    
    func hideCustomMaskView(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: animateDuration, delay: 0, options: .curveEaseOut) {
                self.customMaskView.alpha = 0
            }
        }else {
            customMaskView.alpha = 0
        }
    }
    
    func updateFrame(to rect: CGRect, animated: Bool) {
        if rect.width.isNaN || rect.height.isNaN {
            return
        }
        controlView.frame = rect
        maskBgView.updateLayers(rect, animated)
        customMaskView.updateLayers(rect, animated)
        maskLinesView.updateLayers(rect, animated)
    }
    
    var isRoundCrop: Bool {
        get {
            maskBgView.isRoundCrop
        }
        set {
            maskBgView.isRoundCrop = newValue
            maskLinesView.isRoundCrop = newValue
        }
    }
    
    func setRoundCrop(isRound: Bool, animated: Bool) {
        maskBgView.updateRoundCrop(isRound: isRound, animated: animated)
        maskLinesView.updateRoundCrop(isRound: isRound, animated: animated)
    }
    
    func startShowMaskBgTimer() {
        maskBgShowTimer?.invalidate()
        maskBgShowTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.showMaskBgView()
        }
    }
    
    var maskBgViewIsHidden: Bool {
        maskBgView.maskViewIsHidden
    }
    
    func hideMaskBgView(animated: Bool = true) {
        stopShowMaskBgTimer()
        if maskBgView.maskViewIsHidden {
            return
        }
        maskBgView.layer.removeAllAnimations()
        maskBgView.hideMaskView(animated)
        if maskImage != nil {
            customMaskView.layer.removeAllAnimations()
            customMaskView.hideMaskView(animated)
        }else {
            maskLinesView.showGridlinesLayer(true, animated: animated)
        }
        
    }
    
    func showMaskBgView(animated: Bool = true) {
        if !maskBgView.maskViewIsHidden {
            return
        }
        maskBgView.layer.removeAllAnimations()
        maskBgView.showMaskView(animated)
        if maskImage != nil {
            customMaskView.layer.removeAllAnimations()
            customMaskView.showMaskView(animated)
        }else {
            maskLinesView.showGridlinesLayer(false, animated: animated)
        }
    }
    
    func stopShowMaskBgTimer() {
        maskBgShowTimer?.invalidate()
        maskBgShowTimer = nil
    }
    
    func stopControlTimer() {
        controlTimer?.invalidate()
        controlTimer = nil
    }
    
    func startControlTimer() {
        controlTimer?.invalidate()
        controlTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            /// 显示遮罩背景
//            self.showMaskBgView()
            /// 停止定时器
            self.stopControlTimer()
            self.delegate?.frameView(endChanged: self, self.controlView.frame)
        }
        inControlTimer = true
    }
    
    func stopTimer() {
        stopControlTimer()
        stopShowMaskBgTimer()
        inControlTimer = false
    }
}
