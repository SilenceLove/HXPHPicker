//
//  VideoEditorViewController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import AVKit

public enum VideoEditorViewControllerState {
    case normal
    case crop
}
@objc public protocol VideoEditorViewControllerDelegate: NSObjectProtocol {
    @objc optional func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didFinish videoURL: URL)
    @objc optional func videoEditorViewController(didCancel videoEditorViewController: VideoEditorViewController)
}

open class VideoEditorViewController: BaseViewController {
    public weak var delegate: VideoEditorViewControllerDelegate?
    public var avAsset: AVAsset!
    public var config: VideoEditorConfiguration!
    public var state: VideoEditorViewControllerState = .normal
    
    public convenience init(videoURL: URL, config: VideoEditorConfiguration) {
        self.init(avAsset: AVAsset.init(url: videoURL), config: config)
    }
    public init(avAsset: AVAsset, config: VideoEditorConfiguration) {
        self.config = config
        self.avAsset = avAsset
        videoSize = PhotoTools.getVideoThumbnailImage(avAsset: avAsset, atTime: 0.1)?.size ?? .zero
        super.init(nibName: nil, bundle: nil)
    }
    
    var videoSize: CGSize = .zero
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap(tap:)))
        scrollView.addGestureRecognizer(singleTap)
        scrollView.addSubview(playerView)
        return scrollView
    }()
    @objc func singleTap(tap: UITapGestureRecognizer) {
        if state != .normal {
            return
        }
        if topView.isHidden == true {
            showTopView()
        }else {
            hidenTopView()
        }
    }
    func showTopView() {
        toolView.isHidden = false
        topView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 1
            self.topView.alpha = 1
            self.topMaskLayer.isHidden = false
        }
    }
    func hidenTopView() {
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 0
            self.topView.alpha = 0
            self.topMaskLayer.isHidden = true
        } completion: { (isFinished) in
            self.toolView.isHidden = true
            self.topView.isHidden = true
        }
    }
    lazy var playerView: VideoEditorPlayerView = {
        let playerView = VideoEditorPlayerView.init(avAsset: avAsset)
        playerView.delegate = self
        return playerView
    }()
    lazy var cropView: VideoEditorCropView = {
        let cropView = VideoEditorCropView.init(avAsset: avAsset, config: config.cropping)
        cropView.delegate = self
        cropView.alpha = 0
        cropView.isHidden = true
        return cropView
    }()
    lazy var toolView: EditorToolView = {
        let toolView = EditorToolView.init(config: config.toolView)
        toolView.delegate = self
        return toolView
    }()
    lazy var cropConfirmView: VideoEditorCropConfirmView = {
        let cropConfirmView = VideoEditorCropConfirmView.init(config: config.cropView)
        cropConfirmView.alpha = 0
        cropConfirmView.isHidden = true
        cropConfirmView.delegate = self
        return cropConfirmView
    }()
    lazy var topView: UIToolbar = {
        let topView = UIToolbar.init()
        topView.setShadowImage(UIImage.image(for: .clear, havingSize: .zero), forToolbarPosition: .any)
        topView.setBackgroundImage(UIImage.image(for: .clear, havingSize: .zero), forToolbarPosition: .any, barMetrics: .default)
        topView.backgroundColor = .clear
        topView.tintColor = .white
        let cancelItem = UIBarButtonItem.init(image: UIImage.image(for: "hx_editor_back"), style: .plain, target: self, action: #selector(didBackClick))
        topView.items = [cancelItem]
        return topView
    }()
    
    lazy var topMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer.init()
        layer.contentsScale = UIScreen.main.scale
        let blackColor = UIColor.black
        layer.colors = [blackColor.withAlphaComponent(0).cgColor,
                        blackColor.withAlphaComponent(0.15).cgColor,
                        blackColor.withAlphaComponent(0.35).cgColor,
                        blackColor.withAlphaComponent(0.6).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 0, y: 0)
        layer.locations = [0.15, 0.35, 0.6, 0.9]
        layer.borderWidth = 0.0
        return layer
    }()
    var orientationDidChange : Bool = true
    var currentValidRect: CGRect = .zero
    var currentCropOffset: CGPoint?
    var beforeStartTime: CMTime?
    var beforeEndTime: CMTime?
    var rotateBeforeStorageData: (CGFloat, CGFloat, CGFloat)?
    var rotateBeforeData: (CGFloat, CGFloat, CGFloat)?
    var playTimer: DispatchSourceTimer?
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func initView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(cropView)
        view.addSubview(cropConfirmView)
        view.addSubview(toolView)
        view.layer.addSublayer(topMaskLayer)
        view.addSubview(topView)
    }
    @objc func didBackClick() {
        delegate?.videoEditorViewController?(didCancel: self)
        backAction()
    }
    func backAction() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    open override func deviceOrientationWillChanged(notify: Notification) {
        if let currentCropOffset = currentCropOffset {
            rotateBeforeStorageData = cropView.getRotateBeforeData(offsetX: currentCropOffset.x, validX: currentValidRect.minX, validWidth: currentValidRect.width)
        }
        rotateBeforeData = cropView.getRotateBeforeData()
        playerView.pause()
        stopPlayTimer()
    }
    open override func deviceOrientationDidChanged(notify: Notification) {
        orientationDidChange = true
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolView.frame = CGRect(x: 0, y: view.height - UIDevice.bottomMargin - 50, width: view.width, height: 50 + UIDevice.bottomMargin)
        toolView.reloadContentInset()
        cropView.frame = CGRect(x: 0, y: toolView.y - 100, width: view.width, height: 100)
        topView.width = view.width
        topView.height = navigationController?.navigationBar.height ?? 44
        if let modalPresentationStyle = navigationController?.modalPresentationStyle, UIDevice.isPortrait {
            if modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom {
                topView.y = UIDevice.generalStatusBarHeight
            }
        }else if (modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom) && UIDevice.isPortrait {
            topView.y = UIDevice.generalStatusBarHeight
        }
        topMaskLayer.frame = CGRect(x: 0, y: 0, width: view.width, height: topView.frame.maxY + 10)
        if orientationDidChange {
            cropView.configData()
            if let rotateBeforeData = rotateBeforeData {
                cropView.layoutSubviews()
                cropView.rotateAfterSetData(offsetXScale: rotateBeforeData.0, validXScale: rotateBeforeData.1, validWithScale: rotateBeforeData.2)
                cropView.updateTimeLabels()
                playerView.playStartTime = cropView.getStartTime()
                playerView.playEndTime = cropView.getEndTime()
                if let rotateBeforeStorageData = rotateBeforeStorageData {
                    rotateAfterSetStorageData(offsetXScale: rotateBeforeStorageData.0, validXScale: rotateBeforeStorageData.1, validWithScale: rotateBeforeStorageData.2)
                }
                playerView.resetPlay()
                startPlayTimer()
            }
            DispatchQueue.main.async {
                self.orientationDidChange = false
            }
        }
        cropConfirmView.frame = toolView.frame
        setPlayerViewFrame()
        scrollView.frame = view.bounds
    }
    
    func rotateAfterSetStorageData(offsetXScale: CGFloat, validXScale: CGFloat, validWithScale: CGFloat) {
        let insert = cropView.collectionView.contentInset
        let offsetX = -insert.left + cropView.contentWidth * offsetXScale
        currentCropOffset = CGPoint(x: offsetX, y: -insert.top)
        let validInitialX = cropView.validRectX + cropView.imageWidth * 0.5
        let validMaxWidth = cropView.width - validInitialX * 2
        let validX = validMaxWidth * validXScale + validInitialX
        let vaildWidth = validMaxWidth * validWithScale
        currentValidRect = CGRect(x: validX, y: 0, width: vaildWidth, height: cropView.itemHeight)
    }
    func setPlayerViewFrame() {
        if state == .normal {
            playerView.frame = PhotoTools.transformImageSize(videoSize, to: view)
        }else {
            let leftMargin = 30 + UIDevice.leftMargin
            let width = view.width - leftMargin * 2
            var y: CGFloat = 10
            var height = cropView.y - y - 5
            if let modalPresentationStyle = navigationController?.modalPresentationStyle, UIDevice.isPortrait {
                if modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom { height -= UIDevice.generalStatusBarHeight
                    y += UIDevice.generalStatusBarHeight
                }
            }else if (modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom) && UIDevice.isPortrait {
                height -= UIDevice.generalStatusBarHeight
                y += UIDevice.generalStatusBarHeight
            }
            let rect = PhotoTools.transformImageSize(videoSize, toViewSize: CGSize(width: width, height: height), directions: [.horizontal])
            playerView.frame = CGRect(x: leftMargin + (width - rect.width) * 0.5, y: y + (height - rect.height) * 0.5, width: rect.width, height: rect.height)
        }
        scrollView.contentSize = playerView.size
    }
    open override var prefersStatusBarHidden: Bool {
        return config.prefersStatusBarHidden
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlayTimer()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController != self {
//            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//            navigationController?.navigationBar.shadowImage = nil
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage.image(for: UIColor.clear, havingSize: .zero), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage.image(for: UIColor.clear, havingSize: .zero)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    deinit {
        print("deinit \(self)")
    }
}

// MARK: VideoEditorPlayerViewDelegate
extension VideoEditorViewController: VideoEditorPlayerViewDelegate {
    func playerView(_ playerView: VideoEditorPlayerView, didPlayAt time: CMTime) {
        if state == .crop {
            cropView.startLineAnimation(at: time)
        }
    }
    
    func playerView(_ playerView: VideoEditorPlayerView, didPauseAt time: CMTime) {
        if state == .crop {
            cropView.stopLineAnimation()
        }
    }
}

// MARK: VideoEditorCropViewDelegate
extension VideoEditorViewController: VideoEditorCropViewDelegate {
    func cropView(_ cropView: VideoEditorCropView, didScrollAt time: CMTime) {
        pausePlay(at: time)
    }
    func cropView(_ cropView: VideoEditorCropView, endScrollAt time: CMTime) {
        startPlay(at: time)
    }
    func cropView(_ cropView: VideoEditorCropView, didChangedValidRectAt time: CMTime) {
        pausePlay(at: time)
    }
    func cropView(_ cropView: VideoEditorCropView, endChangedValidRectAt time: CMTime) {
        startPlay(at: time)
    }
    func cropView(_ cropView: VideoEditorCropView, progressLineDragEndAt time: CMTime) {
        
    }
    func cropView(_ cropView: VideoEditorCropView, progressLineDragBeganAt time: CMTime) {
        
    }
    func cropView(_ cropView: VideoEditorCropView, progressLineDragChangedAt time: CMTime) {
        
    }
    func pausePlay(at time: CMTime) {
        if state == .crop && !orientationDidChange {
            stopPlayTimer()
            playerView.shouldPlay = false
            playerView.playStartTime = time
            playerView.pause()
            playerView.seek(to: time)
            cropView.stopLineAnimation()
        }
    }
    func startPlay(at time: CMTime) {
        if state == .crop && !orientationDidChange {
            playerView.playStartTime = time
            playerView.playEndTime = cropView.getEndTime()
            playerView.resetPlay()
            playerView.shouldPlay = true
            startPlayTimer()
        }
    }
    func startPlayTimer(reset: Bool = true) {
        startPlayTimer(reset: reset, startTime: cropView.getStartTime(), endTime: cropView.getEndTime())
    }
    func startPlayTimer(reset: Bool = true, startTime: CMTime, endTime: CMTime) {
        stopPlayTimer()
        let playTimer = DispatchSource.makeTimerSource()
        var milliseconds: Double
        if reset {
            milliseconds = (endTime.seconds - startTime.seconds) * 1000
        }else {
            milliseconds = (playerView.player.currentTime().seconds - cropView.getStartTime().seconds) * 1000
        }
        playTimer.schedule(deadline: .now(), repeating: .milliseconds(Int(milliseconds)), leeway: .microseconds(0))
        playTimer.setEventHandler(handler: {
            DispatchQueue.main.async {
                self.playerView.resetPlay()
            }
        })
        playTimer.resume()
        self.playTimer = playTimer
    }
    func stopPlayTimer() {
        if let playTimer = playTimer {
            playTimer.cancel()
            self.playTimer = nil
        }
    }
}

// MARK: EditorToolViewDelegate
extension VideoEditorViewController: EditorToolViewDelegate {
    
    func toolView(didFinishButtonClick toolView: EditorToolView) {
        _ = ProgressHUD.showLoadingHUD(addedTo: view, text: "视频导出中", animated: true)
        if let startTime = playerView.playStartTime, let endTime = playerView.playEndTime {
            weak var weakSelf = self
            PhotoTools.exportEditVideo(for: avAsset, timeRang: CMTimeRange(start: startTime, end: endTime), presentName: config.exportPresetName) { (videoURL, error) in
                if let videoURL = videoURL {
                    weakSelf?.delegate?.videoEditorViewController?(weakSelf!, didFinish: videoURL)
                    weakSelf?.backAction()
                }else {
                    ProgressHUD.hideHUD(forView: weakSelf?.view, animated: true)
                    ProgressHUD.showWarningHUD(addedTo: weakSelf?.view, text: "导出失败", animated: true, delay: 1.5)
                }
            }
            
        }else {
            didBackClick()
        }
    }
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolModel) {
        if model.type == .crop {
            cropAction()
        }
    }
    
    func cropAction() {
        if state == .normal {
            navigationController?.setNavigationBarHidden(true, animated: true)
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
            playerView.playStartTime = cropView.getStartTime()
            playerView.playEndTime = cropView.getEndTime()
            cropConfirmView.isHidden = false
            cropView.isHidden = false
            cropView.updateTimeLabels()
            state = .crop
            if currentValidRect.equalTo(.zero) {
                playerView.resetPlay()
                startPlayTimer()
            }
            hidenTopView()
            UIView.animate(withDuration: 0.25) {
                self.cropView.alpha = 1
                self.cropConfirmView.alpha = 1
                self.setPlayerViewFrame()
            }
        }
    }
}

