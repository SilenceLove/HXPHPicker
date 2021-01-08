//
//  HXPHConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import Foundation

open class HXPHConfiguration: NSObject {
    
    /// 如果自带的语言不够，可以添加自定义的语言文字
    /// HXPHManager.shared.customLanguages 自定义语言数组
    /// HXPHManager.shared.fixedCustomLanguage 如果有多种自定义语言，可以固定显示某一种
    /// 语言类型
    public var languageType: HXPHLanguageType = .system
    
    /// 外观风格
    public var appearanceStyle: HXPHAppearanceStyle = .varied
    
    /// 隐藏状态栏
    public var prefersStatusBarHidden: Bool = false
}
