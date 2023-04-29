//
//  EditorStickersContentView.swift
//  HXPHPicker
//
//  Created by Slience on 2023/4/13.
//

import UIKit

class EditorStickersContentView: UIView {
    lazy var animationView: VideoEditorMusicAnimationView = {
        let view = VideoEditorMusicAnimationView(hexColor: "#ffffff")
        view.startAnimation()
        return view
    }()
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        let fontSize: CGFloat = 25
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.truncationMode = .end
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .left
        textLayer.isWrapped = true
        return textLayer
    }()
    lazy var imageView: ImageView = {
        let view = ImageView()
        if let imageData = item.imageData {
            view.setImageData(imageData)
        }else {
            view.image = item.image
        }
        return view
    }()
    var scale: CGFloat = 1
    var item: EditorStickerItem
    weak var timer: Timer?
    init(item: EditorStickerItem) {
        self.item = item
        super.init(frame: item.frame)
        if item.music != nil {
            addSubview(animationView)
            layer.addSublayer(textLayer)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if let player = PhotoManager.shared.audioPlayer {
                textLayer.string = item.music?.lyric(atTime: player.currentTime)?.lyric
            }else {
                textLayer.string = item.music?.lyric(atTime: 0)?.lyric
            }
            CATransaction.commit()
            updateText()
            startTimer()
        }else {
            if item.text != nil {
                imageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            }
            addSubview(imageView)
        }
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    func startTimer() {
        invalidateTimer()
        let timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true, block: { [weak self] timer in
                if let player = PhotoManager.shared.audioPlayer {
                    let lyric = self?.item.music?.lyric(atTime: player.currentTime)
                    if let str = self?.textLayer.string as? String,
                       let lyricStr = lyric?.lyric,
                       str == lyricStr {
                       return
                    }
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self?.textLayer.string = lyric?.lyric
                    self?.updateText()
                    CATransaction.commit()
                }else {
                    timer.invalidate()
                    self?.timer = nil
                }
        })
        self.timer = timer
    }
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    func update(item: EditorStickerItem) {
        self.item = item
        if !frame.equalTo(item.frame) {
            frame = item.frame
        }
        if imageView.image != item.image {
            imageView.image = item.image
        }
    }
    func updateText() {
        if var height = (textLayer.string as? String)?.height(
            ofFont: textLayer.font as! UIFont, maxWidth: width * scale
        ) {
            height = min(100, height)
            if textLayer.frame.height != height {
                textLayer.frame = CGRect(origin: .zero, size: CGSize(width: width * scale, height: height))
            }
        }
        animationView.frame = CGRect(x: 2, y: -23, width: 20, height: 15)
    }
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizer.delegate = self
        super.addGestureRecognizer(gestureRecognizer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if item.music != nil {
            updateText()
        }else {
            imageView.frame = bounds
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorStickersContentView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
//        if otherGestureRecognizer.delegate is PhotoEditorViewController ||
//            otherGestureRecognizer.delegate is VideoEditorViewController {
//            return false
//        }
        if otherGestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            return true
        }
        if let view = gestureRecognizer.view, view == self,
           let otherView = otherGestureRecognizer.view, otherView == self {
            return true
        }
        return false
    }
}
