//
//  CameraConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/30.
//

import UIKit
import AVFoundation

// MARK: 相机配置类
public class CameraConfiguration: BaseConfiguration {
    
    public enum DevicePosition {
        /// 后置
        case back
        /// 前置
        case front
    }
    
    /// 相机预算分辨率
    public var sessionPreset: AVCaptureSession.Preset = .high
    
    /// 摄像头默认位置
    public var position: DevicePosition = .back
    
    /// 视频最大录制时长
    public var videoMaximumDuration: TimeInterval = 60
    
    /// 主题色
    public var tintColor: UIColor = .systemTintColor {
        didSet { setupEditorColor() }
    }
    
    /// 摄像头最大缩放比例
    public var videoMaxZoomScale: CGFloat = 6
    
    #if HXPICKER_ENABLE_EDITOR
    /// 允许编辑
    /// true: 拍摄完成后会跳转到编辑界面
    public var allowsEditing: Bool = true
    
    /// 照片编辑器配置
    public lazy var photoEditor: PhotoEditorConfiguration = .init()
    
    /// 视频编辑器配置
    public lazy var videoEditor: VideoEditorConfiguration = .init()
    #endif
    
    /// 允许启动定位
    /// 需要在跳转之前请求授权，内部不会主动请求授权
    public var allowLocation: Bool = true
    
    public override init() {
        super.init()
        /// shouldAutorotate 能够旋转
        /// supportedInterfaceOrientations 支持的方向
        
        /// 隐藏状态栏
        prefersStatusBarHidden = true
        
        #if HXPICKER_ENABLE_EDITOR
        photoEditor.languageType = languageType
        videoEditor.languageType = languageType
        photoEditor.indicatorType = indicatorType
        videoEditor.indicatorType = indicatorType
        photoEditor.appearanceStyle = appearanceStyle
        videoEditor.appearanceStyle = appearanceStyle
        #endif
    }
    
    #if HXPICKER_ENABLE_EDITOR
    public override var languageType: LanguageType {
        didSet {
            photoEditor.languageType = languageType
            videoEditor.languageType = languageType
        }
    }
    public override var indicatorType: BaseConfiguration.IndicatorType {
        didSet {
            photoEditor.indicatorType = indicatorType
            videoEditor.indicatorType = indicatorType
        }
    }
    public override var appearanceStyle: AppearanceStyle {
        didSet {
            photoEditor.appearanceStyle = appearanceStyle
            videoEditor.appearanceStyle = appearanceStyle
        }
    }
    #endif
}

extension CameraConfiguration {
    #if HXPICKER_ENABLE_EDITOR
    func setupEditorColor() {
        videoEditor.cropView.finishButtonBackgroundColor = tintColor
        videoEditor.cropView.finishButtonDarkBackgroundColor = tintColor
        videoEditor.toolView.finishButtonBackgroundColor = tintColor
        videoEditor.toolView.finishButtonDarkBackgroundColor = tintColor
        videoEditor.toolView.toolSelectedColor = tintColor
        videoEditor.toolView.musicSelectedColor = tintColor
        videoEditor.music.tintColor = tintColor
        videoEditor.text.tintColor = tintColor
        
        photoEditor.toolView.toolSelectedColor = tintColor
        photoEditor.toolView.finishButtonBackgroundColor = tintColor
        photoEditor.toolView.finishButtonDarkBackgroundColor = tintColor
        photoEditor.cropConfimView.finishButtonBackgroundColor = tintColor
        photoEditor.cropConfimView.finishButtonDarkBackgroundColor = tintColor
        photoEditor.cropping.aspectRatioSelectedColor = tintColor
        photoEditor.filter = .init(
            infos: PhotoTools.defaultFilters(),
            selectedColor: tintColor
        )
        photoEditor.text.tintColor = tintColor
    }
    #endif
}
