//
//  EditorConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import SwiftUI

open class EditorConfiguration: BaseConfiguration {
    public override init() {
        super.init()
        prefersStatusBarHidden = true
    }
    
    public struct Filter {
        /// 滤镜信息
        public var infos: [PhotoEditorFilterInfo]
        
        /// 滤镜选中颜色
        public var selectedColor: UIColor
        
        /// 编辑视频时，是否加载上次滤镜效果
        /// 如果滤镜数据与上次编辑时的滤镜数据不一致会导致加载错乱
        /// 请确保滤镜数据与上一次的数据一致之后再加载
        public var isLoadLastFilter: Bool
        
        public init(
            infos: [PhotoEditorFilterInfo] = [],
            selectedColor: UIColor = HXPickerWrapper<UIColor>.systemTintColor,
            isLoadLastFilter: Bool = true
        ) {
            self.infos = infos
            self.selectedColor = selectedColor
            self.isLoadLastFilter = isLoadLastFilter
        }
    }
}

public struct EditorCropSizeConfiguration {
    
    /// 圆形裁剪框
    public var isRoundCrop: Bool = false
    
    /// 默认固定比例
    /// ```
    /// /// 如果不想要底部其他的比例请将`aspectRatios`置空
    /// aspectRatios = []
    /// ```
    public var fixedRatio: Bool = false
    
    /// 默认宽高比
    public var aspectRatioType: AspectRatioType = .original
    
    /// 裁剪时遮罩类型
    public var maskType: EditorImageResizerMaskView.MaskType = .darkBlurEffect
    
    /// 宽高比选中颜色
    public var aspectRatioSelectedColor: UIColor = .systemTintColor
    
    /// 宽高比数组默认选择的下标
    /// 选中不代表默认就是对应的宽高比
    /// ```
    /// /// 如果想要默认对应的宽高比必须设置 `aspectRatioType`
    /// /// 默认选中 2
    /// defaultSeletedIndex = 2
    /// /// 默认的宽高比也要设置与之对应的比例，这样进入裁剪的时候默认就是设置的样式
    /// aspectRatioType = .custom(.init(width: 3, height: 2))
    /// /// 固定宽高比
    /// fixedRatio = true
    /// ```
    public var defaultSeletedIndex: Int = 0
    
    /// 宽高比数组 [[宽, 高]]
    /// tip：请将数组第一个设置为 [0, 0] 自由模式，第一个点击还原时会默认选中
    /// ```
    /// /// 如果不添加自由模式，可以隐藏还原按钮
    /// let photoConfig = PhotoEditorConfiguration()
    /// photoConfig.cropConfimView.isShowResetButton = false
    /// ```
    public var aspectRatios: [[Int]] = [[0, 0], [1, 1], [3, 2], [2, 3], [4, 3], [3, 4], [16, 9], [9, 16]]
    
    /// 当 `aspectRatios` 为空数组时，点击还原是否重置到原始宽高比
    /// true：重置到原始宽高比
    /// false：重置到设置的默认宽高比`aspectRatioType`，居中显示
    /// tip：isRoundCrop = true，圆形裁剪框时无效
    public var resetToOriginal: Bool = false
    
    public init() { }
}

public struct EditorBrushConfiguration {
    
    /// 画笔颜色数组
    public var colors: [String] = PhotoTools.defaultColors()
    
    /// 默认画笔颜色索引
    public var defaultColorIndex: Int = 2
    
    /// 初始画笔宽度
    public var lineWidth: CGFloat = 5
    
    /// 画笔最大宽度
    public var maximumLinewidth: CGFloat = 20
    
    /// 画笔最小宽度
    public var minimumLinewidth: CGFloat = 2
    
    /// 显示画笔尺寸大小滑动条
    public var showSlider: Bool = true
    
    /// 添加自定义颜色 - iOS 14+
    public var addCustomColor: Bool = true
    
    /// 自定义默认颜色 - iOS 14+
    public var customDefaultColor: UIColor = "#9EB6DC".hx.color
    
    public init() { }
}
