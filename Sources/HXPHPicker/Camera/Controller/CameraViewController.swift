//
//  CameraViewController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/30.
//

import UIKit
import CoreLocation
import AVFoundation

/// 需要有导航栏
open class CameraViewController: BaseViewController {
    public weak var delegate: CameraViewControllerDelegate?
    
    /// 相机配置
    public let config: CameraConfiguration
    /// 相机类型
    public let type: CameraController.CameraType
    /// 自动dismiss
    public var autoDismiss: Bool = true
    
    public init(
        config: CameraConfiguration,
        type: CameraController.CameraType,
        delegate: CameraViewControllerDelegate? = nil
    ) {
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        self.config = config
        self.type = type
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var previewView: CameraPreviewView = {
        let view = CameraPreviewView(
            config: config
        )
        view.delegate = self
        return view
    }()
    
    lazy var cameraManager: CameraManager = {
        let manager = CameraManager(config: config)
        return manager
    }()
    
    lazy var bottomView: CameraBottomView = {
        let view = CameraBottomView(tintColor: config.tintColor)
        view.delegate = self
        return view
    }()
    
    lazy var topMaskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(true)
        return layer
    }()
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    var didLocation: Bool = false
    var currentLocation: CLLocation?
    
    private var requestCameraSuccess = false
    private var currentZoomFacto: CGFloat = 1
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        DeviceOrientationHelper
            .shared
            .startDeviceOrientationNotifier()
        view.addSubview(previewView)
        view.addSubview(bottomView)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            PhotoTools.showConfirm(
                viewController: self,
                title: "相机不可用!".localized,
                message: nil,
                actionTitle: "确定".localized
            ) { _ in
                self.dismiss(animated: true)
            }
            return
        }
        AssetManager.requestCameraAccess { isGranted in
            if isGranted {
                self.setupCamera()
            }else {
                PhotoTools.showNotCameraAuthorizedAlert(viewController: self)
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc
    func willEnterForeground() {
        if requestCameraSuccess {
            try? cameraManager.addMovieOutput()
        }
    }
    
    @objc
    func didSwichCameraClick() {
        do {
            try cameraManager.switchCameras()
        } catch {
            print(error)
            ProgressHUD.showWarning(
                addedTo: view,
                text: "摄像头切换失败!".localized,
                animated: true,
                delayHide: 1.5
            )
        }
        resetZoom()
    }
    
    func resetZoom() {
        try? cameraManager.rampZoom(to: 1)
        previewView.effectiveScale = 1
    }
    
    func setupCamera() {
        DispatchQueue.global().async {
            do {
                self.cameraManager.session.beginConfiguration()
                try self.cameraManager.startSession()
                var needAddAudio = false
                switch self.type {
                case .photo:
                    try self.cameraManager.addPhotoOutput()
                    self.cameraManager.addVideoOutput()
                case .video:
                    try self.cameraManager.addMovieOutput()
                    needAddAudio = true
                case .all:
                    try self.cameraManager.addPhotoOutput()
                    try self.cameraManager.addMovieOutput()
                    needAddAudio = true
                }
                if !needAddAudio {
                    self.addOutputCompletion()
                }else {
                    self.addAudioInput()
                }
            } catch {
                print(error)
                self.cameraManager.session.commitConfiguration()
                DispatchQueue.main.async {
                    PhotoTools.showConfirm(
                        viewController: self,
                        title: "相机初始化失败!".localized,
                        message: nil,
                        actionTitle: "确定".localized
                    ) { _ in
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func addAudioInput() {
        AVCaptureDevice.requestAccess(for: .audio) { isGranted in
            DispatchQueue.global().async {
                if isGranted {
                    do {
                        try self.cameraManager.addAudioInput()
                    } catch {
                        DispatchQueue.main.async {
                            ProgressHUD.showWarning(
                                addedTo: self.view,
                                text: "麦克风添加失败，录制视频会没有声音哦!".localized,
                                animated: true,
                                delayHide: 1.5
                            )
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        PhotoTools.showAlert(
                            viewController: self,
                            title: "无法使用麦克风".localized,
                            message: "请在设置-隐私-相机中允许访问麦克风".localized,
                            leftActionTitle: "取消".localized,
                        leftHandler: { alertAction in
                            ProgressHUD.showWarning(
                                addedTo: self.view,
                                text: "麦克风添加失败，录制视频会没有声音哦!".localized,
                                animated: true,
                                delayHide: 1.5
                            )
                        },
                            rightActionTitle: "设置".localized
                        ) { alertAction in
                            PhotoTools.openSettingsURL()
                        }
                    }
                }
                self.addOutputCompletion()
            }
        }
    }
    
    func addOutputCompletion() {
        self.cameraManager.session.commitConfiguration()
        self.cameraManager.startRunning()
        self.previewView.setSession(self.cameraManager.session)
        self.requestCameraSuccess = true
        DispatchQueue.main.async {
            self.sessionCompletion()
        }
    }
    
    func sessionCompletion() {
        if cameraManager.canSwitchCameras() {
            view.layer.addSublayer(topMaskLayer)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: "hx_camera_overturn".image,
                style: .plain,
                target: self,
                action: #selector(didSwichCameraClick)
            )
        }
        previewView.setupGestureRecognizer()
        bottomView.addGesture(for: type)
        startLocation()
    }
    
    @objc open override func deviceOrientationDidChanged(notify: Notification) {
        previewView.resetOrientation()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSubviews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let nav = navigationController else {
            return
        }
        let navHeight = nav.navigationBar.frame.maxY
        nav.navigationBar.setBackgroundImage(
            UIImage.image(
                for: .clear,
                havingSize: CGSize(width: view.width, height: navHeight)
            ),
            for: .default
        )
        nav.navigationBar.shadowImage = UIImage()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if requestCameraSuccess {
            cameraManager.startRunning()
            bottomView.isGestureEnable = true
        }
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PhotoManager.shared.saveCameraPreview()
    }
    
    func layoutSubviews() {
        if UIDevice.isPad || !UIDevice.isPortrait {
            if UIDevice.isPad {
                previewView.frame = view.bounds
            }else {
                previewView.size = CGSize(width: view.height * 16 / 9, height: view.height)
                previewView.center = CGPoint(x: view.width * 0.5, y: view.height * 0.5)
            }
        }else {
            previewView.size = CGSize(width: view.width, height: view.width / 9 * 16)
            previewView.center = CGPoint(x: view.width * 0.5, y: view.height * 0.5)
        }
        
        let bottomHeight: CGFloat = 130
        let bottomY: CGFloat
        if UIDevice.isPortrait && !UIDevice.isPad {
            let bottomMargin: CGFloat
            if UIDevice.isAllIPhoneX {
                bottomMargin = 110
            }else {
                bottomMargin = 150
            }
            bottomY = view.height - bottomMargin - previewView.y
        }else {
            bottomY = view.height - bottomHeight
        }
        bottomView.frame = CGRect(
            x: 0,
            y: bottomY,
            width: view.width,
            height: bottomHeight
        )
        if let nav = navigationController {
            topMaskLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: nav.navigationBar.frame.maxY + 10
            )
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        config.prefersStatusBarHidden
    }
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        if allowLocation && didLocation {
            locationManager.stopUpdatingLocation()
        }
        DeviceOrientationHelper.shared.stopDeviceOrientationNotifier()
    }
}

extension CameraViewController: CameraBottomViewDelegate {
    func bottomView(beganTakePictures bottomView: CameraBottomView) {
        if !cameraManager.session.isRunning {
            return
        }
        cameraManager.capturePhoto { [weak self] data in
            guard let self = self else { return }
            if let data = data ,
               var image = UIImage(data: data) {
                if image.imageOrientation != .up,
                   let nImage = image.normalizedImage() {
                    image = nImage
                }
                self.resetZoom()
                self.cameraManager.stopRunning()
                self.previewView.resetMask(image)
                self.bottomView.isGestureEnable = false
                self.saveCameraImage(image)
                #if HXPICKER_ENABLE_EDITOR
                if self.config.allowsEditing {
                    self.openPhotoEditor(image)
                }else {
                    self.openPhotoResult(image)
                }
                #else
                self.openPhotoResult(image)
                #endif
            }else {
                ProgressHUD.showWarning(
                    addedTo: self.view,
                    text: "拍摄失败!".localized,
                    animated: true,
                    delayHide: 1.5
                )
            }
        }
    }
    func bottomView(beganRecording bottomView: CameraBottomView) {
        cameraManager.startRecording { [weak self] duration in
            self?.bottomView.startTakeMaskLayerPath(duration: duration)
        } progress: { progress, time in
            
        } completion: { [weak self] videoURL, error in
            guard let self = self else { return }
            self.bottomView.stopRecord()
            if error == nil {
                self.resetZoom()
                self.cameraManager.stopRunning()
                self.previewView.resetMask(PhotoTools.getVideoThumbnailImage(videoURL: videoURL, atTime: 0.1))
                self.bottomView.isGestureEnable = false
                self.saveCameraVideo(videoURL)
                #if HXPICKER_ENABLE_EDITOR
                if self.config.allowsEditing {
                    self.openVideoEditor(videoURL)
                }else {
                    self.openVideoResult(videoURL)
                }
                #else
                self.openVideoResult(videoURL)
                #endif
            }else {
                let text: String
                if let error = error as NSError?,
                   error.code == 110 {
                    text = String(format: "拍摄时长不足%d秒".localized, arguments: [1])
                }else {
                    text = "拍摄失败!".localized
                }
                ProgressHUD.showWarning(
                    addedTo: self.view,
                    text: text,
                    animated: true,
                    delayHide: 1.5
                )
            }
        }
    }
    func bottomView(endRecording bottomView: CameraBottomView) {
        cameraManager.stopRecording()
    }
    func bottomView(longPressDidBegan bottomView: CameraBottomView) {
        currentZoomFacto = previewView.effectiveScale
    }
    func bottomView(_ bottomView: CameraBottomView, longPressDidChanged scale: CGFloat) {
        let remaining = previewView.maxScale - currentZoomFacto
        let zoomScale = currentZoomFacto + remaining * scale
        cameraManager.zoomFacto = zoomScale
    }
    func bottomView(longPressDidEnded bottomView: CameraBottomView) {
        previewView.effectiveScale = cameraManager.zoomFacto
    }
    func bottomView(didBackButton bottomView: CameraBottomView) {
        delegate?.cameraViewController(didCancel: self)
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func openPhotoResult(_ image: UIImage) {
        let vc = CameraResultViewController(
            image: image,
            tintColor: config.tintColor
        )
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: false)
    }
    func openVideoResult(_ videoURL: URL) {
        let vc = CameraResultViewController(
            videoURL: videoURL,
            tintColor: config.tintColor
        )
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension CameraViewController: CameraPreviewViewDelegate {
    func previewView(didPreviewing previewView: CameraPreviewView) {
        bottomView.hiddenTip()
    }
    func previewView(_ previewView: CameraPreviewView, pinchGestureScale scale: CGFloat) {
        cameraManager.zoomFacto = scale
    }
    
    func previewView(_ previewView: CameraPreviewView, tappedToFocusAt point: CGPoint) {
        try? cameraManager.expose(at: point)
    }
    
    func previewView(didLeftSwipe previewView: CameraPreviewView) {
        
    }
    
    func previewView(didRightSwipe previewView: CameraPreviewView) {
        
    }
}

extension CameraViewController: CameraResultViewControllerDelegate {
    func cameraResultViewController(
        didDone cameraResultViewController: CameraResultViewController
    ) {
        let vc = cameraResultViewController
        switch vc.type {
        case .photo:
            if let image = vc.image {
                didFinish(withImage: image)
            }
        case .video:
            if let videoURL = vc.videoURL {
                didFinish(withVideo: videoURL)
            }
        }
    }
    func didFinish(withImage image: UIImage) {
        delegate?.cameraViewController(
            self,
            didFinishWithImage: image,
            location: currentLocation
        )
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    func didFinish(withVideo videoURL: URL) {
        delegate?.cameraViewController(
            self,
            didFinishWithVideo: videoURL,
            location: currentLocation
        )
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    func saveCameraImage(_ image: UIImage) {
        let previewSize = previewView.size
        DispatchQueue.global().async {
            let thumbImage = image.scaleToFillSize(size: previewSize)
            PhotoManager.shared.cameraPreviewImage = thumbImage
        }
    }
    func saveCameraVideo(_ videoURL: URL) {
        PhotoTools.getVideoThumbnailImage(
            url: videoURL,
            atTime: 0.1
        ) { _, image in
            if let image = image {
                PhotoManager.shared.cameraPreviewImage = image
            }
        }
    }
}
