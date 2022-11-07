//
//  PickerConfiguration.swift
//  照片选择器-Swift
//
//  Created by Silence on 2020/11/9.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

public class PickerConfiguration: BaseConfiguration {
    
    /// Resource options, control the type of system album resources obtained
    /// .livePhoto .gifPhoto is a child of photo
    /// Only get still pictures and videos by default
    /// 资源可选项，控制获取系统相册资源的类型
    /// .livePhoto .gifPhoto 是photo的子项
    /// 默认只获取静态图片和视频
    public var selectOptions: PickerAssetOptions = [.photo, .video]
    
    /// select mode
    /// 选择模式
    public var selectMode: PickerSelectMode = .multiple
    
    /// Photos and videos can be selected together
    /// 照片和视频可以一起选择
    public var allowSelectedTogether: Bool = true
    
    /// Allow system photo library to load
    /// 允许加载系统照片库
    public var allowLoadPhotoLibrary: Bool = true
    
    /// When choosing a photo, first determine if it is on iCloud. If on iCloud, the resources on iCloud will be synchronized first
    /// If the network is disconnected or the system iCloud error occurs:
    /// true: selection failed
    /// fasle: Getting the original image will fail
    /// 选择照片时，先判断是否在iCloud上。如果在iCloud上会先同步iCloud上的资源
    /// 如果在断网或者系统iCloud出错的情况下:
    /// true: 选择失败
    /// fasle: 获取原始图片会失败
    public var allowSyncICloudWhenSelectPhoto: Bool = true
    
    /// Album display mode
    /// 相册展示模式
    public var albumShowMode: AlbumShowMode = .normal
    
    /// Whether to sort by creation time when getting the resource list
    /// 获取资源列表时是否按创建时间排序
    public var creationDate: Bool = false
    
    /// Resource list photo Cell click action
    /// 资源列表照片Cell点击动作
    public var photoSelectionTapAction: SelectionTapAction = .preview
    
    /// Resource list video Cell click action
    /// 资源列表视频Cell点击动作
    public var videoSelectionTapAction: SelectionTapAction = .preview
    
    /// The maximum number of photos that can be selected, if it is 0, there is no limit
    /// 最多可以选择的照片数，如果为0则不限制
    public var maximumSelectedPhotoCount: Int = 0
    
    /// The maximum number of videos that can be selected, if it is 0, there is no limit
    /// 最多可以选择的视频数，如果为0则不限制
    public var maximumSelectedVideoCount: Int = 0
    
    /// The maximum number of resources that can be selected, if it is 0, there is no limit
    /// 最多可以选择的资源数，如果为0则不限制
    public var maximumSelectedCount: Int = 9
    
    /// The maximum duration of video selection, if it is 0, there is no limit
    /// 视频最大选择时长，为0则不限制
    public var maximumSelectedVideoDuration: Int = 0
    
    /// The minimum length of video selection, if it is 0, there is no limit
    /// 视频最小选择时长，为0则不限制
    public var minimumSelectedVideoDuration: Int = 0
    
    /// The maximum file size of the video selection, if it is 0, there is no limit
    /// 视频选择的最大文件大小，为0则不限制
    /// 1000 = 1kb
    /// 1000000 = 1Mb 
    public var maximumSelectedVideoFileSize: Int = 0
    
    /// The maximum file size of the photo selection, if it is 0, there is no limit
    /// 照片选择的最大文件大小，为0则不限制
    /// 1000 = 1Kb
    /// 1000000 = 1Mb
    public var maximumSelectedPhotoFileSize: Int = 0
    
    #if HXPICKER_ENABLE_EDITOR
    /// Editable resource type
    /// Video editing allowed: When the selected video duration exceeds the limit, it will automatically enter the editing interface
    /// The configuration for displaying the edit button is: previewView.bottomView.editButtonHidden = false
    /// 可编辑资源类型
    /// 视频允许编辑：当选择的视频时长超过限制将自动进入编辑界面
    /// 显示编辑按钮的配置为：previewView.bottomView.editButtonHidden = false
    public var editorOptions: PickerAssetOptions = [.photo, .video]
    
