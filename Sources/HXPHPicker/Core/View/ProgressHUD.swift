//
//  ProgressHUD.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import UIKit

extension ProgressHUD {
    enum Mode {
        case indicator
        case image
        case success
    }
}
class ProgressHUD: UIView {
    var mode : Mode
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView.init()
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.masksToBounds = true
        backgroundView.alpha = 0
        backgroundView.addSubview(blurEffectView)
        return backgroundView
    }()
    
    lazy var contentView: UIView = {
        let contentView = UIView.init()
        return contentView
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect.init(style: .dark)
        let blurEffectView = UIVisualEffectView.init(effect: effect)
        return blurEffectView
    }()
    
    lazy var indicatorView : ProgressCircleView = {
        let indicatorView = ProgressCircleView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
//        let indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
//        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    lazy var textLb: UILabel = {
        let textLb = UILabel.init()
        textLb.textColor = .white
        textLb.textAlignment = .center
        textLb.font = UIFont.systemFont(ofSize: 16)
        textLb.numberOfLines = 0;
        return textLb
    }()
    
    lazy var imageView: ProgressImageView = {
        let imageView = ProgressImageView.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        return imageView
    }()
    
    lazy var tickView: ProgressImageView = {
        let tickView = ProgressImageView.init(tickFrame: CGRect(x: 0, y: 0, width: 80, height: 80))
        return tickView
    }()
    
    var text : String?
    var finished : Bool = false
    var showDelayTimer : Timer?
    var hideDelayTimer : Timer?
    
    init(addedTo view: UIView, mode: Mode) {
        self.mode = mode
        super.init(frame: view.bounds)
        initView()
    }
    func initView() {
        addSubview(backgroundView)
        contentView.addSubview(textLb)
        if mode == .indicator {
            contentView.addSubview(indicatorView)
        }else if mode == .image {
            contentView.addSubview(imageView)
        }else if mode == .success {
            contentView.addSubview(tickView)
        }
        backgroundView.addSubview(contentView)
        
    }
    
    private func showHUD(text: String?, animated: Bool, afterDelay: TimeInterval) {
        self.text = text
        textLb.text = text
        updateFrame()
        if afterDelay > 0 {
            let timer = Timer.init(timeInterval: afterDelay, target: self, selector: #selector(handleShowTimer(timer:)), userInfo: animated, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            self.showDelayTimer = timer
        }else {
            showViews(animated: animated)
        }
    }
    @objc func handleShowTimer(timer: Timer) {
        showViews(animated: (timer.userInfo != nil))
    }
    private func showViews(animated: Bool) {
        if finished {
            return
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 1
            }
        }else {
            self.backgroundView.alpha = 1
        }
    }
    func hide(withAnimated animated: Bool, afterDelay: TimeInterval) {
        finished = true
        self.showDelayTimer?.invalidate()
        if afterDelay > 0 {
            let timer = Timer.init(timeInterval: afterDelay, target: self, selector: #selector(handleHideTimer(timer:)), userInfo: animated, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            self.hideDelayTimer = timer
        }else {
            hideViews(animated: animated)
        }
    }
    @objc func handleHideTimer(timer: Timer) {
        hideViews(animated: (timer.userInfo != nil))
    }
    func hideViews(animated: Bool) {
        indicatorView.stopAnimating()
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.backgroundView.alpha = 0
            } completion: { (finished) in
                self.removeFromSuperview()
            }
        }else {
            self.backgroundView.alpha = 0
            removeFromSuperview()
        }
    }
    func updateText(text: String) {
        self.text = text
        textLb.text = text
        updateFrame()
    }
    private func updateFrame() {
        if text != nil {
            var textWidth = text!.width(ofFont: textLb.font, maxHeight: 15)
            if textWidth < 60 {
                textWidth = 60
            }
            if textWidth > width - 100 {
                textWidth = width - 100
            }
            let height = text!.height(ofFont: textLb.font, maxWidth: textWidth)
            textLb.size = CGSize(width: textWidth, height: height)
        }
        var textMaxWidth = textLb.width + 60
        if textMaxWidth < 100 {
            textMaxWidth = 100
        }
        
        let centenrX = textMaxWidth / 2
        textLb.centerX = centenrX
        if mode == .indicator {
            indicatorView.startAnimating()
            indicatorView.centerX = centenrX
            if text != nil {
                textLb.y = indicatorView.frame.maxY + 10
            }else {
                textLb.y = indicatorView.frame.maxY
            }
        }else if mode == .image {
            imageView.centerX = centenrX
            if text != nil {
                textLb.y = imageView.frame.maxY + 15
            }else {
                textLb.y = imageView.frame.maxY
            }
        }else if mode == .success {
            tickView.centerX = centenrX
            textLb.y = tickView.frame.maxY
        }
        
        contentView.height = textLb.frame.maxY
        contentView.width = textMaxWidth
        if contentView.height + 40 < 100 {
            backgroundView.height = 100
        }else {
            backgroundView.height = contentView.height + 40
        }
        if textMaxWidth < backgroundView.height {
            backgroundView.width = backgroundView.height
        }else {
            backgroundView.width = textMaxWidth
        }
        contentView.center = CGPoint(x: backgroundView.width * 0.5, y: backgroundView.height * 0.5)
        backgroundView.center = CGPoint(x: width * 0.5, y: height * 0.5)
        blurEffectView.frame = backgroundView.bounds
    }
    @discardableResult
    class func showLoading(addedTo view: UIView?, animated: Bool) -> ProgressHUD? {
        return showLoading(addedTo: view, text: nil, animated: animated)
    }
    @discardableResult
    class func showLoading(addedTo view: UIView?, afterDelay: TimeInterval, animated: Bool) -> ProgressHUD? {
        return showLoading(addedTo: view, text: nil, afterDelay: afterDelay, animated: animated)
    }
    @discardableResult
    class func showLoading(addedTo view: UIView?, text: String?, animated: Bool) -> ProgressHUD? {
        return showLoading(addedTo: view, text: text, afterDelay: 0, animated: animated)
    }
    @discardableResult
    class func showLoading(addedTo view: UIView?, text: String?, afterDelay: TimeInterval , animated: Bool) -> ProgressHUD? {
        if view == nil {
            return nil
        }
        let progressView = ProgressHUD.init(addedTo: view!, mode: .indicator)
        progressView.showHUD(text: text, animated: animated, afterDelay: afterDelay)
        view!.addSubview(progressView)
        return progressView
    }
    class func showWarning(addedTo view: UIView?, text: String?, animated: Bool, delayHide: TimeInterval) {
        self.showWarning(addedTo: view, text: text, afterDelay: 0, animated: animated)
        self.hide(forView: view, animated: animated, afterDelay: delayHide)
    }
    class func showWarning(addedTo view: UIView?, text: String?, afterDelay: TimeInterval , animated: Bool) {
        if view == nil {
            return
        }
        let progressView = ProgressHUD.init(addedTo: view!, mode: .image)
        progressView.showHUD(text: text, animated: animated, afterDelay: afterDelay)
        view!.addSubview(progressView)
    }
    class func showSuccess(addedTo view: UIView?, text: String?, animated: Bool, delayHide: TimeInterval) {
        self.showSuccess(addedTo: view, text: text, afterDelay: 0, animated: animated)
        self.hide(forView: view, animated: animated, afterDelay: delayHide)
    }
    class func showSuccess(addedTo view: UIView?, text: String?, afterDelay: TimeInterval , animated: Bool) {
        if view == nil {
            return
        }
        let progressView = ProgressHUD.init(addedTo: view!, mode: .success)
        progressView.showHUD(text: text, animated: animated, afterDelay: afterDelay)
        view!.addSubview(progressView)
    }
    
    class func hide(forView view:UIView? ,animated: Bool) {
        hide(forView: view, animated: animated, afterDelay: 0)
    }
    
    class func hide(forView view:UIView? ,animated: Bool ,afterDelay: TimeInterval) {
        if view == nil {
            return
        }
        for subView in view!.subviews {
            if subView is ProgressHUD {
                (subView as! ProgressHUD).hide(withAnimated: animated, afterDelay: afterDelay)
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if !frame.equalTo(superview?.bounds ?? frame) {
            frame = superview?.bounds ?? frame
            updateFrame()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ProgressCircleView: UIView {
    
    lazy var circleLayer: CAShapeLayer = {
        let lineWidth: CGFloat = 3
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        circleLayer.contentsScale = UIScreen.main.scale
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(arcCenter: CGPoint(x: width * 0.5, y: height * 0.5), radius: width * 0.5 - lineWidth * 0.5, startAngle: -CGFloat.pi, endAngle: -CGFloat.pi + CGFloat.pi * 2, clockwise: true)
        circleLayer.path = path.cgPath
        circleLayer.lineCap = .round
        circleLayer.lineJoin = .round
        circleLayer.lineWidth = lineWidth
        return circleLayer
    }()
    
    lazy var maskLayer: CALayer = {
        let maskLayer = CALayer()
        maskLayer.frame = bounds
        maskLayer.contentsScale = UIScreen.main.scale
        let topLayer = CAGradientLayer.init()
        topLayer.frame = CGRect(x: 0, y: 0, width: width, height: height * 0.5)
        topLayer.colors = [UIColor.white.withAlphaComponent(0.85).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
        topLayer.startPoint = CGPoint(x: 0, y: 0);
        topLayer.endPoint = CGPoint(x: 1, y: 0);
        maskLayer.addSublayer(topLayer)
        let bottomLayer = CAGradientLayer.init()
        bottomLayer.frame = CGRect(x: 0, y: height * 0.5, width: width, height: height * 0.5)
        bottomLayer.colors = [UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.white.withAlphaComponent(0.15).cgColor, UIColor.white.withAlphaComponent(0.05).cgColor]
        bottomLayer.startPoint = CGPoint(x: 1, y: 1);
        bottomLayer.endPoint = CGPoint(x: 0, y: 1);
        maskLayer.addSublayer(bottomLayer)
        maskLayer.mask = circleLayer
        return maskLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(maskLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 0.5
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        maskLayer.add(animation, forKey: nil)
    }
    func stopAnimating() {
        maskLayer.removeAllAnimations()
    }
}
