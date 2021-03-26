//
//  PhotoEditorViewController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit

open class PhotoEditorViewController: BaseViewController {
    
    public let config: PhotoEditorConfiguration
    
    public var state: State = .normal
    
    public var image: UIImage
    
    public init(image: UIImage, config: PhotoEditorConfiguration) {
        self.image = image
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: EditorImageResizerView = {
        let imageView = EditorImageResizerView.init()
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
        let cropConfirmView = EditorCropConfirmView.init(config: config.cropView)
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
        dismiss(animated: true, completion: nil)
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
    var imageInitializeCompletion = false
    var orientationDidChange: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(toolView)
        view.addSubview(cropConfirmView)
        view.layer.addSublayer(topMaskLayer)
        view.addSubview(topView)
    }
    open override func deviceOrientationWillChanged(notify: Notification) {
        
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
        if let modalPresentationStyle = navigationController?.modalPresentationStyle, UIDevice.isPortrait {
            if modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom {
                topView.y = UIDevice.generalStatusBarHeight
            }
        }else if (modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom) && UIDevice.isPortrait {
            topView.y = UIDevice.generalStatusBarHeight
        }
        topMaskLayer.frame = CGRect(x: 0, y: 0, width: view.width, height: topView.frame.maxY + 10)
        cropConfirmView.frame = toolView.frame
        imageView.frame = view.bounds
        if !imageInitializeCompletion {
            imageView.setImage(image)
            imageInitializeCompletion = true
        }
    }
}

// MARK: EditorToolViewDelegate
extension PhotoEditorViewController: EditorToolViewDelegate {
     
    func toolView(didFinishButtonClick toolView: EditorToolView) {
        
    }
    
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolOptions) {
        if model.type == .cropping {
            state = .cropping
            croppingAction()
        }
    }
    
    func croppingAction() {
        imageView.setState(state == .cropping ? .cropping : .normal, animated: true)
        if state == .cropping {
            cropConfirmView.isHidden = false
            hidenTopView()
        }else {
            showTopView()
        }
        UIView.animate(withDuration: 0.25) {
            self.cropConfirmView.alpha = self.state == .cropping ? 1 : 0
        } completion: { (isFinished) in
            if self.state == .normal {
                self.cropConfirmView.isHidden = true
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
        state = .normal
        croppingAction()
    }
    
    /// 点击取消按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didCancelButtonClick cropConfirmView: EditorCropConfirmView) {
        state = .normal
        croppingAction()
    }
    
    func hiddenCropConfirmView() {
        
    }
}
