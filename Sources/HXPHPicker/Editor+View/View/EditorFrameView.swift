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
    
    lazy var maskBgView: EditorMaskView = {
        let view = EditorMaskView(isMask: true, maskType: .darkBlurEffect)
//        view.isRoundCrop = cropConfig.isRoundCrop
        view.alpha = 0
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var maskLinesView: EditorMaskView = {
        let view = EditorMaskView(isMask: false)
//        maskLinesView.isRoundCrop = cropConfig.isRoundCrop
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(maskBgView)
        addSubview(maskLinesView)
        addSubview(controlView)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let controlPoint = convert(point, to: controlView)
        if controlView.canUserEnabled(controlPoint) != nil {
            return super.hitTest(point, with: event)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskBgView.frame = bounds
        maskLinesView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EditorFrameView {
    var isControlPanning: Bool {
        controlView.panning
    }
    var isControlEnable: Bool {
        get { controlView.isUserInteractionEnabled }
        set { controlView.isUserInteractionEnabled = newValue }
    }
    
    var factor: EditorControlView.Factor {
        get { controlView.factor }
        set { controlView.factor = newValue }
    }
    
    var maxControlRect: CGRect {
        get { controlView.maxImageresizerFrame }
        set { controlView.maxImageresizerFrame = newValue }
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
        maskLinesView.showGridlinesLayer(true)
    }
    func hideGridlinesLayer() {
        maskLinesView.showGridlinesLayer(false)
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
    
    func updateFrame(to rect: CGRect, animated: Bool) {
        if rect.width.isNaN || rect.height.isNaN {
            return
        }
        controlView.frame = rect
        maskBgView.updateLayers(rect, animated)
        maskLinesView.updateLayers(rect, animated)
    }
    
    func startShowMaskBgTimer() {
        maskBgShowTimer?.invalidate()
        maskBgShowTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.showMaskBgView()
        }
    }
    
    func hideMaskBgView() {
        stopShowMaskBgTimer()
        if maskBgView.maskViewIsHidden {
            return
        }
        maskBgView.layer.removeAllAnimations()
        maskLinesView.showGridlinesLayer(true)
        maskBgView.hideMaskView()
    }
    
    func showMaskBgView() {
        if !maskBgView.maskViewIsHidden {
            return
        }
        maskBgView.layer.removeAllAnimations()
        maskLinesView.showGridlinesLayer(false)
        maskBgView.showMaskView()
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
            self.showMaskBgView()
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
