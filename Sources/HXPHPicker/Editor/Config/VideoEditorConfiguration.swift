//
//  VideoEditorConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//
import UIKit
import AVFoundation

open class VideoEditorConfiguration: EditorConfiguration {
     
    /// 导出的质量
    public var exportPresetName: String = AVAssetExportPresetHighestQuality
    
    /// 编辑控制器的默认状态
    public var defaultState: VideoEditorViewController.State = .normal
    
    /// 当编辑控制器默认状态是裁剪状态时是否必须裁剪视频
    public var mustBeTailored: Bool = true
    
    /// 裁剪配置
    public lazy var cropping: VideoCroppingConfiguration = .init()
    
    /// 裁剪视图配置
    public lazy var cropView: VideoCropConfirmViewConfiguration = .init()
    
    /// 工具视图配置
    public lazy var toolView: EditorToolViewConfiguration = .init()
    
    func mutableCopy() -> Any {
        let config = VideoEditorConfiguration.init()
        config.exportPresetName = exportPresetName
        config.defaultState = defaultState
        config.mustBeTailored = mustBeTailored
        config.cropping = cropping
        config.cropView = cropView
        config.toolView = toolView
        return config
    }
}
