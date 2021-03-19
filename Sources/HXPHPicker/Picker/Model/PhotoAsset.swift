//
//  PhotoAsset.swift
//  HXPhotoPickerSwift
//
//  Created by Silence on 2020/11/12.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos

public typealias PhotoAssetICloudHandlerHandler = (PhotoAsset, PHImageRequestID) -> Void
public typealias PhotoAssetProgressHandler = (PhotoAsset, Double) -> Void
public typealias PhotoAssetFailureHandler = (PhotoAsset, [AnyHashable : Any]?) -> Void

open class PhotoAsset: Equatable {
    
    /// 系统相册里的资源
    public var phAsset: PHAsset? {
        didSet {
            setMediaType()
        }
    }
    
    /// 媒体类型
    public var mediaType: PhotoAsset.MediaType = .photo
    
    /// 媒体子类型
    public var mediaSubType: PhotoAsset.MediaSubType = .image
    
    /// 原图
    public var originalImage: UIImage? {
        get {
            getOriginalImage()
        }
    }

    /// 图片/视频文件大小
    public var fileSize: Int {
        get {
            getFileSize()
        }
    }
    #if HXPICKER_ENABLE_EDITOR
    /// 视频编辑数据
    public var videoEdit: VideoEditResult?
    #endif
    
    /// 视频时长 格式：00:00
    public var videoTime: String? {
        get {
            #if HXPICKER_ENABLE_EDITOR
            if let videoEdit = videoEdit {
                return videoEdit.videoTime
            }
            #endif
            return pVideoTime
        }
    }
    
    /// 视频时长 秒
    public var videoDuration: TimeInterval {
        get {
            #if HXPICKER_ENABLE_EDITOR
            if let videoEdit = videoEdit {
                return videoEdit.videoDuration
            }
            #endif
            return pVideoDuration
        }
    }
    
    /// 当前资源是否被选中
    public var isSelected: Bool = false
    
    /// 选中时的下标
    public var selectIndex: Int = 0
    
    /// 图片/视频尺寸大小
    public var imageSize: CGSize {
        get {
            getImageSize()
        }
    }
    
    /// iCloud下载状态
    public var downloadStatus: PhotoAsset.DownloadStatus = .unknow
    
    /// iCloud下载进度，如果取消了会记录上次进度
    public var downloadProgress: Double = 0
    
    /// 根据系统相册里对应的 PHAsset 数据初始化
    /// - Parameter asset: 系统相册里对应的 PHAsset 数据
    public init(asset: PHAsset) {
        self.phAsset = asset
        setMediaType()
    }
    
    /// 根据系统相册里对应的 PHAsset本地唯一标识符 初始化
    /// - Parameter localIdentifier: 系统相册里对应的 PHAsset本地唯一标识符
    public init(localIdentifier: String) {
        phAsset = AssetManager.fetchAsset(withLocalIdentifier: localIdentifier)
        setMediaType()
    }
    
    /// 根据本地image初始化
    /// - Parameter image: 对应的 UIImage 数据
    public convenience init(image: UIImage?) {
        self.init(image: image, localIdentifier: String(Date.init().timeIntervalSince1970))
    }
    
    /// 根据本地 UIImage 和 自定义的本地唯一标识符 初始化
    /// 定义了唯一标识符，进入相册时内部会根据标识符自动选中对应的资源。请确保唯一标识符的正确性
    /// - Parameters:
    ///   - image: 对应的 UIImage 数据
    ///   - localIdentifier: 自定义的本地唯一标识符
    public init(image: UIImage?, localIdentifier: String?) {
        localAssetIdentifier = localIdentifier
        localImage = image
        mediaType = .photo
        mediaSubType = .localImage
    }
    
    /// 根据本地videoURL初始化
    /// - Parameter videoURL: 对应的 URL 数据
    public convenience init(videoURL: URL?) {
        self.init(videoURL: videoURL, localIdentifier: String(Date.init().timeIntervalSince1970))
    }
    
