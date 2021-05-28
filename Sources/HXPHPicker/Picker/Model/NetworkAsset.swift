//
//  NetworkAsset.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/24.
//

#if canImport(Kingfisher)
import UIKit
import Kingfisher

public struct NetworkImageAsset {
    
    /// 占位图
    public var placeholder: String?
    
    /// 缩略图，列表cell展示
    public let thumbnailURL: URL
    
    /// Kingfisher 下载缩略图时 DownsamplingImageProcessor 设置的大小
    public let thumbnailSize: CGSize
    
    /// 原图，预览大图展示
    public let originalURL: URL
    
    /// 图片尺寸
    public var imageSize: CGSize
    
    /// 图片文件大小
    public var fileSize: Int
    
    public init(thumbnailURL: URL,
                originalURL: URL,
                thumbnailSize: CGSize = UIScreen.main.bounds.size,
                imageSize: CGSize = .zero,
                fileSize: Int = 0) {
        self.thumbnailURL = thumbnailURL
        self.originalURL = originalURL
        self.thumbnailSize = thumbnailSize
        self.imageSize = imageSize
        self.fileSize = fileSize
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: originalURL.cacheKey) {
            self.imageSize = image.size
            if let imageData = image.kf.data(format: originalURL.isGif ? .GIF : .unknown) {
                self.fileSize = imageData.count
            }
        }
    }
}
#endif
