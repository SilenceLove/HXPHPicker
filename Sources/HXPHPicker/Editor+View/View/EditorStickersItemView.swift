//
//  EditorStickersItemView.swift
//  HXPHPicker
//
//  Created by Slience on 2023/4/13.
//

import UIKit

protocol EditorStickersItemViewDelegate: AnyObject {
    func stickerItemView(shouldTouchBegan itemView: EditorStickersItemView) -> Bool
    func stickerItemView(didTouchBegan itemView: EditorStickersItemView)
    func stickerItemView(touchEnded itemView: EditorStickersItemView)
    func stickerItemView(_ itemView: EditorStickersItemView, updateStickerText item: EditorStickerItem)
    func stickerItemView(_ itemView: EditorStickersItemView, tapGestureRecognizerNotInScope point: CGPoint)
    func stickerItemView(_ itemView: EditorStickersItemView, panGestureRecognizerChanged panGR: UIPanGestureRecognizer)
    func stickerItemView(panGestureRecognizerEnded itemView: EditorStickersItemView) -> Bool
    func stickerItemView(moveToCenter itemView: EditorStickersItemView) -> Bool
    func stickerItemView(itemCenter itemView: EditorStickersItemView) -> CGPoint
    func stickerItemView(_ itemView: EditorStickersItemView, maxScale itemSize: CGSize) -> CGFloat
    func stickerItemView(_ itemView: EditorStickersItemView, minScale itemSize: CGSize) -> CGFloat
    func stickerItemView(didDeleteClick itemView: EditorStickersItemView)
    func stickerItemView(didDragScale itemView: EditorStickersItemView)
}
class EditorStickersItemView: UIView {
    weak var delegate: EditorStickersItemViewDelegate?
    lazy var mirrorView: UIView = {
        let view = UIView()
        return view
    }()
    lazy var contentView: EditorStickersContentView = {
        let view = EditorStickersContentView(item: item)
        view.center = center
        return view
    }()
    lazy var externalBorder: CALayer = {
        let externalBorder = CALayer()
        externalBorder.shadowOpacity = 0.3
        externalBorder.shadowOffset = CGSize(width: 0, height: 0)
        externalBorder.shadowRadius = 1
        externalBorder.shouldRasterize = true
        externalBorder.rasterizationScale = UIScreen.main.scale
        externalBorder.contentsScale = UIScreen.main.scale
        return externalBorder
    }()
    lazy var deleteBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage("hx_editor_view_sticker_item_delete".image, for: .normal)
        button.addTarget(self, action: #selector(didDeleteButtonClick), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    lazy var scaleBtn: UIImageView = {
        let button = UIImageView(image: "hx_editor_view_sticker_item_scale".image)
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(PhotoPanGestureRecognizer(target: self, action: #selector(dragScaleButtonClick(pan:))))
        button.isHidden = true
        return button
    }()
    var item: EditorStickerItem
    var isEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            contentView.isUserInteractionEnabled = isEnabled
        }
    }
    var isDelete: Bool = false
    var scale: CGFloat
    var touching: Bool = false
    var isSelected: Bool = false {
        willSet {
            if isSelected == newValue {
                return
            }
//            if item.music == nil {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                externalBorder.cornerRadius = newValue ? 1 / scale : 0
                externalBorder.borderWidth = newValue ? 1 / scale : 0
                CATransaction.commit()
                deleteBtn.isHidden = !newValue
                scaleBtn.isHidden = !newValue
//            }
            isUserInteractionEnabled = newValue
            if newValue {
                update(size: contentView.item.frame.size)
            }else {
                firstTouch = false
            }
        }
    }
    var itemMargin: CGFloat = 20
    var initialScale: CGFloat = 1
    var initialPoint: CGPoint = .zero
    var initialRadian: CGFloat = 0
    var initialMirrorScale: CGPoint = .init(x: 1, y: 1)
    var editMirrorScale: CGPoint = .init(x: 1, y: 1)
    
    var initialScalePoint: CGPoint = .zero
    var scaleR: CGFloat = 1
    var scaleA: CGFloat = 0
    var firstTouch: Bool = false
    var radian: CGFloat = 0
    var pinchScale: CGFloat = 1
    var mirrorScale: CGPoint = .init(x: 1, y: 1)
    
