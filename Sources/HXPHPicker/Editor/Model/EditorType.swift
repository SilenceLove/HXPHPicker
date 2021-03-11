//
//  EditorType.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/14.
//

import Foundation


/// 视频编辑控制器的状态
public extension VideoEditorViewController {
    enum State {
        case normal //!< 正常状态
        case cropping   //!< 裁剪状态
    }
}
public extension EditorToolModel {
    enum `Type` {
        case cropping
    }
}
