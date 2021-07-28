//
//  WeChatMometViewController.swift
//  Example
//
//  Created by Slience on 2021/7/28.
//

import UIKit
import HXPHPicker

class WeChatMometViewController: UIViewController, PhotoPickerControllerDelegate {
    var isImage = false
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didImageViewClick)))
        view.backgroundColor = .systemYellow
        return view
    }()
    @objc func didImageViewClick() {
        isImage = true
        let config = PhotoTools.getWXPickerConfig(isMoment: true)
        config.selectOptions = .photo
        config.selectMode = .single
        config.photoSelectionTapAction = .openEditor
        config.photoEditor.cropping.aspectRatioType = .ratio_1x1
        config.photoEditor.cropping.fixedRatio = true
        config.photoEditor.fixedCropState = true
        let pickerController = PhotoPickerController(picker: config, delegate: self)
        
        present(pickerController, animated: true, completion: nil)
    }
    
    func pickerController(_ pickerController: PhotoPickerController,
                          didFinishSelection result: PickerResult) {
        if isImage {
            imageView.image = result.photoAssets.first?.originalImage
        }else {
            pickerController.dismiss(animated: true) {
                let vc = WeChatMometPublishViewController()
                let nav = UINavigationController(rootViewController: vc)
                
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WeChat-Moment"
        view.backgroundColor = .white
        view.addSubview(imageView)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .done, target: self, action: #selector(didPublishClick))
    }
    
    @objc func didPublishClick() {
        let config = PhotoTools.getWXPickerConfig(isMoment: true)
        config.maximumSelectedVideoDuration = 60
        let pickerController = PhotoPickerController(picker: config, delegate: self)
        pickerController.autoDismiss = false
        present(pickerController, animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 0, width: view.width, height: view.width)
    }
}
