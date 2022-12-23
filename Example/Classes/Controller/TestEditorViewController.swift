//
//  TestEditorViewController.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import HXPHPicker
import AVFoundation

class TestEditorViewController: BaseViewController {
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.addSubview(editorView)
        return view
    }()
    
    lazy var editorView: EditorView = {
        let view = EditorView()
        view.backgroundColor = self.view.backgroundColor
        
        // 这样设置边距 进入/退出 编辑状态不会有 缩小/放大 动画
//        view.contentInset = .init(top: 20, left: 20, bottom: 20 + UIDevice.bottomMargin, right: 20)
        // 这样设置边距 进入/退出 编辑状态会有 缩小/放大 动画
        view.editContentInset = { _ in
            .init(top: 20, left: UIDevice.leftMargin + 20, bottom: 20 + UIDevice.bottomMargin, right: UIDevice.rightMargin + 20)
        }
        view.maskType = .blurEffect(style: .light)
        if let path = Bundle.main.path(forResource: "videoeditormatter", ofType: "MP4") {
            let url = URL(fileURLWithPath: path)
            view.setAVAsset(.init(url: url))
            view.loadVideo()
        }else {
            view.setImage(.init(named: "wx_head_icon"))
        }
        view.state = .edit
//        view.ignoreFixedRatio = false
//        view.setRoundMask(animated: false)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "菜单",
            style: .plain,
            target: self,
            action: #selector(showAlert)
        )
        view.addSubview(contentView)
    }
    
    var orientationDidChanged: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = .init(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 88, width: view.hx.width, height: 0)
        contentView.hx.height = view.hx.height - contentView.hx.y
        editorView.frame = contentView.bounds
        if orientationDidChanged {
            editorView.update()
            orientationDidChanged = false
        }
    }
    
    public override func deviceOrientationWillChanged(notify: Notification) {
        orientationDidChanged = true
    }
    
    @objc
    func showAlert() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if editorView.state == .edit {
            if editorView.canReset {
                alert.addAction(.init(title: "还原", style: .default, handler: { [weak self] _ in
                    self?.editorView.reset(true)
                }))
            }
            alert.addAction(.init(title: "旋转", style: .default, handler: { [weak self] _ in
                let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(.init(title: "旋转任意角度", style: .default, handler: { [weak self] _ in
                    let textAlert = UIAlertController(title: "输入旋转的角度", message: nil, preferredStyle: .alert)
                    textAlert.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    textAlert.addAction(.init(title: "确定", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        let textFiled = textAlert.textFields?.first
                        let text = textFiled?.text ?? "0"
                        let angle = CGFloat(Int(text) ?? 0)
                        self.editorView.rotate(angle, animated: true)
                    }))
                    textAlert.addAction(.init(title: "取消", style: .cancel))
                    self?.present(textAlert, animated: true)
                }))
                alert.addAction(.init(title: "向左旋转90°", style: .default, handler: { [weak self] _ in
                    self?.editorView.rotateLeft(true)
                }))
                alert.addAction(.init(title: "向右旋转90°", style: .default, handler: { [weak self] _ in
                    self?.editorView.rotateRight(true)
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }))
            alert.addAction(.init(title: "镜像", style: .default, handler: { [weak self] _ in
                let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(.init(title: "水平镜像", style: .default, handler: { [weak self] _ in
                    self?.editorView.mirrorHorizontally(true)
                }))
                alert.addAction(.init(title: "垂直镜像", style: .default, handler: { [weak self] _ in
                    self?.editorView.mirrorVertically(true)
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }))
            alert.addAction(.init(title: editorView.isFixedRatio ? "取消固定比例" : "固定比例", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.editorView.isFixedRatio = !self.editorView.isFixedRatio
            }))
            
            alert.addAction(.init(title: editorView.isRoundMask ? "取消圆切" : "圆切", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if self.editorView.isRoundMask {
                    self.editorView.ignoreFixedRatio = true
                    self.editorView.setRoundMask(false, animated: true)
                }else {
                    self.editorView.isFixedRatio = false
                    self.editorView.ignoreFixedRatio = false
                    self.editorView.setRoundMask(true, animated: true)
                }
            }))
            alert.addAction(.init(title: "修改裁剪框比例", style: .default, handler: { [weak self] _ in
                let alert = UIAlertController.init(title: "修改比例", message: nil, preferredStyle: .alert)
                alert.addTextField { (textfield) in
                    textfield.keyboardType = .numberPad
                    textfield.placeholder = "输入宽度比"
                }
                alert.addTextField { (textfield) in
                    textfield.keyboardType = .numberPad
                    textfield.placeholder = "输入高度比"
                }
                alert.addAction(
                    UIAlertAction(
                        title: "确定",
                        style: .default,
                        handler: { [weak self] (action) in
                            guard let self = self else { return }
                    let widthTextFiled = alert.textFields?.first
                    let widthRatioStr = widthTextFiled?.text ?? "0"
                    let widthRatio = Int(widthRatioStr.count == 0 ? "0" : widthRatioStr)!
                    let heightTextFiled = alert.textFields?.last
                    let heightRatioStr = heightTextFiled?.text ?? "0"
                    let heightRatio = Int(heightRatioStr.count == 0 ? "0" : heightRatioStr)!
                    self.editorView.ignoreFixedRatio = true
                    self.editorView.setAspectRatio(.init(width: widthRatio, height: heightRatio), animated: true)
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }))
            alert.addAction(.init(title: "添加蒙版", style: .default, handler: { [weak self] _ in
                let maskAlert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                maskAlert.addAction(.init(title: "Love", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "love", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "Love Text", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "love_text", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "Stars", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "stars", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "Text", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "text", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "Portrait", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "portrait", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "QIY", style: .default, handler: { [weak self] _ in
                    if let path = Bundle.main.path(forResource: "qiy", ofType: "png"),
                       let image = UIImage(contentsOfFile: path) {
                        self?.editorView.setMaskImage(image, animated: true)
                        self?.editorView.setAspectRatio(.init(width: image.size.width, height: image.size.height), animated: true)
                        self?.editorView.isFixedRatio = true
                    }
                }))
                maskAlert.addAction(.init(title: "移除蒙版", style: .destructive, handler: { [weak self] _ in
                    self?.editorView.setMaskImage(nil, animated: true)
                    self?.editorView.isFixedRatio = false
                }))
                maskAlert.addAction(.init(title: "取消", style: .cancel))
                self?.present(maskAlert, animated: true)
            }))
            alert.addAction(.init(title: "修改遮罩类型", style: .default, handler: { [weak self] _ in
                let maskAlert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                maskAlert.addAction(.init(title: "blackColor", style: .default, handler: { [weak self] _ in
                    self?.editorView.setMaskType(.customColor(color: .black.withAlphaComponent(0.7)), animated: true)
                }))
                maskAlert.addAction(.init(title: "redColor", style: .default, handler: { [weak self] _ in
                    self?.editorView.setMaskType(.customColor(color: .red.withAlphaComponent(0.7)), animated: true)
                }))
                maskAlert.addAction(.init(title: "darkBlurEffect", style: .default, handler: { [weak self] _ in
                    self?.editorView.setMaskType(.blurEffect(style: .dark), animated: true)
                }))
                maskAlert.addAction(.init(title: "lightBlurEffect", style: .default, handler: { [weak self] _ in
                    self?.editorView.setMaskType(.blurEffect(style: .light), animated: true)
                }))
                maskAlert.addAction(.init(title: "取消", style: .cancel))
                self?.present(maskAlert, animated: true)
            }))
            alert.addAction(.init(title: "确认编辑", style: .default, handler: { [weak self] _ in
                self?.editorView.finishEdit(true)
                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }))
            alert.addAction(.init(title: "取消编辑", style: .default, handler: { [weak self] _ in
                self?.editorView.cancelEdit(true)
                self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }))
        }else {
            if editorView.type == .video {
                if !editorView.isVideoPlaying {
                    alert.addAction(.init(title: "播放视频", style: .default, handler: { [weak self] _ in
                        self?.editorView.playVideo()
                    }))
                }else {
                    alert.addAction(.init(title: "暂停视频", style: .default, handler: { [weak self] _ in
                        self?.editorView.pauseVideo()
                    }))
                }
            }
            alert.addAction(.init(title: "进入编辑模式", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if self.editorView.isRoundMask {
                    self.editorView.ignoreFixedRatio = false
                }
                self.editorView.startEdit(true)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            }))
        }
        alert.addAction(.init(title: "选择编辑的照片/视频", style: .default, handler: { [weak self] _ in
            self?.openPickerController()
        }))
        alert.addAction(.init(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc
    func openPickerController() {
        let config = PickerConfiguration()
        config.selectMode = .single
        config.selectOptions = [.gifPhoto, .video]
        config.previewView.bottomView.originalButtonHidden = true
        hx.present(
            picker: config
        ) { [weak self] result, _ in
            guard let self = self else { return }
            let asset = result.photoAssets.first
            asset?.getAssetURL {
                switch $0 {
                case .success(let urlResult):
                    if urlResult.mediaType == .photo {
                        let imageData = try? Data(contentsOf: urlResult.url)
                        self.editorView.setImageData(imageData)
//                        let image = UIImage(contentsOfFile: urlResult.url.path)
//                        self.editorView.setImage(image)
//                        self.editorView.updateImage(image)
                    }else {
                        let avAsset = AVAsset(url: urlResult.url)
                        let coverImage = PhotoTools.getVideoThumbnailImage(videoURL: urlResult.url, atTime: 0.1)
                        self.editorView.setAVAsset(avAsset, coverImage: coverImage)
                        self.editorView.loadVideo()
                    }
                default:
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
