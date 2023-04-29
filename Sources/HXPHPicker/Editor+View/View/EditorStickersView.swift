//
//  EditorStickersView.swift
//  HXPHPicker
//
//  Created by Slience on 2023/1/20.
//

import UIKit

protocol EditorStickersViewDelegate: AnyObject {
    func stickerView(touchBegan stickerView: EditorStickersView)
    func stickerView(touchEnded stickerView: EditorStickersView)
    func stickerView(_ stickerView: EditorStickersView, moveToCenter itemView: EditorStickersItemView) -> Bool
    func stickerView(_ stickerView: EditorStickersView, minScale itemSize: CGSize) -> CGFloat
    func stickerView(_ stickerView: EditorStickersView, maxScale itemSize: CGSize) -> CGFloat
    func stickerView(_ stickerView: EditorStickersView, updateStickerText item: EditorStickerItem)
    func stickerView(didRemoveAudio stickerView: EditorStickersView)
    
    
    func stickerView(itemCenter stickerView: EditorStickersView) -> CGPoint?
}

extension EditorStickerViewDelegate {
    func stickerView(didRemoveAudio stickerView: EditorStickersView) {}
}
class EditorStickersView: UIView {
    weak var delegate: EditorStickersViewDelegate?
    var scale: CGFloat = 1 {
        didSet {
            for subView in subviews {
                if let itemView = subView as? EditorStickersItemView {
                    itemView.scale = scale
                }
            }
        }
    }
    var isTouching: Bool = false
    var isEnabled: Bool {
        get {
            isUserInteractionEnabled
        }
        set {
            if !newValue {
                deselectedSticker()
            }
            isUserInteractionEnabled = newValue
        }
    }
    var count: Int {
        subviews.count
    }
    
    var selectView: EditorStickersItemView? {
        willSet {
            if let selectView = selectView,
               let selectSuperView = selectView.superview,
               selectSuperView == UIApplication._keyWindow {
                endDragging(selectView)
            }
        }
    }
    
    weak var audioView: EditorStickersItemView?
    lazy var trashView: EditorStickerTrashView = {
        let view = EditorStickerTrashView(frame: CGRect(x: 0, y: 0, width: 180, height: 80))
        view.centerX = UIScreen.main.bounds.width * 0.5
        view.y = UIScreen.main.bounds.height
        view.alpha = 0
        return view
    }()
    
    var isShowTrash: Bool = false
    
