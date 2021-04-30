//
//  EditorController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import AVKit

open class EditorController: UINavigationController {
    
    public weak var videoEditorDelegate: VideoEditorViewControllerDelegate? {
        didSet {
            let vc = viewControllers.first as? VideoEditorViewController
            vc?.delegate = videoEditorDelegate
        }
    }
    
    public weak var photoEditorDelegate: PhotoEditorViewControllerDelegate? {
        didSet {
            let vc = viewControllers.first as? PhotoEditorViewController
            vc?.delegate = photoEditorDelegate
        }
    }
    
    public var editorType: EditorType
    
    /// 根据UIImage初始化
    /// - Parameters:
    ///   - image: 对应的UIImage
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public init(image: UIImage, editResult: PhotoEditResult? = nil, config: PhotoEditorConfiguration) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        editorType = .photo
        self.config = config
        super.init(nibName: nil, bundle: nil)
        let photoEditorVC = PhotoEditorViewController.init(image: image, editResult: editResult, config: config)
        self.viewControllers = [photoEditorVC]
    }
    
    /// 根据视频地址初始化
    /// - Parameters:
    ///   - videoURL: 本地视频地址
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public convenience init(videoURL: URL, editResult: VideoEditResult? = nil, config: VideoEditorConfiguration) {
        self.init(avAsset: AVAsset.init(url: videoURL), editResult: editResult, config: config)
    }
    
    /// 根据AVAsset初始化
    /// - Parameters:
    ///   - avAsset: 视频对应的AVAsset对象
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public init(avAsset: AVAsset, editResult: VideoEditResult? = nil, config: VideoEditorConfiguration) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        editorType = .video
        self.config = config
        super.init(nibName: nil, bundle: nil)
        let videoEditorVC = VideoEditorViewController.init(avAsset: avAsset, editResult: editResult, config: config)
        self.viewControllers = [videoEditorVC]
    }
    
    #if HXPICKER_ENABLE_PICKER
    /// 根据PhotoAsset初始化
    /// - Parameters:
    ///   - photoAsset: 视频对应的PhotoAsset对象
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public init(photoAsset: PhotoAsset, editResult: VideoEditResult? = nil, config: VideoEditorConfiguration) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        editorType = .video
        self.config = config
        super.init(nibName: nil, bundle: nil)
        let videoEditorVC = VideoEditorViewController.init(photoAsset: photoAsset, editResult: editResult, config: config)
        self.viewControllers = [videoEditorVC]
    }
    
    /// 根据PhotoAsset初始化
    /// - Parameters:
    ///   - photoAsset: 照片对应的PhotoAsset对象
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public init(photoAsset: PhotoAsset, editResult: PhotoEditResult? = nil, config: PhotoEditorConfiguration) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        editorType = .photo
        self.config = config
        super.init(nibName: nil, bundle: nil)
        let photoEditorVC = PhotoEditorViewController.init(photoAsset: photoAsset, editResult: editResult, config: config)
        self.viewControllers = [photoEditorVC]
    }
    #endif
    
    /// 编辑器配置
    var config: EditorConfiguration
    
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        children.first
    } 
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