    /// 根据本地 videoURL 和 自定义的本地唯一标识符初始化
    /// 定义了唯一标识符，进入相册时内部会根据标识符自动选中对应的资源。请确保唯一标识符的正确性
    /// - Parameters:
    ///   - videoURL: 对应的 URL 数据
    ///   - localIdentifier: 自定义的本地唯一标识符
    public init(videoURL: URL?, localIdentifier: String?) {
        localAssetIdentifier = localIdentifier
        localImage = PhotoTools.getVideoThumbnailImage(videoURL: videoURL, atTime: 0.1)
        pVideoDuration = PhotoTools.getVideoDuration(videoURL: videoURL)
        pVideoTime = PhotoTools.transformVideoDurationToString(duration: pVideoDuration)
        localVideoURL = videoURL
        mediaType = .video
        mediaSubType = .localVideo
    }
    
    /// 本地资源的唯一标识符
    var localAssetIdentifier: String?
    var localIndex: Int = 0
    var localImage: UIImage?
    var localVideoURL: URL?
    private var pFileSize: Int?
    private var pVideoTime: String?
    private var pVideoDuration: TimeInterval = 0
    
    public static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.isEqual(rhs)
    }
}
// MARK: 
public extension PhotoAsset {
    
    /// 判断是否是同一个 PhotoAsset 对象
    func isEqual(_ photoAsset: PhotoAsset?) -> Bool {
        if let photoAsset = photoAsset {
            if self === photoAsset {
                return true
            }
            if let localIdentifier = phAsset?.localIdentifier, let phLocalIdentifier = photoAsset.phAsset?.localIdentifier, localIdentifier == phLocalIdentifier {
                return true
            }
            if let localAssetIdentifier = localAssetIdentifier , let phLocalAssetIdentifier = photoAsset.localAssetIdentifier, localAssetIdentifier == phLocalAssetIdentifier {
                return true
            }
            if let localImage = localImage, let phLocalImage = photoAsset.localImage, localImage == phLocalImage {
                return true
            }
            if let localVideoURL = localVideoURL, let phLocalVideoURL = photoAsset.localVideoURL, localVideoURL == phLocalVideoURL {
                return true
            }
            if let phAsset = phAsset, phAsset == photoAsset.phAsset {
                return true
            }
        }
        return false
    }
}

// MARK: Self-use
extension PhotoAsset {
     
    func copyCamera() -> PhotoAsset {
        var photoAsset: PhotoAsset
        if mediaType == .photo {
            photoAsset = PhotoAsset.init(image: localImage, localIdentifier: localAssetIdentifier)
        }else {
            photoAsset = PhotoAsset.init(videoURL: localVideoURL, localIdentifier: localAssetIdentifier)
        }
        photoAsset.localIndex = localIndex
        return photoAsset
    }
    
