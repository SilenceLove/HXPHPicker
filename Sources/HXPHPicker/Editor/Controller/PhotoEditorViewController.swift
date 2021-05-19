//
//  PhotoEditorViewController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import Photos

public protocol PhotoEditorViewControllerDelegate: AnyObject {
    
    /// 编辑完成
    /// - Parameters:
    ///   - photoEditorViewController: 对应的 PhotoEditorViewController
    ///   - result: 编辑后的数据
    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinish result: PhotoEditResult)
    
    /// 点击完成按钮，但是照片未编辑
    /// - Parameters:
    ///   - photoEditorViewController: 对应的 PhotoEditorViewController
    func photoEditorViewController(didFinishWithUnedited photoEditorViewController: PhotoEditorViewController)
    
    /// 取消编辑
    /// - Parameter photoEditorViewController: 对应的 PhotoEditorViewController
    func photoEditorViewController(didCancel photoEditorViewController: PhotoEditorViewController)
}
public extension PhotoEditorViewControllerDelegate {
    func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinish result: PhotoEditResult) {}
    func photoEditorViewController(didFinishWithUnedited photoEditorViewController: PhotoEditorViewController) {}
    func photoEditorViewController(didCancel photoEditorViewController: PhotoEditorViewController) {}
}
open class PhotoEditorViewController: BaseViewController {
    
    public weak var delegate: PhotoEditorViewControllerDelegate?
    
    public let config: PhotoEditorConfiguration
    
    public var state: State = .normal
    
    public var image: UIImage!
    
    public var editResult: PhotoEditResult?
    
    public init(image: UIImage, editResult: PhotoEditResult? = nil, config: PhotoEditorConfiguration) {
        self.image = image
        self.config = config
        self.editResult = editResult
        super.init(nibName: nil, bundle: nil)
    }
    public var isPicker: Bool = false
    
