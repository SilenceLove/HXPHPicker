//
//  EditorType.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/14.
//

import Foundation


/// 视频编辑控制器的状态
public extension VideoEditorViewController {
    enum State: Int {
        case normal     //!< 正常状态
        case cropping   //!< 裁剪状态
    }
}

/// 编辑工具模型
public extension EditorToolOptions {
    enum `Type` {
        case cropping   //!< 裁剪
    }
}