    init(
        item: EditorStickerItem,
        scale: CGFloat
    ) {
        self.item = item
        self.scale = scale
        let rect = CGRect(
            x: 0,
            y: 0,
            width: item.frame.width,
            height: item.frame.height
        )
        super.init(frame: rect)
        mirrorView.frame = bounds
        addSubview(mirrorView)
        let margin = itemMargin / scale
        externalBorder.frame = CGRect(
            x: -margin * 0.5,
            y: -margin * 0.5,
            width: width + margin,
            height: height + margin
        )
        layer.addSublayer(externalBorder)
        contentView.scale = scale
        mirrorView.addSubview(contentView)
//        if item.music == nil {
            externalBorder.borderColor = UIColor.white.cgColor
            addSubview(deleteBtn)
            addSubview(scaleBtn)
            deleteBtn.center = .init(x: externalBorder.frame.minX, y: externalBorder.frame.minY)
            scaleBtn.center = .init(x: externalBorder.frame.width, y: externalBorder.frame.height)
//        }
        initGestures()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if bounds.contains(point) {
            return contentView
        }
        return view
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorStickersItemView {
    
    func invalidateTimer() {
        contentView.invalidateTimer()
    }
    
    func initGestures() {
        contentView.isUserInteractionEnabled = true
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(contentViewTapClick(tapGR:)))
        contentView.addGestureRecognizer(tapGR)
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(contentViewPanClick(panGR:)))
        contentView.addGestureRecognizer(panGR)
        if item.music == nil {
            let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(contentViewPinchClick(pinchGR:)))
            contentView.addGestureRecognizer(pinchGR)
        }
        let rotationGR = UIRotationGestureRecognizer(
            target: self,
            action: #selector(contentViewRotationClick(rotationGR:))
        )
        contentView.addGestureRecognizer(rotationGR)
    }
}

extension EditorStickersItemView {
    
    @objc
    func didDeleteButtonClick() {
        delegate?.stickerItemView(didDeleteClick: self)
    }
    