    var trashViewDidRemove: Bool = false
    var trashViewIsVisible: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isEnabled {
            return nil
        }
        let view = super.hitTest(point, with: event)
        if isTouching {
            return view
        }
        if let view = view, view is EditorStickersContentView {
            if let selectView = selectView {
                let rect = selectView.frame
                if rect.contains(point) {
                    return selectView.contentView
                }
                let deleteRect = selectView.convert(selectView.deleteBtn.frame, to: self)
                if deleteRect.contains(point) {
                    return selectView.deleteBtn
                }
                let scaleRect = selectView.convert(selectView.scaleBtn.frame, to: self)
                if scaleRect.contains(point) {
                    return selectView.scaleBtn
                }
            }
            if let itemView = view.superview?.superview as? EditorStickersItemView,
               !itemView.isDelete {
                if itemView != selectView {
                    deselectedSticker()
                    itemView.isSelected = true
                    bringSubviewToFront(itemView)
                    itemView.resetRotaion()
                    selectView = itemView
                }
            }
        }else {
            if let selectView = selectView {
                let rect = selectView.frame
                if rect.contains(point) {
                    return selectView.contentView
                }
                let deleteRect = selectView.convert(selectView.deleteBtn.frame, to: self)
                if deleteRect.contains(point) {
                    return selectView.deleteBtn
                }
                let scaleRect = selectView.convert(selectView.scaleBtn.frame, to: self)
                if scaleRect.contains(point) {
                    return selectView.scaleBtn
                }
                deselectedSticker()
            }else {
                let lastView = subviews.filter {
                    let rect = $0.frame
                    return rect.contains(point)
                }.last
                if let lastView = lastView as? EditorStickersItemView {
                    if lastView != selectView {
                        deselectedSticker()
                        lastView.isSelected = true
                        bringSubviewToFront(lastView)
                        lastView.resetRotaion()
                        selectView = lastView
                    }
                }else {
                    deselectedSticker()
                }
            }
        }
        return view
    }
    var isDragging: Bool = false
    var beforeItemArg: CGFloat = 0
    var currentItemArg: CGFloat = 0
    var angle: CGFloat = 0
    var currentItemDegrees: CGFloat = 0
    var hasImpactFeedback: Bool = false
    var mirrorScale: CGPoint = .init(x: 1, y: 1) {
        didSet {
            for subView in subviews {
                if let itemView = subView as? EditorStickersItemView {
                    itemView.initialMirrorScale = itemView.editMirrorScale
                }
            }
        }
    }
    
    func stickerData() -> EditorStickerData? {
        var datas: [EditorStickerItemData] = []
        var showLyric = false
        var LyricIndex = 0
        for (index, subView) in subviews.enumerated() {
            if let itemView = subView as? EditorStickerItemView {
                if itemView.item.music != nil {
                    showLyric = true
                    LyricIndex = index
                }
                let centerScale = CGPoint(x: itemView.centerX / width, y: itemView.centerY / height)
                let itemData = EditorStickerItemData(
                    item: itemView.item,
                    pinchScale: itemView.pinchScale,
                    rotation: itemView.radian,
                    centerScale: centerScale,
                    mirrorType: itemView.mirrorType,
                    superMirrorType: itemView.superMirrorType,
                    superAngel: itemView.superAngle,
                    initialAngle: itemView.initialAngle,
                    initialMirrorType: itemView.initialMirrorType
                )
                datas.append(itemData)
            }
        }
//        if datas.isEmpty {
            return nil
//        }
//        let stickerData = EditorStickerData(
//            items: datas,
//            mirrorType: mirrorType,
//            angel: angle,
//            showLyric: showLyric,
//            LyricIndex: LyricIndex
//        )
//        return stickerData
    }
    func setStickerData(stickerData: EditorStickerData, viewSize: CGSize) {
//        mirrorType = stickerData.mirrorType
//        angle = stickerData.angel
//        for itemData in stickerData.items {
//            let itemView = add(sticker: itemData.item, isSelected: false)
//            itemView.mirrorType = itemData.mirrorType
//            itemView.superMirrorType = itemData.superMirrorType
//            itemView.superAngle = itemData.superAngel
//            itemView.initialAngle = itemData.initialAngle
//            itemView.initialMirrorType = itemData.initialMirrorType
//            itemView.update(
//                pinchScale: itemData.pinchScale,
//                rotation: itemData.rotation,
//                isInitialize: true,
//                isMirror: true
//            )
//            itemView.center = CGPoint(
//                x: viewSize.width * itemData.centerScale.x,
//                y: viewSize.height * itemData.centerScale.y
//            )
//        }
    }
    func getStickerInfo() -> [EditorStickerInfo] {
        var infos: [EditorStickerInfo] = []
//        for subView in subviews {
//            if let itemView = subView as? EditorStickerItemView {
//                let image: UIImage
//                if let imageData = itemView.item.imageData {
//                    #if canImport(Kingfisher)
//                    image = DefaultImageProcessor.default.process(
//                        item: .data(imageData),
//                        options: .init([])
//                    )!
//                    #else
//                    image = UIImage.init(data: imageData)!
//                    #endif
//                }else {
//                    image = itemView.item.image
//                }
//                let music: EditorStickerInfoMusic?
//                if let musicInfo = itemView.item.music {
//                    music = .init(
//                        fontSizeScale: 25.0 / width,
//                        animationSizeScale: CGSize(
//                            width: 20 / width,
//                            height: 15 / height
//                        ),
//                        music: musicInfo
//                    )
//                }else {
//                    music = nil
//                }
//                let info = EditorStickerInfo(
//                    image: image,
//                    isText: itemView.item.text != nil,
//                    centerScale: CGPoint(x: itemView.centerX / width, y: itemView.centerY / height),
//                    sizeScale: CGSize(
//                        width: itemView.item.frame.width / width,
//                        height: itemView.item.frame.height / height
//                    ),
//                    angel: itemView.radian,
//                    scale: itemView.pinchScale,
//                    viewSize: size,
//                    music: music,
//                    initialAngle: itemView.initialAngle,
//                    initialMirrorType: itemView.initialMirrorType
//                )
//                infos.append(info)
//            }
//        }
        return infos
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorStickersView {
    @discardableResult
    func add(
        sticker item: EditorStickerItem,
        isSelected: Bool
    ) -> EditorStickersItemView {
        selectView?.isSelected = false
        let itemView = EditorStickersItemView(item: item, scale: scale)
        itemView.delegate = self
        var pScale: CGFloat
        if item.text == nil && item.music == nil {
            let ratio: CGFloat = 0.5
            var width = self.width * self.scale
            var height = self.height * self.scale
            if width > UIScreen.main.bounds.width {
                width = UIScreen.main.bounds.width
            }
            if height > UIScreen.main.bounds.height {
                height = UIScreen.main.bounds.height
            }
            pScale = min(ratio * width / itemView.width, ratio * height / itemView.height)
        }else if item.text != nil {
            pScale = min(
                min(
                    self.width * self.scale - 40,
                    itemView.width
                ) / itemView.width,
                min(
                    self.height * self.scale - 40,
                    itemView.height
                ) / itemView.height
            )
        }else {
            pScale = 1
        }
        itemView.mirrorScale = mirrorScale
        let radians = -angle.radians
        itemView.isSelected = isSelected
        if let center = delegate?.stickerView(itemCenter: self) {
            itemView.center = center
        }else {
            if let keyWindow = UIApplication._keyWindow {
                itemView.center = convert(keyWindow.center, from: keyWindow)
            }
        }
        itemView.firstTouch = isSelected
        addSubview(itemView)
        itemView.update(pinchScale: pScale / self.scale, rotation: radians)
        if isSelected {
            selectView = itemView
        }
        if item.music != nil {
            audioView = itemView
        }
        return itemView
    }
    func deselectedSticker() {
        selectView?.isSelected = false
        selectView = nil
    }
    func removeAudioView() {
        audioView?.invalidateTimer()
        audioView?.removeFromSuperview()
        audioView = nil
    }
    func removeAllSticker() {
        deselectedSticker()
        removeAudioView()
        for subView in subviews where subView is EditorStickerItemView {
            subView.removeFromSuperview()
        }
    }
    func resetItemView(itemView: EditorStickersItemView) {
        if isDragging {
            endDragging(itemView)
        }
    }
    
    func update(item: EditorStickerItem) {
        selectView?.update(item: item)
    }
}

extension EditorStickersView {
    
    func startDragging(_ itemView: EditorStickersItemView) {
        isDragging = true
        beforeItemArg = itemView.radian
        let radians = angle.radians
        currentItemDegrees = radians
        if itemView.superview != UIApplication._keyWindow {
            let rect = convert(itemView.frame, to: UIApplication._keyWindow)
            itemView.frame = rect
            UIApplication._keyWindow?.addSubview(itemView)
        }
        let rotation: CGFloat
        if itemView.mirrorScale.x * itemView.mirrorScale.y == 1 {
            if itemView.initialMirrorScale.x * itemView.initialMirrorScale.y == 1 {
                rotation = itemView.radian + radians
            }else {
                rotation = -itemView.radian - radians
            }
        }else {
            if itemView.initialMirrorScale.x * itemView.initialMirrorScale.y == 1 {
                rotation = -itemView.radian - radians
            }else {
                rotation = itemView.radian + radians
            }
        }
        itemView.update(
            pinchScale: itemView.pinchScale,
            rotation: rotation,
            isWindow: true
        )
        currentItemArg = itemView.radian
    }
    
    func endDragging(_ itemView: EditorStickersItemView) {
        isDragging = false
        guard let superview = itemView.superview,
              superview != self else {
            return
        }
        let arg = itemView.radian - currentItemArg
        if superview == UIApplication._keyWindow {
            let rect = superview.convert(itemView.frame, to: self)
            itemView.frame = rect
        }
        addSubview(itemView)
        let rotation: CGFloat
        if itemView.mirrorScale.x * itemView.mirrorScale.y == 1 {
            if itemView.initialMirrorScale.x * itemView.initialMirrorScale.y == 1 {
                rotation = itemView.radian - currentItemDegrees
            }else {
                rotation = -itemView.radian - currentItemDegrees
            }
        }else {
            if itemView.initialMirrorScale.x * itemView.initialMirrorScale.y == 1 {
                rotation = beforeItemArg - arg
            }else {
                rotation = beforeItemArg + arg
            }
        }
        itemView.update(
            pinchScale: itemView.pinchScale,
            rotation: rotation
        )
    }
}

extension EditorStickersView {
    
    func mirrorVerticallyHandler() {
        mirrorHandler(.init(x: -1, y: 1))
    }
    func mirrorHorizontallyHandler() {
        mirrorHandler(.init(x: 1, y: -1))
    }
    func mirrorHandler(_ scale: CGPoint) {
        for subView in subviews {
            if let itemView = subView as? EditorStickersItemView {
                let transform = CGAffineTransform(scaleX: itemView.editMirrorScale.x, y: itemView.editMirrorScale.y).scaledBy(x: scale.x, y: scale.y)
                itemView.editMirrorScale = .init(x: transform.a, y: transform.d)
            }
        }
    }
    func initialMirror(_ scale: CGPoint) {
        for subView in subviews {
            if let itemView = subView as? EditorStickersItemView {
                let transform = CGAffineTransform(scaleX: itemView.editMirrorScale.x, y: itemView.editMirrorScale.y).scaledBy(x: scale.x, y: scale.y)
                itemView.editMirrorScale = .init(x: transform.a, y: transform.d)
            }
        }
    }
    func resetMirror() {
        for subView in subviews {
            if let itemView = subView as? EditorStickersItemView {
                itemView.editMirrorScale = itemView.initialMirrorScale
            }
        }
    }
}

extension EditorStickersView {
    
    func showTrashView() {
        if !isShowTrash {
            return
        }
        trashViewDidRemove = false
        trashViewIsVisible = true
        UIView.animate(withDuration: 0.25) {
            self.trashView.centerX = UIScreen.main.bounds.width * 0.5
            self.trashView.y = UIScreen.main.bounds.height - UIDevice.bottomMargin - 20 - self.trashView.height
            self.trashView.alpha = 1
        } completion: { _ in
            if !self.trashViewIsVisible {
                self.trashView.y = UIScreen.main.bounds.height
                self.trashView.alpha = 0
            }
        }
    }
    
    @objc
    func hideTrashView() {
        if !isShowTrash {
            return
        }
        trashViewIsVisible = false
        trashViewDidRemove = true
        UIView.animate(withDuration: 0.25) {
            self.trashView.centerX = UIScreen.main.bounds.width * 0.5
            self.trashView.y = UIScreen.main.bounds.height
            self.trashView.alpha = 0
            self.selectView?.alpha = 1
        } completion: { _ in
            if !self.trashViewIsVisible {
                self.trashView.removeFromSuperview()
                self.trashView.inArea = false
            }else {
                self.trashView.y = UIScreen.main.bounds.height - UIDevice.bottomMargin - 20 - self.trashView.height
                self.trashView.alpha = 1
            }
        }

    }
}

extension EditorStickersView: EditorStickersItemViewDelegate {
    func stickerItemView(
        _ itemView: EditorStickersItemView,
        updateStickerText item: EditorStickerItem
    ) {
        delegate?.stickerView(self, updateStickerText: item)
    }
    
    func stickerItemView(shouldTouchBegan itemView: EditorStickersItemView) -> Bool {
        if let selectView = selectView, itemView != selectView {
            return false
        }
        return true
    }
    
    func stickerItemView(didTouchBegan itemView: EditorStickersItemView) {
        isTouching = true
        delegate?.stickerView(touchBegan: self)
        if let selectView = selectView, selectView != itemView {
            selectView.isSelected = false
            self.selectView = itemView
        }else if selectView == nil {
            selectView = itemView
        }
        if !isDragging {
            startDragging(itemView)
        }
        if !trashViewIsVisible && isShowTrash {
            UIApplication._keyWindow?.addSubview(trashView)
            showTrashView()
        }
    }
    
    func stickerItemView(didDragScale itemView: EditorStickersItemView) {
        delegate?.stickerView(touchBegan: self)
        if !isDragging {
            startDragging(itemView)
        }
    }
    
    func stickerItemView(touchEnded itemView: EditorStickersItemView) {
        delegate?.stickerView(touchEnded: self)
        if let selectView = selectView, selectView != itemView {
            selectView.isSelected = false
            self.selectView = itemView
        }else if selectView == nil {
            selectView = itemView
        }
        resetItemView(itemView: itemView)
        if trashViewIsVisible {
            hideTrashView()
        }
        isTouching = false
    }
    func stickerItemView(_ itemView: EditorStickersItemView, tapGestureRecognizerNotInScope point: CGPoint) {
        if let selectView = selectView, itemView == selectView {
            if isDragging {
                endDragging(selectView)
            }else {
                deselectedSticker()
            }
            let cPoint = itemView.convert(point, to: self)
            for subView in subviews.reversed() {
                if let itemView = subView as? EditorStickersItemView {
                    if itemView.frame.contains(cPoint) {
                        itemView.isSelected = true
                        self.selectView = itemView
                        bringSubviewToFront(itemView)
                        return
                    }
                }
            }
        }
    }
    
    func stickerItemView(_ itemView: EditorStickersItemView, panGestureRecognizerChanged panGR: UIPanGestureRecognizer) {
        if !isShowTrash {
            return
        }
        let point = panGR.location(in: UIApplication._keyWindow)
        if trashView.frame.contains(point) && !trashViewDidRemove {
            trashView.inArea = true
            if !hasImpactFeedback {
                UIView.animate(withDuration: 0.25) {
                    self.selectView?.alpha = 0.4
                }
                perform(#selector(hideTrashView), with: nil, afterDelay: 1.2)
                let shake = UIImpactFeedbackGenerator(style: .medium)
                shake.prepare()
                shake.impactOccurred()
                trashView.layer.removeAllAnimations()
                let animaiton = CAKeyframeAnimation(keyPath: "transform.scale")
                animaiton.duration = 0.3
                animaiton.values = [1.05, 0.95, 1.025, 0.975, 1]
                trashView.layer.add(animaiton, forKey: nil)
                hasImpactFeedback = true
            }
        }else {
            UIView.animate(withDuration: 0.2) {
                self.selectView?.alpha = 1
            }
            UIView.cancelPreviousPerformRequests(withTarget: self)
            hasImpactFeedback = false
            trashView.inArea = false
        }
    }
    func stickerItemView(moveToCenter itemView: EditorStickersItemView) -> Bool {
        delegate?.stickerView(self, moveToCenter: itemView) ?? false
    }
    func stickerItemView(panGestureRecognizerEnded itemView: EditorStickersItemView) -> Bool {
        if !isShowTrash {
            if let selectView = selectView, selectView != itemView {
                selectView.isSelected = false
                self.selectView = itemView
            }else if selectView == nil {
                selectView = itemView
            }
            resetItemView(itemView: itemView)
            return false
        }
        let inArea = trashView.inArea
        if inArea {
            isDragging = false
            trashView.inArea = false
            if itemView.item.music != nil {
                itemView.invalidateTimer()
                audioView = nil
                delegate?.stickerView(didRemoveAudio: self)
            }
            itemView.isDelete = true
            itemView.isEnabled = false
            UIView.animate(withDuration: 0.25) {
                itemView.alpha = 0
            } completion: { _ in
                itemView.removeFromSuperview()
            }
            selectView = nil
        }else {
            if let selectView = selectView, selectView != itemView {
                selectView.isSelected = false
                self.selectView = itemView
            }else if selectView == nil {
                selectView = itemView
            }
            resetItemView(itemView: itemView)
        }
        if isDragging {
            hideTrashView()
        }
        return inArea
    }
    func stickerItemView(_ itemView: EditorStickersItemView, maxScale itemSize: CGSize) -> CGFloat {
        if let maxScale = delegate?.stickerView(self, maxScale: itemSize) {
            return maxScale
        }
        return 5
    }
    
    func stickerItemView(_ itemView: EditorStickersItemView, minScale itemSize: CGSize) -> CGFloat {
        if let minScale = delegate?.stickerView(self, minScale: itemSize) {
            return minScale
        }
        return 0.2
    }
    
    func stickerItemView(itemCenter itemView: EditorStickersItemView) -> CGPoint {
        if let center = delegate?.stickerView(itemCenter: self) {
            return center
        }else {
            if let keyWindow = UIApplication._keyWindow {
                return convert(keyWindow.center, from: keyWindow)
            }
        }
        return .zero
    }
    
    func stickerItemView(didDeleteClick itemView: EditorStickersItemView) {
        if itemView == selectView {
            deselectedSticker()
        }
        itemView.removeFromSuperview()
    }
}
