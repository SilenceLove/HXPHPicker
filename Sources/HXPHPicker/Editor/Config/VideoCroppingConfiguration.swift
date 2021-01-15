//
//  VideoCroppingConfiguration.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/10.
//

import UIKit

public class VideoCroppingConfiguration: NSObject {
    
    /// 视频最大裁剪时长，最小1
    public var maximumVideoCroppingTime: CGFloat = 10
    
    /// 视频最小裁剪时长，最小1
    public var minimumVideoCroppingTime: CGFloat = 1
}