    #if HXPICKER_ENABLE_PICKER
    public var photoAsset: PhotoAsset!
    public init(photoAsset: PhotoAsset, editResult: PhotoEditResult? = nil, config: PhotoEditorConfiguration) {
        isPicker = true
        self.config = config
        self.editResult = editResult
        self.photoAsset = photoAsset
        super.init(nibName: nil, bundle: nil)
    }
    func requestImage() {
        if photoAsset.mediaSubType == .localImage {
            requestAssetCompletion(image: photoAsset.localImage!)
        }else {
            _=ProgressHUD.showLoading(addedTo: view, animated: true)
            photoAsset.requestAssetImageURL(filterEditor: true) { [weak self] (imageUrl) in
                DispatchQueue.global().async {
                    if let imageUrl = imageUrl, let image = UIImage.init(contentsOfFile: imageUrl.path)?.scaleSuitableSize() {
                        DispatchQueue.main.async {
                            ProgressHUD.hide(forView: self?.view, animated: true)
                            self?.requestAssetCompletion(image: image)
                        }
                    }else {
                        DispatchQueue.main.async {
                            ProgressHUD.hide(forView: self?.view, animated: true)
                            PhotoTools.showConfirm(viewController: self, title: "提示".localized, message: "图片获取失败!".localized, actionTitle: "确定".localized) { (alertAction) in
                                self?.didBackClick()
                            }
                        }
                    }
                }
            }
        }
    }
    func requestAssetCompletion(image: UIImage) {
        if imageInitializeCompletion == true {
            imageView.setImage(image)
            if let editedData = editResult?.editedData {
                imageView.setEditedData(editedData: editedData)
            }
            if state == .cropping {
                imageView.startCropping(true)
                croppingAction()
            }
        }
        self.image = image
    }
    #endif
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: PhotoEditorView = {
        let imageView = PhotoEditorView.init(cropConfig: config.cropConfig)
        imageView.editorDelegate = self
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap(tap:)))
        imageView.addGestureRecognizer(singleTap)
        return imageView
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
    lazy var cropConfirmView: EditorCropConfirmView = {
        let cropConfirmView = EditorCropConfirmView.init(config: config.cropConfimView, showReset: true)
        cropConfirmView.alpha = 0
        cropConfirmView.isHidden = true
        cropConfirmView.delegate = self
        return cropConfirmView
    }()
    lazy var toolView: EditorToolView = {
        let toolView = EditorToolView.init(config: config.toolView)
        toolView.delegate = self
        return toolView
    }()
    
    lazy var topView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let cancelBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 57, height: 44))
        cancelBtn.setImage(UIImage.image(for: "hx_editor_back"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(didBackClick), for: .touchUpInside)
        view.addSubview(cancelBtn)
        return view
    }()
    @objc func didBackClick() {
        delegate?.photoEditorViewController(didCancel: self)
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    
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
    
    lazy var cropToolView: PhotoEditorCropToolView = {
        var showRatios = true
        if config.cropConfig.fixedRatio || config.cropConfig.isRoundCrop {
            showRatios = false
        }
        let view = PhotoEditorCropToolView.init(showRatios: showRatios)
        view.delegate = self
        view.themeColor = config.cropConfig.aspectRatioSelectedColor
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    
    var imageInitializeCompletion = false
    var orientationDidChange: Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if config.fixedCropState {
            state = .cropping
            toolView.alpha = 0
            toolView.isHidden = true
            topView.alpha = 0
            topView.isHidden = true
        }else {
            state = config.state
        }
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.addSubview(imageView)
        view.addSubview(toolView)
        view.addSubview(cropConfirmView)
        view.addSubview(cropToolView)
        view.layer.addSublayer(topMaskLayer)
        view.addSubview(topView)
        
        #if HXPICKER_ENABLE_PICKER
        if isPicker {
            requestImage()
        }
        #endif
    }
    open override func deviceOrientationWillChanged(notify: Notification) {
        imageView.reset(false)
        imageView.finishCropping(false)
        if config.fixedCropState {
            return
        }
        state = .normal
        croppingAction()
    }
    open override func deviceOrientationDidChanged(notify: Notification) {
        orientationDidChange = true
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolView.frame = CGRect(x: 0, y: view.height - UIDevice.bottomMargin - 50, width: view.width, height: 50 + UIDevice.bottomMargin)
        toolView.reloadContentInset()
        topView.width = view.width
        topView.height = navigationController?.navigationBar.height ?? 44
        let cancelButton = topView.subviews.first
        cancelButton?.x = UIDevice.leftMargin
        if let modalPresentationStyle = navigationController?.modalPresentationStyle, UIDevice.isPortrait {
            if modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom {
                topView.y = UIDevice.generalStatusBarHeight
            }
        }else if (modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom) && UIDevice.isPortrait {
            topView.y = UIDevice.generalStatusBarHeight
        }
        topMaskLayer.frame = CGRect(x: 0, y: 0, width: view.width, height: topView.frame.maxY + 10)
        cropConfirmView.frame = toolView.frame
        cropToolView.frame = CGRect(x: 0, y: cropConfirmView.y - 60, width: view.width, height: 60)
        cropToolView.updateContentInset()
        imageView.frame = view.bounds
        if !imageInitializeCompletion {
            if !isPicker || image != nil {
                imageView.setImage(image)
                if let editedData = editResult?.editedData {
                    imageView.setEditedData(editedData: editedData)
                }
                if state == .cropping {
                    imageView.startCropping(true)
                    croppingAction()
                }
            }
            imageInitializeCompletion = true
        }
        if orientationDidChange {
            imageView.orientationDidChange()
            if config.fixedCropState {
                imageView.startCropping(false)
            }
            orientationDidChange = false
        }
    }
    open override var prefersStatusBarHidden: Bool {
        return config.prefersStatusBarHidden
    }
    open override var prefersHomeIndicatorAutoHidden: Bool {
        false
    }
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .all
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController != self && navigationController?.viewControllers.contains(self) == false {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.viewControllers.count == 1 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
}

// MARK: EditorToolViewDelegate
extension PhotoEditorViewController: EditorToolViewDelegate {
     
    func toolView(didFinishButtonClick toolView: EditorToolView) {
        editResources()
    }
    func editResources() {
        if imageView.canReset() || imageView.imageView.hasCropping {
            _=ProgressHUD.showLoading(addedTo: view, animated: true)
            imageView.cropping { [weak self] (result) in
                if let result = result, let self = self {
                    self.delegate?.photoEditorViewController(self, didFinish: result)
                    self.didBackClick()
                }else {
                    ProgressHUD.hide(forView: self?.view, animated: true)
                    ProgressHUD.showWarning(addedTo: self?.view, text: "图片获取失败!".localized, animated: true, delayHide: 1.5)
                }
            }
        }else {
            delegate?.photoEditorViewController(didFinishWithUnedited: self)
            didBackClick()
        }
    }
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolOptions) {
        if model.type == .cropping {
            state = .cropping
            imageView.startCropping(true)
            croppingAction()
        }
    }
    
    func croppingAction() {
        if state == .cropping {
            cropConfirmView.isHidden = false
            cropToolView.isHidden = false
            hidenTopView()
        }else {
            showTopView()
        }
        UIView.animate(withDuration: 0.25) {
            self.cropConfirmView.alpha = self.state == .cropping ? 1 : 0
            self.cropToolView.alpha = self.state == .cropping ? 1 : 0
        } completion: { (isFinished) in
            if self.state == .normal {
                self.cropConfirmView.isHidden = true
                self.cropToolView.isHidden = true
            }
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
}

// MARK: EditorCropConfirmViewDelegate
extension PhotoEditorViewController: EditorCropConfirmViewDelegate {
    
    /// 点击完成按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didFinishButtonClick cropConfirmView: EditorCropConfirmView) {
        if config.fixedCropState {
            imageView.imageView.finishCropping(false, completion: nil, updateCrop: false)
            editResources()
            return
        }
        state = .normal
        imageView.finishCropping(true)
        croppingAction()
    }
    
    /// 点击还原按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didResetButtonClick cropConfirmView: EditorCropConfirmView) {
        cropConfirmView.resetButton.isEnabled = false
        imageView.reset(true)
        cropToolView.reset(animated: true)
    }
    
    /// 点击取消按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didCancelButtonClick cropConfirmView: EditorCropConfirmView) {
        if config.fixedCropState {
            didBackClick()
            return
        }
        state = .normal
        imageView.cancelCropping(true)
        croppingAction()
    }
}

