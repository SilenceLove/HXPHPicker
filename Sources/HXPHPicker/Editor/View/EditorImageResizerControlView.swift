//
//  EditorImageResizerControlView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/22.
//

import UIKit

protocol EditorImageResizerControlViewDelegate: AnyObject {
    func controlView(beganChanged controlView: EditorImageResizerControlView, _ rect: CGRect)
    func controlView(endChanged controlView: EditorImageResizerControlView, _ rect: CGRect)
    func controlView(didChanged controlView: EditorImageResizerControlView, _ rect: CGRect)
}

class EditorImageResizerControlView: UIView {
    weak var delegate: EditorImageResizerControlViewDelegate?
    
    lazy var topControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var bottomControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var leftControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var rightControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var leftTopControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var rightTopControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var rightBottomControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    lazy var leftBottomControl: UIView = {
        let view = UIView.init()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerHandler(pan:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    var maxImageresizerFrame: CGRect = .zero
    var imageresizerFrame: CGRect = .zero
    var currentFrame: CGRect = .zero
    var panning: Bool = false
    init() {
        super.init(frame: .zero)
        addSubview(topControl)
        addSubview(bottomControl)
        addSubview(leftControl)
        addSubview(rightControl)
        addSubview(leftTopControl)
        addSubview(leftBottomControl)
        addSubview(rightTopControl)
        addSubview(rightBottomControl)
    }
    
    @objc func panGestureRecognizerHandler(pan: UIPanGestureRecognizer) {
        let view = pan.view
        let point = pan.translation(in: view)
        if pan.state == .began {
            panning = true
            delegate?.controlView(beganChanged: self, frame)
//            if currentFrame.equalTo(.zero) {
                currentFrame = self.frame
//            }
        }
        var rectX = currentFrame.minX
        var rectY = currentFrame.minY
        var rectW = currentFrame.width
        var rectH = currentFrame.height
        if view == topControl {
            rectH = rectH - point.y
            rectY = rectY + point.y
            if rectH < 50 {
                rectH = 50
                rectY = currentFrame.maxY - 50
            }
            if rectY < maxImageresizerFrame.minY {
                rectY = maxImageresizerFrame.minY
                rectH = currentFrame.maxY - maxImageresizerFrame.minY
            }
        }else if view == leftControl {
            rectX = rectX + point.x
            rectW = rectW - point.x
            if rectW < 50 {
                rectW = 50
                rectX = currentFrame.maxX - 50
            }
            if rectX < maxImageresizerFrame.minX {
                rectX = maxImageresizerFrame.minX
                rectW = currentFrame.maxX - maxImageresizerFrame.minX
            }
        }else if view == rightControl {
            rectW = rectW + point.x
            if rectW < 50 {
                rectW = 50
            }
            if rectW > maxImageresizerFrame.maxX - currentFrame.minX {
                rectW = maxImageresizerFrame.maxX - currentFrame.minX
            }
        }else if view == bottomControl {
            rectH = rectH + point.y
            if rectH < 50 {
                rectH = 50
            }
            if rectH > maxImageresizerFrame.maxY - currentFrame.minY {
                rectH = maxImageresizerFrame.maxY - currentFrame.minY
            }
        }else if view == leftTopControl {
            rectX = rectX + point.x
            rectY = rectY + point.y
            rectW = rectW - point.x
            rectH = rectH - point.y
            if rectW < 50 {
                rectW = 50
                rectX = currentFrame.maxX - 50
            }
            if rectH < 50 {
                rectH = 50
                rectY = currentFrame.maxY - 50
            }
            if rectX < maxImageresizerFrame.minX {
                rectX = maxImageresizerFrame.minX
                rectW = currentFrame.maxX - maxImageresizerFrame.minX
            }
            if rectY < maxImageresizerFrame.minY {
                rectY = maxImageresizerFrame.minY
                rectH = currentFrame.maxY - maxImageresizerFrame.minY
            }
        }else if view == leftBottomControl {
            rectX = rectX + point.x
            rectW = rectW - point.x
            rectH = rectH + point.y
            if rectW < 50 {
                rectW = 50
                rectX = currentFrame.maxX - 50
            }
            if rectH < 50 {
                rectH = 50
            }
            if rectX < maxImageresizerFrame.minX {
                rectX = maxImageresizerFrame.minX
                rectW = currentFrame.maxX - maxImageresizerFrame.minX
            }
            if rectH > maxImageresizerFrame.maxY - currentFrame.minY {
                rectH = maxImageresizerFrame.maxY - currentFrame.minY
            }
        }else if view == rightTopControl {
            rectW = rectW + point.x
            rectY = rectY + point.y
            rectH = rectH - point.y
            if rectW < 50 {
                rectW = 50
            }
            if rectH < 50 {
                rectH = 50
                rectY = currentFrame.maxY - 50
            }
            if rectW > maxImageresizerFrame.maxX - currentFrame.minX {
                rectW = maxImageresizerFrame.maxX - currentFrame.minX
            }
            if rectY < maxImageresizerFrame.minY {
                rectY = maxImageresizerFrame.minY
                rectH = currentFrame.maxY - maxImageresizerFrame.minY
            }
        }else if view == rightBottomControl {
            rectW = rectW + point.x
            rectH = rectH + point.y
            if rectW < 50 {
                rectW = 50
            }
            if rectH < 50 {
                rectH = 50
            }
            if rectW > maxImageresizerFrame.maxX - currentFrame.minX {
                rectW = maxImageresizerFrame.maxX - currentFrame.minX
            }
            if rectH > maxImageresizerFrame.maxY - currentFrame.minY {
                rectH = maxImageresizerFrame.maxY - currentFrame.minY
            }
        }
        frame = CGRect(x: rectX, y: rectY, width: rectW, height: rectH)
        delegate?.controlView(didChanged: self, frame)
        if pan.state == .cancelled || pan.state == .ended || pan.state == .failed {
            delegate?.controlView(endChanged: self, frame)
            panning = false
        }
//        switch pan.state {
//        case .cancelled, .ended, .failed:
//            currentFrame = .zero
//        default:
//            break
//        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled {
            return nil
        }
        if topControl.frame.contains(point) {
            return topControl
        }else if leftControl.frame.contains(point) {
            return leftControl
        }else if rightControl.frame.contains(point) {
            return rightControl
        }else if bottomControl.frame.contains(point) {
            return bottomControl
        }else if leftTopControl.frame.contains(point) {
            return leftTopControl
        }else if leftBottomControl.frame.contains(point) {
            return leftBottomControl
        }else if rightTopControl.frame.contains(point) {
            return rightTopControl
        }else if rightBottomControl.frame.contains(point) {
            return rightBottomControl
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let lineMarign: CGFloat = 20
        topControl.frame = CGRect(x: lineMarign, y: -lineMarign, width: width - lineMarign * 2, height: lineMarign * 2)
        leftControl.frame = CGRect(x: -lineMarign, y: lineMarign, width: lineMarign * 2, height: height - lineMarign * 2)
        rightControl.frame = CGRect(x: width - lineMarign, y: lineMarign, width: lineMarign * 2, height: height - lineMarign * 2)
        bottomControl.frame = CGRect(x: lineMarign, y: height - lineMarign, width: width - lineMarign * 2, height: lineMarign * 2)
        leftTopControl.frame = CGRect(x: -lineMarign, y: -lineMarign, width: lineMarign * 2, height: lineMarign * 2)
        leftBottomControl.frame = CGRect(x: -lineMarign, y: height - lineMarign, width: lineMarign * 2, height: lineMarign * 2)
        rightTopControl.frame = CGRect(x: width - lineMarign, y: -lineMarign, width: lineMarign * 2, height: lineMarign * 2)
        rightBottomControl.frame = CGRect(x: width - lineMarign, y: height - lineMarign, width: lineMarign * 2, height: lineMarign * 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
