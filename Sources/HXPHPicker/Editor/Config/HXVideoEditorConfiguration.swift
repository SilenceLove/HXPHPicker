//
//  HXVideoEditorConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//
import UIKit
import AVFoundation

public class HXVideoEditorConfiguration: HXEditorConfiguration {
     
    /// 导出的质量
    var exportPresetName: String = AVAssetExportPresetHighestQuality
    
    /// 裁剪配置
    public lazy var cropping: HXVideoCroppingConfiguration = .init()
    
    /// 裁剪视图配置
    public lazy var cropView: HXVideoCropConfirmViewConfiguration = .init()
    
    /// 工具视图配置
    public lazy var toolView: HXEditorToolViewConfiguration = .init()
}
