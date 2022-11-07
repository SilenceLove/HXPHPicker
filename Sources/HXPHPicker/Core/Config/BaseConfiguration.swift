//
//  BaseConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import UIKit

open class BaseConfiguration {
    
    public var modalPresentationStyle: UIModalPresentationStyle
    
    /// If the built-in language is not enough, you can add a custom language text
    /// PhotoManager.shared.customLanguages - custom language array
    /// PhotoManager.shared.fixedCustomLanguage - If there are multiple custom languages, one can be fixed to display
    /// 如果自带的语言不够，可以添加自定义的语言文字
    /// PhotoManager.shared.customLanguages - 自定义语言数组
    /// PhotoManager.shared.fixedCustomLanguage - 如果有多种自定义语言，可以固定显示某一种
    public var languageType: LanguageType = .system
    
    /// Appearance style
    /// 外观风格
    public var appearanceStyle: AppearanceStyle = .varied
    
    /// hide status bar
    /// 隐藏状态栏
    public var prefersStatusBarHidden: Bool = false
    
    /// Rotation is allowed, and rotation can only be disabled in full screen
    /// 允许旋转，全屏情况下才可以禁止旋转
    public var shouldAutorotate: Bool = true
    
    /// supported directions
    /// 支持的方向
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    
    /// Loading indicator type
    /// 加载指示器类型
    public var indicatorType: IndicatorType = .circle {
        didSet { PhotoManager.shared.indicatorType = indicatorType }
    }
    
    public init() {
        if #available(iOS 13.0, *) {
            modalPresentationStyle = .automatic
        } else {
            modalPresentationStyle = .fullScreen
        }
        PhotoManager.shared.indicatorType = indicatorType
    }
}

public extension BaseConfiguration {
    
    enum IndicatorType {
        /// gradient ring
        /// 渐变圆环
        case circle
        /// System chrysanthemum
        /// 系统菊花
        case system
    }
}