// MARK: VideoEditorCropConfirmViewDelegate
extension VideoEditorViewController: VideoEditorCropConfirmViewDelegate {
    
    func cropConfirmView(didFinishButtonClick cropConfirmView: VideoEditorCropConfirmView) {
        state = .normal
        cropView.stopScroll()
        currentCropOffset = cropView.collectionView.contentOffset
        currentValidRect = cropView.frameMaskView.validRect
        playerView.playStartTime = cropView.getStartTime()
        playerView.playEndTime = cropView.getEndTime()
        playerView.play()
        hiddenCropConfirmView()
    }
    func cropConfirmView(didCancelButtonClick cropConfirmView: VideoEditorCropConfirmView) {
        state = .normal
        cropView.stopScroll()
        cropView.stopLineAnimation()
        playerView.playStartTime = beforeStartTime
        playerView.playEndTime = beforeEndTime
        hiddenCropConfirmView()
        guard let currentCropOffset = currentCropOffset, cropView.collectionView.contentOffset.equalTo(currentCropOffset) && cropView.frameMaskView.validRect.equalTo(currentValidRect) else {
            cropView.stopLineAnimation()
            playerView.resetPlay()
            if let startTime = beforeStartTime, let endTime = beforeEndTime {
                startPlayTimer(startTime: startTime, endTime: endTime)
            }else {
                stopPlayTimer()
            }
            return
        }
    }
    
    func hiddenCropConfirmView() {
        showTopView()
        UIView.animate(withDuration: 0.25) {
            self.cropView.alpha = 0
            self.cropConfirmView.alpha = 0
            self.setPlayerViewFrame()
        } completion: { (isFinished) in
            self.cropView.isHidden = true
            self.cropConfirmView.isHidden = true
        }
    }
}
