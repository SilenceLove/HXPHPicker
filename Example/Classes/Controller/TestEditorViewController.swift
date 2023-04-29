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
    
    var image: UIImage? = .init(named: "wx_head_icon")
    var videoURL: URL!
    
    var imageResult: EditResult.Image?
    var videoResult: EditResult.Video?
    
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
        if let result = imageResult {
            view.setImage(image)
            view.setAdjustmentData(result.data)
        }else if let result = videoResult {
            view.setAVAsset(.init(url: videoURL))
            view.setAdjustmentData(result.data)
            view.loadVideo()
        }else {
            view.setImage(image)
            view.state = .edit
        }
//        view.isResetIgnoreFixedRatio = false
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
        if editorView.type != .unknown {
            func preview(_ isPreview: Bool) {
                if self.editorView.type == .video {
                    self.editorView.cancelVideoCroped()
                    self.view.hx.show()
                    self.editorView.cropVideo(
                        factor: .init(preset: .ratio_960x540, quality: 6),
                        progress: { progress in
                        print("video_progress: \(progress)")
                    }, completion: { [weak self] videoResult in
                        guard let self = self else { return }
                        switch videoResult {
                        case .success(let result):
                            self.view.hx.hide()
                            print(result)
                            self.editorView.pauseVideo()
                            if !isPreview {
                                let vc = TestEditorViewController()
                                vc.videoURL = self.videoURL
                                vc.videoResult = result
                                self.navigationController?.pushViewController(vc, animated: true)
                                return
                            }
                            PhotoBrowser.show(
                                [.init(.init(videoURL: result.url))],
                                transitionalImage: PhotoTools.getVideoThumbnailImage(videoURL: result.url, atTime: 0.1)
                            ) { _ in
                                self.editorView.finalView
                            } longPressHandler: { _, photoAsset, photoBrowser in
                                photoBrowser.view.hx.show()
                                photoAsset.saveToSystemAlbum { phAsset in
                                    photoBrowser.view.hx.hide()
                                    if phAsset == nil {
                                        photoBrowser.view.hx.showWarning(text: "保存失败", delayHide: 1.5)
                                    }else {
                                        photoBrowser.view.hx.showSuccess(text: "保存成功", delayHide: 1.5)
                                    }
                                }
                            }
                        case .failure(let error):
                            print("error: \(error)")
                            if !error.isCancel {
                                self.view.hx.hide()
                            }
                        }
                    })
                    return
                }
                self.view.hx.show()
                self.editorView.cropImage({ [weak self] imageResult in
                    guard let self = self else { return }
                    self.view.hx.hide()
                    switch imageResult {
                    case .success(let result):
                        print(result)
                        if !isPreview {
                            let vc = TestEditorViewController()
                            vc.image = self.image
                            vc.imageResult = result
                            self.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                        PhotoBrowser.show(
                            [.init(.init(result.url))],
                            transitionalImage: result.image
                        ) { _ in
                            self.editorView.finalView
                        } longPressHandler: { _, photoAsset, photoBrowser in
                            photoBrowser.view.hx.show()
                            photoAsset.saveToSystemAlbum { phAsset in
                                photoBrowser.view.hx.hide()
                                if phAsset == nil {
                                    photoBrowser.view.hx.showWarning(text: "保存失败", delayHide: 1.5)
                                }else {
                                    photoBrowser.view.hx.showSuccess(text: "保存成功", delayHide: 1.5)
                                }
                            }
                        }
                    case .failure(let error):
                        print("error: \(error)")
                    }
                })
            }
            if editorView.isCropedImage || editorView.isCropedVideo {
                alert.addAction(.init(title: "裁剪", style: .default, handler: { _ in
                    preview(false)
                }))
                alert.addAction(.init(title: "预览", style: .default, handler: { _ in
                    preview(true)
                }))
            }
        }
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
                    self?.presendAlert(textAlert)
                }))
                alert.addAction(.init(title: "向左旋转90°", style: .default, handler: { [weak self] _ in
                    self?.editorView.rotateLeft(true)
                }))
                alert.addAction(.init(title: "向右旋转90°", style: .default, handler: { [weak self] _ in
                    self?.editorView.rotateRight(true)
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self?.presendAlert(alert)
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
                self?.presendAlert(alert)
            }))
            alert.addAction(.init(title: editorView.isFixedRatio ? "取消固定比例" : "固定比例", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.editorView.isFixedRatio = !self.editorView.isFixedRatio
                if !self.editorView.isFixedRatio && self.editorView.isRoundMask {
                    self.editorView.setRoundMask(false, animated: true)
                }
            }))
            alert.addAction(.init(title: editorView.isRoundMask ? "取消圆切" : "圆切", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if self.editorView.isRoundMask {
                    self.editorView.isResetIgnoreFixedRatio = true
                    self.editorView.setRoundMask(false, animated: true)
                }else {
                    self.editorView.isFixedRatio = false
                    self.editorView.isResetIgnoreFixedRatio = false
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
                    self.editorView.isResetIgnoreFixedRatio = true
                    self.editorView.setAspectRatio(.init(width: widthRatio, height: heightRatio), animated: true)
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self?.presendAlert(alert)
            }))
            alert.addAction(.init(title: editorView.isShowScaleSize ? "隐藏比例大小" : "显示比例大小", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.editorView.isShowScaleSize = !self.editorView.isShowScaleSize
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
                self?.presendAlert(maskAlert)
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
                self?.presendAlert(maskAlert)
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
            alert.addAction(.init(title: "添加贴纸", style: .default, handler: { [weak self] _ in
                let config = PickerConfiguration()
                config.selectMode = .single
                config.selectOptions = [.gifPhoto, .video]
                config.previewView.bottomView.isHiddenOriginalButton = true
                Photo.picker(config) { [weak self] pickerResult, _ in
                    guard let self = self else {
                        return
                    }
                    let asset = pickerResult.photoAssets.first
                    self.view.hx.show()
                    asset?.getAssetURL {
                        self.view.hx.hide()
                        switch $0 {
                        case .success(let urlResult):
                            if let image = UIImage(contentsOfFile: urlResult.url.path) {
                                self.editorView.addSticker(image, isSelected: true)
                            }
                        default:
                            break
                        }
                    }
                }
            }))
            alert.addAction(.init(title: "添加音乐贴纸", style: .default, handler: { [weak self] _ in
                let audioUrl = Bundle.main.url(forResource: "少女的祈祷", withExtension: "mp3")!
                let lyricUrl = Bundle.main.url(forResource: "少女的祈祷", withExtension: nil)!
                let lrc = try! String(contentsOfFile: lyricUrl.path)
                let music = VideoEditorMusicInfo(
                    audioURL: audioUrl,
                    lrc: lrc
                )
                self?.editorView.addSticker(music, isSelected: true)
                PhotoManager.shared.playMusic(filePath: audioUrl.path) {
                    
                }
            }))
            alert.addAction(.init(title: !editorView.isDrawEnabled ? "开启绘画" : "关闭绘画", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.editorView.isDrawEnabled = !self.editorView.isDrawEnabled
            }))
            alert.addAction(.init(title: "绘画设置", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(.init(title: "画笔宽度", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let alert = UIAlertController.init(title: "画笔宽比", message: nil, preferredStyle: .alert)
                    alert.addTextField { (textfield) in
                        textfield.keyboardType = .numberPad
                        textfield.placeholder = "输入画笔宽比"
                    }
                    alert.addAction(
                        UIAlertAction(
                            title: "确定",
                            style: .default,
                            handler: { [weak self] (action) in
                                guard let self = self,
                                      let textFiled = alert.textFields?.first,
                                      let text = textFiled.text,
                                      !text.isEmpty else {
                                    return
                                }
                                let lineWidth = CGFloat(Int(text)!)
                                self.editorView.drawLineWidth = lineWidth
                    }))
                    alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                    self.presendAlert(alert)
                }))
                alert.addAction(.init(title: "画笔颜色", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    if #available(iOS 14.0, *) {
                        let vc = UIColorPickerViewController()
                        vc.selectedColor = self.editorView.drawLineColor
                        vc.delegate = self
                        self.present(vc, animated: true, completion: nil)
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                self.presendAlert(alert)
            }))
            if self.editorView.isCanUndoDraw {
                alert.addAction(.init(title: "撤销上一次的绘画", style: .default, handler: { [weak self] _ in
                    self?.editorView.undoDraw()
                }))
                alert.addAction(.init(title: "撤销所有的绘画", style: .default, handler: { [weak self] _ in
                    self?.editorView.undoAllDraw()
                }))
            }
            if editorView.type == .image {
                alert.addAction(.init(title: !editorView.isMosaicEnabled ? "开启马赛克涂抹" : "关闭马赛克涂抹", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.editorView.isMosaicEnabled = !self.editorView.isMosaicEnabled
                }))
                alert.addAction(.init(title: "马赛克涂抹设置", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                    alert.addAction(.init(title: "马赛克宽度", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        let alert = UIAlertController.init(title: "马赛克宽比", message: nil, preferredStyle: .alert)
                        alert.addTextField { (textfield) in
                            textfield.keyboardType = .numberPad
                            textfield.placeholder = "输入马赛克宽比"
                        }
                        alert.addAction(
                            UIAlertAction(
                                title: "确定",
                                style: .default,
                                handler: { [weak self] (action) in
                                    guard let self = self,
                                          let textFiled = alert.textFields?.first,
                                          let text = textFiled.text,
                                          !text.isEmpty else {
                                        return
                                    }
                                    let mosaicWidth = CGFloat(Int(text)!)
                                    self.editorView.mosaicWidth = mosaicWidth
                        }))
                        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                        self.presendAlert(alert)
                    }))
                    alert.addAction(.init(title: "涂抹宽度", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        let alert = UIAlertController.init(title: "涂抹宽比", message: nil, preferredStyle: .alert)
                        alert.addTextField { (textfield) in
                            textfield.keyboardType = .numberPad
                            textfield.placeholder = "输入涂抹宽比"
                        }
                        alert.addAction(
                            UIAlertAction(
                                title: "确定",
                                style: .default,
                                handler: { [weak self] (action) in
                                    guard let self = self,
                                          let textFiled = alert.textFields?.first,
                                          let text = textFiled.text,
                                          !text.isEmpty else {
                                        return
                                    }
                                    let smearWidth = CGFloat(Int(text)!)
                                    self.editorView.smearWidth = smearWidth
                        }))
                        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                        self.presendAlert(alert)
                    }))
                    alert.addAction(.init(title: "切换至" + (self.editorView.mosaicType == .mosaic ? "涂抹" : "马赛克"), style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        if self.editorView.mosaicType == .mosaic {
                            self.editorView.mosaicType = .smear
                        }else {
                            self.editorView.mosaicType = .mosaic
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                    self.presendAlert(alert)
                }))
                if self.editorView.isCanUndoMosaic {
                    alert.addAction(.init(title: "撤销上一次的马赛克涂抹", style: .default, handler: { [weak self] _ in
                        self?.editorView.undoMosaic()
                    }))
                    alert.addAction(.init(title: "撤销所有的马赛克涂抹", style: .default, handler: { [weak self] _ in
                        self?.editorView.undoAllMosaic()
                    }))
                }
            }
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
                    self.editorView.isResetIgnoreFixedRatio = false
                }
                self.editorView.startEdit(true)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            }))
        }
        alert.addAction(.init(title: "选择编辑的照片/视频", style: .default, handler: { [weak self] _ in
            self?.openPickerController()
        }))
        alert.addAction(.init(title: "取消", style: .cancel))
        presendAlert(alert)
    }
    
    @objc
    func openPickerController() {
        let config = PickerConfiguration()
        config.selectMode = .single
        config.selectOptions = [.gifPhoto, .video]
        config.previewView.bottomView.isHiddenOriginalButton = true
        hx.present(
            picker: config
        ) { [weak self] result, _ in
            guard let self = self else { return }
            let asset = result.photoAssets.first
            self.view.hx.show()
            asset?.getAssetURL {
                self.view.hx.hide()
                switch $0 {
                case .success(let urlResult):
                    if urlResult.mediaType == .photo {
                        let imageData = try? Data(contentsOf: urlResult.url)
                        self.image = UIImage(contentsOfFile: urlResult.url.path)
                        self.editorView.setImageData(imageData)
//                        let image = UIImage(contentsOfFile: urlResult.url.path)
//                        self.editorView.setImage(image)
//                        self.editorView.updateImage(image)
                    }else {
                        self.videoURL = urlResult.url
                        let avAsset = AVAsset(url: urlResult.url)
                        let coverImage = avAsset.hx.getImage(at: 0.1)
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
        if editorView.state == .edit {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    open override var prefersHomeIndicatorAutoHidden: Bool {
        false
    }
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .all
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

@available(iOS 14.0, *)
extension TestEditorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        editorView.drawLineColor = color
    }
}

extension UIViewController {
    func presendAlert(_ alert: UIAlertController) {
        if UIDevice.isPad {
            let pop = alert.popoverPresentationController
            pop?.permittedArrowDirections = .any
            pop?.sourceView = view
            pop?.sourceRect = CGRect(
                x: view.hx.width * 0.5,
                y: view.hx.height,
                width: 0,
                height: 0
            )
        }
        present(alert, animated: true)
    }
}
