//
//  PickerTypes.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/7.
//

import Foundation
 
public enum SelectType: Int {
    case photo = 0      //!< 只显示图片
    case video = 1      //!< 只显示视频
    case any = 2        //!< 任何类型
}

public enum SelectMode: Int {
    case single = 0         //!< 单选模式
    case multiple = 1       //!< 多选模式
}

public enum QuickSelectMode: Int {
    case none = 0       //!< 正常模式（点击选择框选中，点击cell进入预览界面）
    case photo = 1      //!< 照片点击cell或选择按钮就进入选中状态，不会跳转预览界面
    case video = 2      //!< 视频点击cell或选择按钮就进入选中状态，不会跳转预览界面（如果允许编辑视频的话会跳转编辑界面）
    case any = 3        //!< 照片和视频点击cell或选择按钮就进入选中状态，不会跳转预览界面
}

public extension PhotoAsset {
    enum MediaType: Int {
        case photo = 0      //!< 照片
        case video = 1      //!< 视频
    }

    enum MediaSubType: Int {
        case image = 0          //!< 手机相册里的图片
        case imageAnimated = 1  //!< 手机相册里的动图
        case livePhoto = 2      //!< 手机相册里的LivePhoto
        case localImage = 3     //!< 本地图片
        case video = 4          //!< 手机相册里的视频
        case localVideo = 5     //!< 本地视频
    }
    enum DownloadStatus: Int {
        case unknow         //!< 未知，不用下载或还未开始下载
        case succeed        //!< 下载成功
        case downloading    //!< 下载中
        case canceled       //!< 取消下载
        case failed         //!< 下载失败
    }
}

public enum AlbumShowMode: Int {
    case normal = 0         //!< 正常展示
    case popup = 1          //!< 弹出展示
}

public extension PhotoPickerViewController {
    enum CancelType {
        case text   //!< 文本
        case image  //!< 图片
    }
    enum CancelPosition {
        case left   //!< 左边
        case right  //!< 右边
    }
}

public extension PhotoPickerSelectBoxView {
    enum Style: Int {
        case number //!< 数字
        case tick   //!< √
    }
}

public extension PhotoPreviewViewController {
    enum VideoPlayType {
        case normal     //!< 正常状态，不自动播放
        case auto       //!< 自动播放
        case once       //!< 自动播放一次
    }
}

public extension PickerResult {
    enum URLType {
        case photo  //!< 照片
        case video  //!< 视频
        case any    //!< 任何类型
    }
}

extension PhotoManager {
    enum CameraAlbumLocal: String {
        case identifier = "HXCameraAlbumLocalIdentifier"
        case identifierType = "HXCameraAlbumLocalIdentifierType"
        case language = "HXCameraAlbumLocalLanguage"
    }
}
