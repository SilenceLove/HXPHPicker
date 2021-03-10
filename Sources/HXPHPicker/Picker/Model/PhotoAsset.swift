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

open class PhotoAsset: NSObject {
    
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
            return getOriginalImage()
        }
    }

    /// 图片/视频文件大小
    public var fileSize: Int {
        get {
            return getFileSize()
        }
    }
    
    /// 视频编辑数据
    public var videoEdit: VideoEditResult?
    
    /// 视频时长 格式：00:00
    public var videoTime: String? {
        get {
            if let videoEdit = videoEdit {
                return videoEdit.videoTime
            }
            return pVideoTime
        }
    }
    
    /// 视频时长 秒
    public var videoDuration: TimeInterval {
        get {
            if let videoEdit = videoEdit {
                return videoEdit.videoDuration
            }
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
            return getImageSize()
        }
    }
    
    /// iCloud下载状态
    public var downloadStatus: PhotoAsset.DownloadStatus = .unknow
    
    /// iCloud下载进度，如果取消了会记录上次进度
    public var downloadProgress: Double = 0
    
    /// 根据系统相册里对应的 PHAsset 数据初始化
    /// - Parameter asset: 系统相册里对应的 PHAsset 数据
    public init(asset: PHAsset) {
        super.init()
        self.phAsset = asset
        setMediaType()
    }
    
    /// 根据系统相册里对应的 PHAsset本地唯一标识符 初始化
    /// - Parameter localIdentifier: 系统相册里对应的 PHAsset本地唯一标识符
    public init(localIdentifier: String) {
        super.init()
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
        super.init()
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
        super.init()
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
    private var localImage: UIImage?
    private var localVideoURL: URL?
    private var pFileSize: Int?
    private var pVideoTime: String?
    private var pVideoDuration: TimeInterval = 0
}
// MARK: 获取资源
public extension PhotoAsset {
    
    /// 获取原始图片地址
    func requestImageURL(resultHandler: @escaping (URL?) -> Void) {
        if phAsset == nil {
            requestLocalImageURL(resultHandler: resultHandler)
            return
        }
        requestAssetImageURL(resultHandler: resultHandler)
    }
    /// 获取原始视频地址
    func requestVideoURL(resultHandler: @escaping (URL?) -> Void) {
        if let videoEdit = videoEdit {
            resultHandler(videoEdit.editedURL)
            return
        }
        if phAsset == nil {
            if mediaType == .photo {
                resultHandler(nil)
            }else {
                resultHandler(localVideoURL)
            }
            return
        }
        requestAssetVideoURL(resultHandler: resultHandler)
    }
    
    /// 请求缩略图
    /// - Parameter completion: 完成回调
    /// - Returns: 请求ID
    func requestThumbnailImage(completion: ((UIImage?, PhotoAsset, [AnyHashable : Any]?) -> Void)?) -> PHImageRequestID? {
        return requestThumbnailImage(targetWidth: 180, completion: completion)
    }
    func requestThumbnailImage(targetWidth: CGFloat, completion: ((UIImage?, PhotoAsset, [AnyHashable : Any]?) -> Void)?) -> PHImageRequestID? {
        if let videoEdit = videoEdit {
            completion?(videoEdit.coverImage, self, nil)
            return nil
        }
        if phAsset == nil {
            completion?(localImage, self, nil)
            return nil
        }
        return AssetManager.requestThumbnailImage(for: phAsset!, targetWidth: targetWidth) { (image, info) in
            completion?(image, self, info)
        }
    }
    