    /// The maximum editing time of the video. If it is 0, there is no limit. If the limit is exceeded, it cannot be edited.
    /// 视频最大编辑时长，为0则不限制，超过限制不可编辑（视频时长超出最大选择时长才生效）
    public var maximumVideoEditDuration: Int = 0
    
    /// Video Editing Configuration
    /// 视频编辑配置
    public lazy var videoEditor: VideoEditorConfiguration = .init()
    
    /// Photo editing configuration
    /// 照片编辑配置
    public lazy var photoEditor: PhotoEditorConfiguration = .init()
    
    /// Jump editing interface to customize transition animation
    /// 跳转编辑界面自定义转场动画
    public var editorCustomTransition: Bool = true
    #endif
    
    /// Selector display style, effective when albumShowMode = .popup and fullscreen popup
    /// 选择器展示样式，当 albumShowMode = .popup 并且全屏弹出时有效
    public var pickerPresentStyle: PickerPresentStyle = .present
    
    /// Whether to allow the right swipe gesture to return when albumShowMode = .popup and fullscreen popup. Consistent with WeChat right swipe gesture return
    /// 当 albumShowMode = .popup 并且全屏弹出时，是否允许右滑手势返回。与微信右滑手势返回一致
    public var allowRightSwipeGestureBack: Bool = true
    
    /// Swipe right to return to the gesture trigger range, the distance from the left side of the screen
    /// 右滑返回手势触发范围，距离屏幕左边的距离
    public var rightSwipeGestureTriggerRange: CGFloat = 50
    
    /// Status bar style
    /// 状态栏样式
    public var statusBarStyle: UIStatusBarStyle = .default
    
    /// Translucent effect
    /// 半透明效果
    public var navigationBarIsTranslucent: Bool = true
    
    /// Navigation controller background color
    /// 导航控制器背景颜色
    public var navigationViewBackgroundColor: UIColor = .white
    
    /// Navigation controller background color in dark style
    /// 暗黑风格下导航控制器背景颜色
    public var navigationViewBackgroudDarkColor: UIColor = "#2E2F30".color
    
    /// Navigation bar style
    /// 导航栏样式
    public var navigationBarStyle: UIBarStyle = .default
    
    /// Navigation bar style under dark style
    /// 暗黑风格下导航栏样式
    public var navigationBarDarkStyle: UIBarStyle = .black
    
    public var adaptiveBarAppearance: Bool = true
    
    /// Navigation bar title color
    /// 导航栏标题颜色
    public var navigationTitleColor: UIColor = .black
    
    /// Navigation bar title color in dark style
    /// 暗黑风格下导航栏标题颜色
    public var navigationTitleDarkColor: UIColor = .white
    
    /// TintColor
    public var navigationTintColor: UIColor?
    
    /// TintColor in dark style
    /// 暗黑风格下TintColor
    public var navigationDarkTintColor: UIColor?
    
    /// Album list configuration
    /// 相册列表配置
    public lazy var albumList: AlbumListConfiguration = .init()
    
    /// Photo list configuration
    /// 照片列表配置
    public lazy var photoList: PhotoListConfiguration = .init()
    
    /// Preview interface configuration
    /// 预览界面配置
    public lazy var previewView: PreviewViewConfiguration = .init()
    
    /// Unauthorized prompt interface related configuration
    /// 未授权提示界面相关配置
    public lazy var notAuthorized: NotAuthorizedConfiguration = .init()
    
    /// Whether to cache the [Camera Roll/All Photos] album
    /// 是否缓存[相机胶卷/所有照片]相册
    public var isCacheCameraAlbum: Bool = true
    
    public override init() {
        super.init()
        PhotoManager.shared.isCacheCameraAlbum = isCacheCameraAlbum
    }
}
