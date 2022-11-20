//
//  TestEditorViewController.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import HXPHPicker
import AVFoundation

class TestEditorViewController: UIViewController {
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.addSubview(editorView)
        return view
    }()
    
    lazy var editorView: EditorView = {
        let view = EditorView()
        view.contentInsets = { _ in
            .init(top: 20, left: 20, bottom: 20 + UIDevice.bottomMargin, right: 20)
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = .init(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 88, width: view.hx.width, height: 0)
        contentView.hx.height = view.hx.height - contentView.hx.y
        editorView.frame = contentView.bounds
    }
    
    var isEdit: Bool = false
    
    @objc
    func showAlert() {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if isEdit {
            if editorView.state == .edit {
                if editorView.canReset {
                    alert.addAction(.init(title: "还原", style: .default, handler: { [weak self] _ in
                        self?.editorView.reset(true)
                    }))
                }
                alert.addAction(.init(title: "确认编辑", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                    self?.editorView.finishEdit(true)
                }))
                alert.addAction(.init(title: "取消编辑", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                    self?.editorView.cancelEdit(true)
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
                    self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    self?.editorView.startEdit(true)
                }))
            }
        }
        if editorView.state == .normal {
            alert.addAction(.init(title: "选择编辑的照片/视频", style: .default, handler: { [weak self] _ in
                self?.openPickerController()
            }))
        }
        alert.addAction(.init(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc
    func openPickerController() {
        let config = PickerConfiguration()
        config.selectMode = .single
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
                        let image = UIImage(contentsOfFile: urlResult.url.path)
                        self.editorView.setImage(image)
                    }else {
                        let avAsset = AVAsset(url: urlResult.url)
                        let coverImage = PhotoTools.getVideoThumbnailImage(videoURL: urlResult.url, atTime: 0.1)
                        self.editorView.setVideoAsset(avAsset, coverImage: coverImage)
                        self.editorView.loadVideoAsset()
                    }
                default:
                    break
                }
                self.isEdit = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