    /// 请求imageData，如果资源在iCloud上会自动下载。如果需要更细节的处理请查看 PHAssetManager+Asset
    /// - Parameters:
    ///   - iCloudHandler: 下载iCloud上的资源时回调iCloud的请求ID
    ///   - progressHandler: iCloud下载进度
    /// - Returns: 请求ID
    func requestImageData(iCloudHandler: PhotoAssetICloudHandlerHandler?, progressHandler: PhotoAssetProgressHandler?, success: ((PhotoAsset, Data, UIImage.Orientation, [AnyHashable : Any]?) -> Void)?, failure: PhotoAssetFailureHandler?) -> PHImageRequestID {
        if let videoEdit = videoEdit {
            DispatchQueue.global().async {
                let imageData = PhotoTools.getImageData(for: videoEdit.coverImage)
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        success?(self, imageData, videoEdit.coverImage!.imageOrientation, nil)
                    }else {
                        failure?(self, nil)
                    }
                }
            }
            return 0
        }
        if phAsset == nil {
            failure?(self, nil)
            return 0
        }
        var version = PHImageRequestOptionsVersion.current
        if mediaSubType == .imageAnimated {
            version = .original
        }
        downloadStatus = .downloading
        return AssetManager.requestImageData(for: phAsset!, version: version, iCloudHandler: { (iCloudRequestID) in
            iCloudHandler?(self, iCloudRequestID)
        }, progressHandler: { (progress, error, stop, info) in
            self.downloadProgress = progress
            DispatchQueue.main.async {
                progressHandler?(self, progress)
            }
        }, resultHandler: { (data, dataUTI, imageOrientation, info, downloadSuccess) in
            if downloadSuccess {
                self.downloadProgress = 1
                self.downloadStatus = .succeed
                success?(self, data!, imageOrientation, info)
            }else {
                if AssetManager.assetCancelDownload(for: info) {
                    self.downloadStatus = .canceled
                }else {
                    self.downloadProgress = 0
                    self.downloadStatus = .failed
                }
                failure?(self, info)
            }
        })
    }
    
    /// 请求LivePhoto，如果资源在iCloud上会自动下载。如果需要更细节的处理请查看 PHAssetManager+Asset
    /// - Parameters:
    ///   - targetSize: 请求的大小
    ///   - iCloudHandler: 下载iCloud上的资源时回调iCloud的请求ID
    ///   - progressHandler: iCloud下载进度
    /// - Returns: 请求ID
    @available(iOS 9.1, *)
    func requestLivePhoto(targetSize: CGSize, iCloudHandler: PhotoAssetICloudHandlerHandler?, progressHandler: PhotoAssetProgressHandler?, success: ((PhotoAsset, PHLivePhoto, [AnyHashable : Any]?) -> Void)?, failure: PhotoAssetFailureHandler?) -> PHImageRequestID {
        if phAsset == nil {
            failure?(self, nil)
            return 0
        }
        downloadStatus = .downloading
        return AssetManager.requestLivePhoto(for: phAsset!, targetSize: targetSize) { (iCloudRequestID) in
            iCloudHandler?(self, iCloudRequestID)
        } progressHandler: { (progress, error, stop, info) in
            self.downloadProgress = progress
            DispatchQueue.main.async {
                progressHandler?(self, progress)
            }
        } resultHandler: { (livePhoto, info, downloadSuccess) in
            if downloadSuccess {
                self.downloadProgress = 1
                self.downloadStatus = .succeed
                success?(self, livePhoto!, info)
            }else {
                if AssetManager.assetCancelDownload(for: info) {
                    self.downloadStatus = .canceled
                }else {
                    self.downloadProgress = 0
                    self.downloadStatus = .failed
                }
                failure?(self, info)
            }
        }
    }
    
    /// 请求AVAsset，如果资源在iCloud上会自动下载。如果需要更细节的处理请查看 PHAssetManager+Asset
    /// - Parameters:
    ///   - filterEditor: 过滤编辑过的视频，取原视频
    ///   - iCloudHandler: 下载iCloud上的资源时回调iCloud的请求ID
    ///   - progressHandler: iCloud下载进度
    /// - Returns: 请求ID
    func requestAVAsset(filterEditor: Bool = false, iCloudHandler: PhotoAssetICloudHandlerHandler?, progressHandler: PhotoAssetProgressHandler?, success: ((PhotoAsset, AVAsset, [AnyHashable : Any]?) -> Void)?, failure: PhotoAssetFailureHandler?) -> PHImageRequestID {
        if let videoEdit = videoEdit, !filterEditor {
            success?(self, AVAsset.init(url: videoEdit.editedURL), nil)
            return 0
        }
        if phAsset == nil {
            if localVideoURL != nil {
                success?(self, AVAsset.init(url: localVideoURL!), nil)
            }else {
                failure?(self, nil)
            }
            return 0
        }
        downloadStatus = .downloading
        return AssetManager.requestAVAsset(for: phAsset!) { (iCloudRequestID) in
            iCloudHandler?(self, iCloudRequestID)
        } progressHandler: { (progress, error, stop, info) in
            self.downloadProgress = progress
            DispatchQueue.main.async {
                progressHandler?(self, progress)
            }
        } resultHandler: { (avAsset, audioMix, info, downloadSuccess) in
            if downloadSuccess {
                self.downloadProgress = 1
                self.downloadStatus = .succeed
                success?(self, avAsset!, info)
            }else {
                if AssetManager.assetCancelDownload(for: info) {
                    self.downloadStatus = .canceled
                }else {
                    self.downloadProgress = 0
                    self.downloadStatus = .failed
                }
                failure?(self, info)
            }
        }
    }
    
    /// 判断是否是同一个 PhotoAsset 对象
    func isEqual(_ photoAsset: PhotoAsset?) -> Bool {
        if let photoAsset = photoAsset {
            if self == photoAsset {
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
            if let localIdentifier = phAsset?.localIdentifier, let phLocalIdentifier = photoAsset.phAsset?.localIdentifier, localIdentifier == phLocalIdentifier {
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
        if let videoEdit = videoEdit {
            return PhotoTools.getImageData(for: videoEdit.coverImage)
        }
        return PhotoTools.getImageData(for: localImage)
    }
    func getFileSize() -> Int {
        if let videoEdit = videoEdit {
            return videoEdit.editedFileSize
        }
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
    func getOriginalImage() -> UIImage? {
        if let videoEdit = videoEdit {
            return videoEdit.coverImage
        }
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
            if imageData != nil {
                originalImage = UIImage.init(data: imageData!)
                if self.mediaSubType != .imageAnimated && self.phAsset!.isImageAnimated {
                    // 原始图片是动图，但是设置的是不显示动图，所以在这里处理一下
                    originalImage = originalImage?.images?.first
                }
            }
        }
        return originalImage
    }
    func getImageSize() -> CGSize {
        if let videoEdit = videoEdit {
            return videoEdit.coverImage?.size ?? CGSize(width: 200, height: 200)
        }
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
        if phAsset == nil {
            resultHandler(nil)
            return
        }
        if mediaType == .video {
            weak var weakSelf = self
            _ = requestImageData(iCloudHandler: nil, progressHandler: nil) { (photoAsset, imageData, imageOrientation, info) in
                DispatchQueue.global().async {
                    let imageURL = weakSelf?.write(imageData: imageData)
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
            if self.phAsset!.isImageAnimated && self.mediaSubType != .imageAnimated && imageURL != nil {
                // 本质上是gif，需要变成静态图
                let image = UIImage.init(contentsOfFile: imageURL!.path)
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
        if let videoEdit = videoEdit {
            resultHandler(videoEdit.editedURL)
            return
        }
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