    func setMediaType() {
        if phAsset?.mediaType.rawValue == 1 {
            mediaType = .photo
            mediaSubType = .image
        }else if phAsset?.mediaType.rawValue == 2 {
            mediaType = .video
            mediaSubType = .video
            pVideoDuration = phAsset!.duration
            pVideoTime = PhotoTools.transformVideoDurationToString(duration: TimeInterval(round(phAsset!.duration)))
        }
    }
    func getLocalImageData() -> Data? {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            return PhotoTools.getImageData(for: videoEdit.coverImage)
        }
        #endif
        return PhotoTools.getImageData(for: localImage)
    }
    func getFileSize() -> Int {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            return videoEdit.editedFileSize
        }
        #endif
        if let fileSize = pFileSize {
            return fileSize
        }
        var fileSize = 0
        if let photoAsset = phAsset {
            let assetResources = PHAssetResource.assetResources(for: photoAsset)
            let assetIsLivePhoto = photoAsset.isLivePhoto
            for assetResource in assetResources {
                if assetIsLivePhoto && mediaSubType != .livePhoto {
                    if assetResource.type == .photo {
                        if let photoFileSize = assetResource.value(forKey: "fileSize") as? Int {
                            fileSize += photoFileSize
                        }
                    }
                }else {
                    if let photoFileSize = assetResource.value(forKey: "fileSize") as? Int {
                        fileSize += photoFileSize
                    }
                }
            }
        }else {
            if self.mediaType == .photo {
                if let imageData = getLocalImageData() {
                    fileSize = imageData.count
                }
            }else {
                if let videoURL = localVideoURL {
                    do {
                        let videofileSize = try videoURL.resourceValues(forKeys: [.fileSizeKey])
                        fileSize = videofileSize.fileSize ?? 0
                    } catch {}
                }
            }
        }
        pFileSize = fileSize
        return fileSize
    }
    func requestFileSize(result: @escaping (Int, PhotoAsset) -> Void) {
        DispatchQueue.global().async {
            let fileSize = self.getFileSize()
            DispatchQueue.main.async {
                result(fileSize, self)
            }
        }
    }
    func getOriginalImage() -> UIImage? {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            return videoEdit.coverImage
        }
        #endif
        if phAsset == nil {
            return localImage
        }
        let options = PHImageRequestOptions.init()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        if mediaSubType == .imageAnimated {
            options.version = .original
        }
        var originalImage: UIImage?
        _ = AssetManager.requestImageData(for: phAsset!, options: options) { (imageData, dataUTI, orientation, info) in
            if let imageData = imageData {
                originalImage = UIImage.init(data: imageData)
                if self.mediaSubType != .imageAnimated && self.phAsset!.isImageAnimated {
                    // 原始图片是动图，但是设置的是不显示动图，所以在这里处理一下
                    originalImage = originalImage?.images?.first
                }
            }
        }
        return originalImage
    }
    func getImageSize() -> CGSize {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            return videoEdit.coverImage?.size ?? CGSize(width: 200, height: 200)
        }
        #endif
        let size : CGSize
        if let phAsset = phAsset {
            if phAsset.pixelWidth == 0 || phAsset.pixelHeight == 0 {
                size = CGSize(width: 200, height: 200)
            }else {
                size = CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight)
            }
        }else {
            size = localImage?.size ?? CGSize(width: 200, height: 200)
        }
        return size
    }
    
    /// 获取本地图片地址
    func requestLocalImageURL(resultHandler: @escaping (URL?) -> Void) {
        DispatchQueue.global().async {
            if let imageData = self.getLocalImageData() {
                let imageURL = self.write(imageData: imageData)
                DispatchQueue.main.async {
                    resultHandler(imageURL)
                }
            }else {
                DispatchQueue.main.async {
                    resultHandler(nil)
                }
            }
        }
    }
    private func write(imageData: Data) -> URL? {
        let imageURL = PhotoTools.getImageTmpURL()
        do {
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            return nil
        }
    }
    func requestAssetImageURL(resultHandler: @escaping (URL?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            DispatchQueue.global().async {
                var imageURL: URL?
                if let imageData = PhotoTools.getImageData(for: videoEdit.coverImage) {
                    imageURL = self.write(imageData: imageData)
                }
                DispatchQueue.main.async {
                    resultHandler(imageURL)
                }
            }
            return
        }
        #endif
        if phAsset == nil {
            resultHandler(nil)
            return
        }
        if mediaType == .video {
            _ = requestImageData(iCloudHandler: nil, progressHandler: nil) { [weak self] (photoAsset, imageData, imageOrientation, info) in
                DispatchQueue.global().async {
                    let imageURL = self?.write(imageData: imageData)
                    DispatchQueue.main.async {
                        resultHandler(imageURL)
                    }
                }
            } failure: { (photoAsset, ino) in
                resultHandler(nil)
            }
            return
        }
        var suffix: String
        if mediaSubType == .imageAnimated {
            suffix = "gif"
        }else {
            suffix = "jpeg"
        }
        AssetManager.requestImageURL(for: phAsset!, suffix: suffix) { (imageURL) in
            if let imageURL = imageURL, self.phAsset!.isImageAnimated, self.mediaSubType != .imageAnimated {
                // 本质上是gif，需要变成静态图
                let image = UIImage.init(contentsOfFile: imageURL.path)
                if let imageData = PhotoTools.getImageData(for: image) {
                    do {
                        let tempURL = PhotoTools.getImageTmpURL()
                        try imageData.write(to: tempURL)
                        resultHandler(tempURL)
                    } catch {
                        resultHandler(nil)
                    }
                }else {
                    resultHandler(nil)
                }
            }else {
                resultHandler(imageURL)
            }
        }
    }
    func requestAssetVideoURL(resultHandler: @escaping (URL?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            resultHandler(videoEdit.editedURL)
            return
        }
        #endif
        if mediaSubType == .livePhoto {
            var videoURL: URL?
            AssetManager.requestLivePhoto(content: phAsset!) { (imageData) in
            } videoHandler: { (url) in
                videoURL = url
            } completionHandler: { (error) in
                resultHandler(videoURL)
            }
        }else {
            if mediaType == .photo {
                resultHandler(nil)
                return
            }
            AssetManager.requestVideoURL(mp4Format: phAsset!) { (videoURL) in
                resultHandler(videoURL)
            }
        }
    }
}
