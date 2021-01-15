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
    
    /// 裁剪配置
    public lazy var cropping: VideoCroppingConfiguration = .init()
    
    /// 裁剪视图配置
    public lazy var cropView: VideoCropConfirmViewConfiguration = .init()
    
    /// 工具视图配置
    public lazy var toolView: EditorToolViewConfiguration = .init()
}
