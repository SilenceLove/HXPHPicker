//
//  EditorToolModel.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import Foundation

public class EditorToolModel: NSObject {
    
    /// icon图标
    public var imageName: String = "Unknown"
    
    /// 类型
    public var type: EditorToolType = .cropping
}

/// 视频编辑控制器的状态
public enum VideoEditorViewControllerState {
    case normal //!< 正常状态
    case cropping   //!< 裁剪状态
}
