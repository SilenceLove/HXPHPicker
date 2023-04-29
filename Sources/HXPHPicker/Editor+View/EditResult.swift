//
//  EditResult.swift
//  HXPHPicker
//
//  Created by Slience on 2023/1/21.
//

import UIKit

public struct EditResult {
    
    public struct Image {
        
        /// 编辑后的缩略图片，如果为gif则为封面图片
        /// 适合在多图列表展示，预览原图或者大图请使用 imageURL
        public let image: UIImage
        
        /// 编辑后的图片本地地址
        public var url: URL {
            urlConfig.url
        }
        
        public let urlConfig: EditorURLConfig
        
        /// 图片类型
        public let imageType: ImageType
        
        public enum ImageType: Int, Codable {
            /// 静态图
            case normal
            /// 动图
            case gif
        }
        
        /// 编辑视图的状态
        public let data: AdjustmentData
    }
    
    public struct Video {
        
        /// 编辑后的视频地址
        public var url: URL {
            urlConfig.url
        }
        
        public let urlConfig: EditorURLConfig
        
//        /// 编辑后的视频封面
//        public let coverImage: UIImage?
//
//        /// 编辑后的视频大小
//        public let fileSize: Int
//        
//        /// 视频时长 格式：00:00
//        public let videoTime: String
//        
//        /// 视频时长 秒
//        public let videoDuration: TimeInterval
//        
//        /// 是否包含原视频音乐
//        public let isContainOriginalSound: Bool
//        
//        /// 原视频音量
//        public let videoSoundVolume: Float
//        
//        /// 背景音乐地址
//        public let backgroundMusicURL: URL?
//        
//        /// 背景音乐音量
//        public let backgroundMusicVolume: Float
//        
//        /// 时长裁剪数据
//        public let cropData: VideoCropData?
        
        /// 编辑视图的状态
        public let data: AdjustmentData
    }
    
    public struct AdjustmentData: CustomStringConvertible {
        let content: Content
        let maskImage: UIImage?
        let drawView: [EditorDrawView.BrushInfo]
        let mosaicView: [EditorMosaicView.MosaicData]
        
        public var description: String {
            "adjustment data"
        }
    }
}


extension EditResult.AdjustmentData {
    struct Content: Codable {
        let editSize: CGSize
        let contentOffset: CGPoint
        let contentSize: CGSize
        let contentInset: UIEdgeInsets
        let mirrorViewTransform: CGAffineTransform
        let rotateViewTransform: CGAffineTransform
        let scrollViewTransform: CGAffineTransform
        let scrollViewZoomScale: CGFloat
        let controlScale: CGFloat
        let adjustedFactor: Adjusted?
        
        struct Adjusted: Codable {
            let angle: CGFloat
            let zoomScale: CGFloat
            let contentOffset: CGPoint
            let contentInset: UIEdgeInsets
            let maskRect: CGRect
            let transform: CGAffineTransform
            let rotateTransform: CGAffineTransform
            let mirrorTransform: CGAffineTransform
            
            let contentOffsetScale: CGPoint
            let min_zoom_scale: CGFloat
            let isRoundMask: Bool
        }
    }
}

public struct EditorURLConfig: Codable {
    public enum PathType: Codable {
        case document
        case caches
        case temp
    }
    /// 文件名称
    public let fileName: String
    /// 路径类型
    public let pathType: PathType
    
    public init(fileName: String, type: PathType) {
        self.fileName = fileName
        self.pathType = type
    }
    
    /// 文件地址
    public var url: URL {
        var filePath: String = ""
        switch pathType {
        case .document:
            filePath = FileManager.documentPath + "/"
        case .caches:
            filePath = FileManager.cachesPath + "/"
        case .temp:
            filePath = FileManager.tempPath
        }
        filePath.append(contentsOf: fileName)
        return .init(fileURLWithPath: filePath)
    }
}
