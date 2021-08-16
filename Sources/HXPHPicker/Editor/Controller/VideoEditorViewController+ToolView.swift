//
//  VideoEditorViewController+ToolView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/6.
//

import UIKit
import AVKit

// MARK: EditorToolViewDelegate
extension VideoEditorViewController: EditorToolViewDelegate {
    
    /// 导出视频
    /// - Parameter toolView: 底部工具视频
    func toolView(didFinishButtonClick toolView: EditorToolView) {
        playerView.stickerView.deselectedSticker()
        let hasSticker = playerView.stickerView.count > 0
        let stickerLayer = playerView.stickerView.layer
        if let startTime = playerView.playStartTime,
           let endTime = playerView.playEndTime {
            ProgressHUD.showLoading(addedTo: view, text: "视频导出中".localized, animated: true)
            exportSession = PhotoTools.exportEditVideo(
                for: avAsset,
                timeRang: CMTimeRange(start: startTime, end: endTime),
                presentName: config.exportPresetName)
            { [weak self] (videoURL, error) in
                guard let self = self else {
                    return
                }
                if let videoURL = videoURL {
                    if self.backgroundMusicPath != nil ||
                        self.playerView.player.volume == 0 ||
                        hasSticker {
                        self.addBackgroundMusic(
                            forVideo: videoURL,
                            hasSticker: hasSticker,
                            stickerLayer: stickerLayer
                        )
                        return
                    }
                    self.editFinishCallBack(videoURL)
                    self.backAction()
                }else {
                    self.showErrorHUD()
                }
            }
        }else {
            if backgroundMusicPath != nil ||
                playerView.player.volume == 0 ||
                hasSticker {
                ProgressHUD.showLoading(addedTo: view, text: "视频导出中".localized, animated: true)
                let videoURL = PhotoTools.getVideoTmpURL()
                if FileManager.default.fileExists(atPath: videoURL.path) {
                    try? FileManager.default.removeItem(at: videoURL)
                }
                exportSession = AssetManager.exportVideoURL(
                    forVideo: avAsset,
                    toFile: videoURL,
                    exportPreset: config.exportPresetName)
                { [weak self] (url, error) in
                    if let url = url {
                        self?.addBackgroundMusic(
                            forVideo: url,
                            hasSticker: hasSticker,
                            stickerLayer: stickerLayer
                        )
                    }else {
                        self?.showErrorHUD()
                    }
                }
                return
            }
            delegate?.videoEditorViewController(didFinishWithUnedited: self)
            backAction()
        }
    }
    func addBackgroundMusic(
        forVideo videoURL: URL,
        hasSticker: Bool,
        stickerLayer: CALayer)
    {
        DispatchQueue.global().async {
            var audioURL: URL?
            if let musicPath = self.backgroundMusicPath {
                audioURL = URL(fileURLWithPath: musicPath)
            }
            var overlayImages: [UIImage] = []
            if hasSticker {
                if let image = stickerLayer.convertedToImage() {
                    overlayImages.append(image)
                }
                stickerLayer.contents = nil
            }
            var overlayImage: UIImage? = nil
            if !overlayImages.isEmpty {
                overlayImage = UIImage.merge(images: overlayImages)
            }
            self.exportSession = PhotoTools.videoAddBackgroundMusic(
                forVideo: videoURL,
                overlayImage: overlayImage,
                audioURL: audioURL,
                audioVolume: self.backgroundMusicVolume,
                originalAudioVolume: self.playerView.player.volume,
                presentName: self.config.exportPresetName)
            { [weak self] (url) in
                if let url = url {
                    self?.editFinishCallBack(url)
                    self?.backAction()
                }else {
                    self?.showErrorHUD()
                }
            }
        }
    }
    func showErrorHUD() {
        ProgressHUD.hide(forView: view, animated: true)
        ProgressHUD.showWarning(addedTo: view, text: "导出失败".localized, animated: true, delayHide: 1.5)
    }
    func editFinishCallBack(_ videoURL: URL) {
        if let currentCropOffset = currentCropOffset {
            rotateBeforeStorageData = cropView.getRotateBeforeData(offsetX: currentCropOffset.x, validX: currentValidRect.minX, validWidth: currentValidRect.width)
        }
        rotateBeforeData = cropView.getRotateBeforeData()
        var cropData: VideoCropData?
        if let startTime = playerView.playStartTime,
           let endTime = playerView.playEndTime,
           let rotateBeforeStorageData = rotateBeforeStorageData,
           let rotateBeforeData = rotateBeforeData {
            cropData = VideoCropData(
                startTime: startTime.seconds,
                endTime: endTime.seconds,
                preferredTimescale: avAsset.duration.timescale,
                cropingData: .init(offsetX: rotateBeforeStorageData.0, validX: rotateBeforeStorageData.1, validWidth: rotateBeforeStorageData.2),
                cropRectData: .init(offsetX: rotateBeforeData.0, validX: rotateBeforeData.1, validWidth: rotateBeforeData.2)
            )
        }
        var backgroundMusicURL: URL?
        if let audioPath = backgroundMusicPath {
            backgroundMusicURL = URL(fileURLWithPath: audioPath)
        }
        let stickerData = playerView.stickerView.stickerData()
        let editResult = VideoEditResult(
            editedURL: videoURL,
            cropData: cropData,
            videoSoundVolume: playerView.player.volume,
            backgroundMusicURL: backgroundMusicURL,
            backgroundMusicVolume: backgroundMusicVolume,
            stickerData: stickerData
        )
        delegate?.videoEditorViewController(self, didFinish: editResult)
    }
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolOptions) {
        playerView.stickerView.isUserInteractionEnabled = false
        playerView.stickerView.deselectedSticker()
        if model.type == .music {
            if let shouldClick = delegate?.videoEditorViewController(shouldClickMusicTool: self),
               !shouldClick {
                return
            }
            if musicView.musics.isEmpty {
                if let editorDelegate = delegate {
                    if editorDelegate.videoEditorViewController(
                        self,
                        loadMusic: {
                            [weak self] infos in
                            self?.musicView.reloadData(infos: infos)
                    }) {
                        musicView.showLoading()
                    }
                }else {
                    let infos = PhotoTools.defaultMusicInfos()
                    if infos.isEmpty {
                        ProgressHUD.showWarning(addedTo: view, text: "暂无配乐".localized, animated: true, delayHide: 1.5)
                        return
                    }else {
                        musicView.reloadData(infos: infos)
                    }
                }
            }
            isMusicState = !isMusicState
            musicView.reloadContentOffset()
            updateMusicView()
            hidenTopView()
        }else if model.type == .cropping {
            croppingAction()
        }else if model.type == .chartlet {
            chartletView.firstRequest()
            showChartlet = true
            hidenTopView()
            showChartletView()
        }else if model.type == .text {
            playerView.stickerView.isUserInteractionEnabled = true
            if config.text.modalPresentationStyle == .fullScreen {
                isPresentText = true
            }
            let textVC = EditorStickerTextViewController(config: config.text)
            textVC.delegate = self
            let nav = EditorStickerTextController(rootViewController: textVC)
            nav.modalPresentationStyle = config.text.modalPresentationStyle
            present(nav, animated: true, completion: nil)
        }
    }
    
    func showChartletView() {
        UIView.animate(withDuration: 0.25) {
            self.setChartletViewFrame()
        }
    }
    func hiddenChartletView() {
        UIView.animate(withDuration: 0.25) {
            self.setChartletViewFrame()
        }
    }
    
    func updateMusicView() {
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = self.isMusicState ? 0 : 1
            self.setMusicViewFrame()
        } completion: { (_) in
            self.toolView.alpha = self.isMusicState ? 0 : 1
            self.setMusicViewFrame()
        }
    }
    
    /// 进入裁剪界面
    func croppingAction() {
        if state == .normal {
            beforeStartTime = playerView.playStartTime
            beforeEndTime = playerView.playEndTime
            if let offset = currentCropOffset {
                cropView.collectionView.setContentOffset(offset, animated: false)
            }else {
                let insetLeft = cropView.collectionView.contentInset.left
                let insetTop = cropView.collectionView.contentInset.top
                cropView.collectionView.setContentOffset(CGPoint(x: -insetLeft, y: -insetTop), animated: false)
            }
            if currentValidRect.equalTo(.zero) {
                cropView.resetValidRect()
            }else {
                cropView.frameMaskView.validRect = currentValidRect
                cropView.startLineAnimation(at: playerView.player.currentTime())
            }
            playerView.playStartTime = cropView.getStartTime(real: true)
            playerView.playEndTime = cropView.getEndTime(real: true)
            cropConfirmView.isHidden = false
            cropView.isHidden = false
            cropView.updateTimeLabels()
            pState = .cropping
            if currentValidRect.equalTo(.zero) {
                playerView.resetPlay()
                startPlayTimer()
            }
            hidenTopView()
            UIView.animate(withDuration: 0.25, delay: 0, options: [.layoutSubviews]) {
                self.setupScrollViewScale()
                self.cropView.alpha = 1
                self.cropConfirmView.alpha = 1
            } completion: { (isFinished) in
            }
        }
    }
}

extension VideoEditorViewController: EditorStickerTextViewControllerDelegate {
    
    func stickerTextViewController(_ controller: EditorStickerTextViewController, didFinish stickerItem: EditorStickerItem) {
        playerView.stickerView.update(item: stickerItem)
    }
    
    func stickerTextViewController(_ controller: EditorStickerTextViewController, didFinish stickerText: EditorStickerText) {
        let item = EditorStickerItem(image: stickerText.image, text: stickerText)
        playerView.stickerView.add(sticker: item, isSelected: false)
    }
}
