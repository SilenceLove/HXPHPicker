//
//  EditorToolViewConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit

public class EditorToolViewConfiguration: NSObject {
    
    /// 工具栏item数据
    public lazy var toolModelArray: [EditorToolModel] = {
        let cropModel = EditorToolModel.init()
        cropModel.imageName = "hx_editor_video_crop"
        cropModel.type = .crop
        let models: [EditorToolModel] = [cropModel]
        return models
    }()
    
    /// 完成按钮标题颜色
    public lazy var finishButtonTitleColor: UIColor = {
        return .white
    }()
    
    /// 暗黑风格下完成按钮标题颜色
    public lazy var finishButtonTitleDarkColor: UIColor = {
        return .white
    }()
    
    /// 完成按钮的背景颜色
    public lazy var finishButtonBackgroundColor: UIColor = {
        return .systemTintColor
    }()
    
    /// 暗黑风格下完成按钮选的背景颜色
    public lazy var finishButtonDarkBackgroundColor: UIColor = {
        return .systemTintColor
    }()
}