    @objc
    func dragScaleButtonClick(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            touching = true
            firstTouch = true
            delegate?.stickerItemView(didDragScale: self)
            initialScalePoint = convert(scaleBtn.center, to: superview)
            let point = CGPoint(x: initialScalePoint.x - centerX, y: initialScalePoint.y - centerY)
            scaleR = sqrt(point.x * point.x + point.y * point.y)
            scaleA = atan2(point.y, point.x)
            
            initialScale = pinchScale
            initialRadian = radian
        case .changed:
            let point = pan.translation(in: superview)
            let p = CGPoint(x: initialScalePoint.x + point.x - centerX, y: initialScalePoint.y + point.y - centerY)
            let r = sqrt(p.x * p.x + p.y * p.y)
            let arg = atan2(p.y, p.x)
            
            update(pinchScale: initialScale * r / scaleR, rotation: initialRadian + arg - scaleA, isPinch: true)
        case .ended, .cancelled, .failed:
            if !touching {
                return
            }
            touching = false
            firstTouch = false
            let moveToCenter = delegate?.stickerItemView(moveToCenter: self)
            let itemCenter = delegate?.stickerItemView(itemCenter: self)
            delegate?.stickerItemView(touchEnded: self)
            if let moveToCenter = moveToCenter,
                let itemCenter = itemCenter,
               moveToCenter {
                UIView.animate(withDuration: 0.25) {
                    self.center = itemCenter
                }
            }
        default:
            break
        }
    }
    @objc
    func contentViewTapClick(tapGR: UITapGestureRecognizer) {
        if isDelete {
            return
        }
        if let shouldTouch = delegate?.stickerItemView(shouldTouchBegan: self), !shouldTouch {
            return
        }
        let point = tapGR.location(in: self)
        if !contentView.frame.contains(point) {
            delegate?.stickerItemView(self, tapGestureRecognizerNotInScope: point)
            isSelected = false
            return
        }
        if firstTouch && isSelected && item.text != nil && !touching {
            delegate?.stickerItemView(self, updateStickerText: item)
        }
        firstTouch = true
    }
    
    @objc
    func contentViewPanClick(panGR: UIPanGestureRecognizer) {
        if isDelete {
            return
        }
        if let shouldTouch = delegate?.stickerItemView(shouldTouchBegan: self), !shouldTouch {
            return
        }
        switch panGR.state {
        case .began:
            touching = true
            firstTouch = true
            delegate?.stickerItemView(didTouchBegan: self)
            isSelected = true
            initialPoint = self.center
            deleteBtn.isHidden = true
            scaleBtn.isHidden = true
        case .changed:
            let point = panGR.translation(in: superview)
            center = CGPoint(x: initialPoint.x + point.x, y: initialPoint.y + point.y)
            delegate?.stickerItemView(self, panGestureRecognizerChanged: panGR)
        case .ended, .cancelled, .failed:
            if !touching {
                return
            }
            touching = false
            let moveToCenter = delegate?.stickerItemView(moveToCenter: self)
            let itemCenter = delegate?.stickerItemView(itemCenter: self)
            var isDelete = false
            if let panIsDelete = delegate?.stickerItemView(panGestureRecognizerEnded: self) {
                isDelete = panIsDelete
            }
            self.delegate?.stickerItemView(touchEnded: self)
            if let moveToCenter = moveToCenter,
                let itemCenter = itemCenter,
               moveToCenter,
               !isDelete {
                UIView.animate(withDuration: 0.25) {
                    self.center = itemCenter
                }
            }
            if isSelected {
                deleteBtn.isHidden = false
                scaleBtn.isHidden = false
            }
        default:
            break
        }
    }
    
    @objc
    func contentViewPinchClick(pinchGR: UIPinchGestureRecognizer) {
        if isDelete {
            return
        }
        if let shouldTouch = delegate?.stickerItemView(shouldTouchBegan: self), !shouldTouch {
            return
        }
        switch pinchGR.state {
        case .began:
//            if item.music == nil {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                externalBorder.borderWidth = 0
                CATransaction.commit()
//            }
            touching = true
            firstTouch = true
            delegate?.stickerItemView(didTouchBegan: self)
            isSelected = true
            initialScale = pinchScale
            deleteBtn.isHidden = true
            scaleBtn.isHidden = true
            update(pinchScale: initialScale * pinchGR.scale, isPinch: true, isWindow: true)
        case .changed:
            update(pinchScale: initialScale * pinchGR.scale, isPinch: true, isWindow: true)
        case .ended, .cancelled, .failed:
            touching = false
//            if item.music == nil {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                externalBorder.borderWidth = 1 / scale
                CATransaction.commit()
//            }
            delegate?.stickerItemView(touchEnded: self)
            if isSelected {
                deleteBtn.isHidden = false
                scaleBtn.isHidden = false
            }
        default:
            break
        }
        if pinchGR.state == .began && pinchGR.state == .changed {
            pinchGR.scale = 1
        }
    }
    
    @objc
    func contentViewRotationClick(rotationGR: UIRotationGestureRecognizer) {
        if isDelete {
            return
        }
        if let shouldTouch = delegate?.stickerItemView(shouldTouchBegan: self), !shouldTouch {
            return
        }
        switch rotationGR.state {
        case .began:
            firstTouch = true
            touching = true
            isSelected = true
            delegate?.stickerItemView(didTouchBegan: self)
            initialRadian = radian
            rotationGR.rotation = 0
            deleteBtn.isHidden = true
            scaleBtn.isHidden = true
        case .changed:
            radian = initialRadian + rotationGR.rotation
            update(pinchScale: pinchScale, rotation: radian, isWindow: true)
        case .ended, .cancelled, .failed:
            if !touching {
                return
            }
            touching = false
            delegate?.stickerItemView(touchEnded: self)
            rotationGR.rotation = 0
            if isSelected {
                deleteBtn.isHidden = false
                scaleBtn.isHidden = false
            }
        default:
            break
        }
    }
}