// MARK: PhotoEditorViewDelegate
extension PhotoEditorViewController: PhotoEditorViewDelegate {
    func checkResetButton() {
        cropConfirmView.resetButton.isEnabled = imageView.canReset()
    }
    func editorView(willBeginEditing editorView: PhotoEditorView) {
    }
    
    func editorView(didEndEditing editorView: PhotoEditorView) {
        checkResetButton()
    }
    
    func editorView(willAppearCrop editorView: PhotoEditorView) {
        cropToolView.reset(animated: false)
        cropConfirmView.resetButton.isEnabled = false
    }
    
    func editorView(didAppear editorView: PhotoEditorView) {
        checkResetButton()
    }
    
    func editorView(willDisappearCrop editorView: PhotoEditorView) {
        
    }
    
    func editorView(didDisappearCrop editorView: PhotoEditorView) {
        
    }
}

extension PhotoEditorViewController: PhotoEditorCropToolViewDelegate {
    func cropToolView(didRotateButtonClick cropToolView: PhotoEditorCropToolView) {
        imageView.rotate()
    }
    
    func cropToolView(didMirrorHorizontallyButtonClick cropToolView: PhotoEditorCropToolView) {
        imageView.mirrorHorizontally(animated: true)
    }
    
    func cropToolView(didChangedAspectRatio cropToolView: PhotoEditorCropToolView, at model: PhotoEditorCropToolModel) {
        imageView.changedAspectRatio(of: CGSize(width: model.widthRatio, height: model.heightRatio))
    }
}
