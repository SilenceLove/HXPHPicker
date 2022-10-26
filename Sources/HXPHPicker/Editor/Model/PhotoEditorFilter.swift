//
//  PhotoEditorFilter.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/23.
//

import UIKit

/// 需要添加滤镜的原始图片、上一次添加滤镜的图片，滤镜参数，是否是滤镜列表封面
public typealias PhotoEditorFilterHandler = (CIImage, UIImage?, [PhotoEditorFilterParameterInfo], Bool) -> CIImage?

/// 原始画面，滤镜参数
public typealias VideoEditorFilterHandler = (CIImage, [PhotoEditorFilterParameterInfo]) -> CIImage?

#if canImport(Harbeth)
import Harbeth
public typealias PhotoEditorMetalFilterHandler = (PhotoEditorFilterParameterInfo?, Bool) -> C7FilterProtocol
#endif

public struct PhotoEditorFilterInfo {
    
    /// 滤镜名称
    public let filterName: String
    
    /// 滤镜处理器，内部会传入未添加滤镜的图片，返回添加滤镜之后的图片
    /// 如果为视频编辑器时，处理的是底部滤镜预览的数据
    public let filterHandler: PhotoEditorFilterHandler?
    
    /// 视频滤镜
    public let videoFilterHandler: VideoEditorFilterHandler?
    
    /// 滤镜参数
    public let parameters: [PhotoEditorFilterParameter]
    
    public init(
        filterName: String,
        parameters: [PhotoEditorFilterParameter] = [],
        filterHandler: @escaping PhotoEditorFilterHandler,
        videoFilterHandler: VideoEditorFilterHandler? = nil
    ) {
        self.filterName = filterName
        self.filterHandler = filterHandler
        self.videoFilterHandler = videoFilterHandler
        self.parameters = parameters
        #if canImport(Harbeth)
        self.metalFilterHandler = nil
        #endif
    }
    #if canImport(Harbeth)
    public let metalFilterHandler: PhotoEditorMetalFilterHandler?
    
    public init(
        filterName: String,
        parameter: PhotoEditorFilterParameter? = nil,
        metalFilterHandler: @escaping PhotoEditorMetalFilterHandler
    ) {
        self.filterHandler = nil
        self.videoFilterHandler = nil
        
        self.filterName = filterName
        self.metalFilterHandler = metalFilterHandler
        if let parameter = parameter {
            self.parameters = [parameter]
        }else {
            self.parameters = []
        }
    }
    #endif
}

public struct PhotoEditorFilterParameter: Codable {
    
    public let id: String?
    
    public let title: String?
    
    public let defaultValue: Float
    
    public init(
        id: String? = nil,
        title: String? = nil,
        defaultValue: Float
    ) {
        self.id = id
        self.title = title
        self.defaultValue = defaultValue
    }
}

class PhotoEditorFilter: Equatable, Codable {
    
    let filterName: String
    let parameters: [PhotoEditorFilterParameterInfo]
    
    init(
        filterName: String,
        parameters: [PhotoEditorFilterParameterInfo] = []
    ) {
        self.filterName = filterName
        self.parameters = parameters
    }
    
    var isOriginal: Bool = false
    var isSelected: Bool = false
    var sourceIndex: Int = 0
    
    static func == (
        lhs: PhotoEditorFilter,
        rhs: PhotoEditorFilter
    ) -> Bool {
        lhs === rhs
    }
}

public class PhotoEditorFilterParameterInfo: Equatable, Codable {
    
    /// 当前slider的value
    public var value: Float
    
    /// 对应的参数类型
    public let parameter: PhotoEditorFilterParameter
    
    let sliderType:  ParameterSliderView.`Type`
    var isNormal: Bool
    
    init(
        parameter: PhotoEditorFilterParameter,
        sliderType: ParameterSliderView.`Type` = .normal
    ) {
        self.parameter = parameter
        self.value = parameter.defaultValue
        isNormal = self.value == 0
        self.sliderType = sliderType
    }
    
    public static func == (lhs: PhotoEditorFilterParameterInfo, rhs: PhotoEditorFilterParameterInfo) -> Bool {
        lhs === rhs
    }
}

struct VideoEditorFilter: Codable {
    let index: Int
    let parameters: [PhotoEditorFilterParameterInfo]
}