extension EditorStickersItemView {
    func update(
        pinchScale: CGFloat,
        rotation: CGFloat? = nil,
        isInitialize: Bool = false,
        isPinch: Bool = false,
        isWindow: Bool = false
    ) {
        if let rotation = rotation {
            radian = rotation
        }
        var minScale = 0.2 / scale
        var maxScale = 3.0 / scale
        if let min = delegate?.stickerItemView(self, minScale: item.frame.size) {
            minScale = min / scale
        }
        if let max = delegate?.stickerItemView(self, maxScale: item.frame.size) {
            maxScale = max / scale
        }
        if isInitialize {
            self.pinchScale = pinchScale
        }else {
            if isPinch {
                if pinchScale > maxScale {
                    if pinchScale < initialScale {
                        self.pinchScale = pinchScale
                    }else {
                        if initialScale < maxScale {
                            self.pinchScale = min(max(pinchScale, minScale), maxScale)
                        }else {
                            self.pinchScale = initialScale
                        }
                    }
                }else if pinchScale < minScale {
                    if pinchScale > initialScale {
                        self.pinchScale = pinchScale
                    }else {
                        if minScale < initialScale {
                            self.pinchScale = min(max(pinchScale, minScale), maxScale)
                        }else {
                            self.pinchScale = initialScale
                        }
                    }
                }else {
                    self.pinchScale = min(max(pinchScale, minScale), maxScale)
                }
            }else {
                self.pinchScale = pinchScale
            }
        }
        transform = .identity
        mirrorView.transform = .identity
        var margin = itemMargin / scale
        if touching {
            margin *= scale
            contentView.transform = .init(scaleX: self.pinchScale * scale, y: self.pinchScale * scale)
        }else {
            contentView.transform = .init(scaleX: self.pinchScale, y: self.pinchScale)
        }
        var rect = frame
        rect.origin.x += (rect.width - contentView.width) / 2
        rect.origin.y += (rect.height - contentView.height) / 2
        rect.size.width = contentView.width
        rect.size.height = contentView.height
        
        frame = rect
        mirrorView.frame = bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        externalBorder.frame = CGRect(
            x: -margin * 0.5,
            y: -margin * 0.5,
            width: width + margin,
            height: height + margin
        )
        CATransaction.commit()
        
        contentView.center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        transform = transform.rotated(by: radian)
        if isWindow {
            mirrorView.transform = mirrorView.transform.scaledBy(x: initialMirrorScale.x, y: initialMirrorScale.y)
        }else {
            mirrorView.transform = mirrorView.transform.scaledBy(x: mirrorScale.x, y: mirrorScale.y)
        }
        
        if isSelected /* && item.music == nil */{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if touching {
                externalBorder.borderWidth = 1
                externalBorder.cornerRadius = 1
            }else {
                externalBorder.borderWidth = 1 / scale
                externalBorder.cornerRadius = 1 / scale
            }
            CATransaction.commit()
        }
        deleteBtn.size = .init(width: 40 / scale, height: 40 / scale)
        scaleBtn.size = .init(width: 40 / scale, height: 40 / scale)
        deleteBtn.center = .init(x: -margin * 0.5, y: -margin * 0.5)
        scaleBtn.center = .init(x: bounds.width + margin * 0.5, y: bounds.height + margin * 0.5)
    }
    
    func update(item: EditorStickerItem) {
        self.item = item
        contentView.update(item: item)
        update(size: item.frame.size)
    }
    
    func update(size: CGSize, isWindow: Bool = false) {
        let center = self.center
        var frame = frame
        frame.size = CGSize(width: size.width, height: size.height)
        self.frame = frame
        mirrorView.frame = bounds
        self.center = center
        let margin = itemMargin / scale
        externalBorder.frame = CGRect(
            x: -margin * 0.5,
            y: -margin * 0.5,
            width: width + margin,
            height: height + margin
        )
        contentView.transform = .identity
        transform = .identity
        mirrorView.transform = .identity
        
        contentView.size = size
        contentView.center = CGPoint(x: width * 0.5, y: height * 0.5)
        update(
            pinchScale: pinchScale,
            rotation: radian,
            isWindow: isWindow
        )
    }
    func resetRotaion(isWindow: Bool = false) {
        update(
            pinchScale: pinchScale,
            rotation: radian,
            isWindow: isWindow
        )
    }
}
