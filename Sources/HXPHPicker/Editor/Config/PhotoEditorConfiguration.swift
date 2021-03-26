//
//  PhotoEditorConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/20.
//

import UIKit

open class PhotoEditorConfiguration: EditorConfiguration {
    
    /// 工具视图配置
    public lazy var toolView: EditorToolViewConfiguration = .init()
    
    /// 裁剪确认视图配置
    public lazy var cropView: CropConfirmViewConfiguration = .init()
     
}
