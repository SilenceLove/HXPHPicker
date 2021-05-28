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
    #if HXPICKER_ENABLE_EDITOR
    /// 图片编辑数据
    public var photoEdit: PhotoEditResult?
    
    /// 视频编辑数据
    public var videoEdit: VideoEditResult?
    
    var initialPhotoEdit: PhotoEditResult?
    var initialVideoEdit: VideoEditResult?
    #endif
    
    /// 原图
    /// 如果为网络图片时，获取的是缩略地址的图片，也可能为空
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
    
    /// 是否是网络 Asset
    public var isNetworkAsset: Bool {
        get {
            mediaSubType.isNetwork
        }
    }
    
    /// iCloud下载状态
    public var downloadStatus: DownloadStatus = .unknow
    
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
    
    /// 初始化本地图片
    /// - Parameters:
    ///   - localImageAsset: 对应本地图片的 LocalImageAsset
    ///   - localIdentifier: 本地唯一标识符
    public init(localImageAsset: LocalImageAsset) {
        self.localImageAsset = localImageAsset
        mediaType = .photo
        if let imageData = localImageAsset.imageData {
            mediaSubType = imageData.isGif == true ? .localGifImage : .localImage
        }else if let imageURL = localImageAsset.imageURL {
            let suffix = imageURL.lastPathComponent
            mediaSubType = (suffix.hasSuffix("gif") || suffix.hasSuffix("GIF")) ? .localGifImage : .localImage
        }
    }
    
    /// 初始化本地视频
    /// - Parameters:
    ///   - localVideoAsset: 对应本地视频的 LocalVideoAsset
    ///   - localIdentifier: 本地唯一标识符
    public init(localVideoAsset: LocalVideoAsset) {
        self.localVideoAsset = localVideoAsset
        if self.localVideoAsset!.image == nil {
            self.localVideoAsset!.image = PhotoTools.getVideoThumbnailImage(videoURL: localVideoAsset.videoURL, atTime: 0.1)
        }
        if localVideoAsset.duration == 0 {
            self.localVideoAsset!.duration = PhotoTools.getVideoDuration(videoURL: localVideoAsset.videoURL)
            self.localVideoAsset!.videoTime = PhotoTools.transformVideoDurationToString(duration: self.localVideoAsset!.duration)
        }
        pVideoTime = self.localVideoAsset!.videoTime
        pVideoDuration = self.localVideoAsset!.duration
        mediaType = .video
        mediaSubType = .localVideo
    }
    /// 本地图片
    public var localImageAsset: LocalImageAsset?
    /// 本地视频
    public var localVideoAsset: LocalVideoAsset?
    
    /// 本地/网络Asset的唯一标识符
    public private(set) lazy var localAssetIdentifier: String = UUID().uuidString
    
    #if canImport(Kingfisher)
    public init(networkImageAsset: NetworkImageAsset) {
        self.networkImageAsset = networkImageAsset
        mediaType = .photo
        mediaSubType = .networkImage(networkImageAsset.originalURL.isGif)
    }
    /// 网络图片
    public var networkImageAsset: NetworkImageAsset?
    
    var localImageType: DonwloadURLType = .thumbnail
    #endif
    
    var localIndex: Int = 0
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
            if localAssetIdentifier == photoAsset.localAssetIdentifier {
                return true
            }
            #if canImport(Kingfisher)
            if let networkImageAsset = networkImageAsset, let phNetworkImageAsset = photoAsset.networkImageAsset {
                if networkImageAsset.originalURL == phNetworkImageAsset.originalURL {
                    return true
                }
            }
            #endif
            if let localImageAsset = localImageAsset, let phLocalImageAsset = photoAsset.localImageAsset {
                if let localImage = localImageAsset.image, let phLocalImage = phLocalImageAsset.image, localImage == phLocalImage {
                    return true
                }
                if let localImageURL = localImageAsset.imageURL, let phLocalImageURL = phLocalImageAsset.imageURL, localImageURL == phLocalImageURL {
                    return true
                }
            }
            if let localVideoAsset = localVideoAsset, let phLocalVideoAsset = photoAsset.localVideoAsset {
                if localVideoAsset.videoURL == phLocalVideoAsset.videoURL {
                    return true
                }
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
            photoAsset = PhotoAsset.init(localImageAsset: localImageAsset!)
        }else {
            photoAsset = PhotoAsset.init(localVideoAsset: localVideoAsset!)
        }
        photoAsset.localAssetIdentifier = localAssetIdentifier
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
        if let photoEdit = photoEdit {
            return PhotoTools.getImageData(for: photoEdit.editedImage)
        }
        if let videoEdit = videoEdit {
            return PhotoTools.getImageData(for: videoEdit.coverImage)
        }
        #endif
        if let imageData = localImageAsset?.imageData {
            return imageData
        }
        if let imageURL = localImageAsset?.imageURL {
            do {
                let imageData = try Data.init(contentsOf: imageURL)
                return imageData
            }catch {}
        }
        return PhotoTools.getImageData(for: mediaType == .photo ? localImageAsset?.image : localVideoAsset?.image)
    }
    func getLocalVideoDuration(completionHandler: ((TimeInterval, String) -> Void)? = nil) {
        if pVideoDuration > 0 {
            completionHandler?(pVideoDuration, pVideoTime!)
        }else {
            DispatchQueue.global().async {
                let duration = PhotoTools.getVideoDuration(videoURL: self.localVideoAsset?.videoURL)
                self.pVideoDuration = duration
                self.pVideoTime = PhotoTools.transformVideoDurationToString(duration: duration)
                DispatchQueue.main.async {
                    completionHandler?(duration, self.pVideoTime!)
                }
            }
        }
    }
    func getFileSize() -> Int {
        if let fileSize = pFileSize {
            return fileSize
        }
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoEdit {
            if let imageData = PhotoTools.getImageData(for: photoEdit.editedImage) {
                pFileSize = imageData.count
                return imageData.count
            }
            return 0
        }
        if let videoEdit = videoEdit {
            pFileSize = videoEdit.editedFileSize
            return videoEdit.editedFileSize
        }
        #endif
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
                #if canImport(Kingfisher)
                if let networkImageAsset = networkImageAsset, fileSize == 0 {
                    if networkImageAsset.fileSize > 0 {
                        fileSize = networkImageAsset.fileSize
                        pFileSize = fileSize
                    }
                    return fileSize
                }
                #endif
                if let imageData = getLocalImageData() {
                    fileSize = imageData.count
                }
            }else {
                if let videoURL = localVideoAsset?.videoURL {
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
        if let photoEdit = photoEdit {
            return photoEdit.editedImage
        }
        if let videoEdit = videoEdit {
            return videoEdit.coverImage
        }
        #endif
        if phAsset == nil {
            if mediaType == .photo {
                if let image = localImageAsset?.image {
                    return image
                }else if let imageURL = localImageAsset?.imageURL {
                    let image = UIImage.init(contentsOfFile: imageURL.path)
                    localImageAsset?.image = image
                }
                return localImageAsset?.image
            }else {
                return localVideoAsset?.image
            }
        }
        let options = PHImageRequestOptions.init()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        if mediaSubType == .imageAnimated {
            options.version = .original
        }
        var originalImage: UIImage?
        AssetManager.requestImageData(for: phAsset!, options: options) { (imageData, dataUTI, orientation, info) in
            if let imageData = imageData {
                originalImage = UIImage.init(data: imageData)
                if let imageCount = originalImage?.images?.count, self.mediaSubType != .imageAnimated, self.phAsset!.isImageAnimated, imageCount > 1 {
                    // 原始图片是动图，但是设置的是不显示动图，所以在这里处理一下
                    originalImage = originalImage?.images?.first
                }
            }
        }
        return originalImage
    }
    func getImageSize() -> CGSize {
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoEdit {
            return photoEdit.editedImage.size
        }
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
            if let localImage = localImageAsset?.image {
                size = localImage.size
            }else if let localImageData = localImageAsset?.imageData, let image = UIImage.init(data: localImageData) {
                size = image.size
            }else if let imageURL = localImageAsset?.imageURL, let image = UIImage.init(contentsOfFile: imageURL.path) {
                localImageAsset?.image = image
                size = image.size
            }else if let localImage = localVideoAsset?.image {
                size = localImage.size
            }else {
                #if canImport(Kingfisher)
                if let networkImageSize = networkImageAsset?.imageSize, !networkImageSize.equalTo(.zero) {
                    size = networkImageSize
                } else {
                    size = CGSize(width: 200, height: 200)
                }
                #else
                size = CGSize(width: 200, height: 200)
                #endif
            }
        }
        return size
    }
    
    /// 获取本地图片地址
    func requestLocalImageURL(toFile fileURL:URL? = nil, resultHandler: @escaping (URL?) -> Void) {
        if let localImageURL = getLocalImageAssetURL() {
            if let fileURL = fileURL, fileURL.path != localImageURL.path {
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    try FileManager.default.moveItem(at: localImageURL, to: fileURL)
                    resultHandler(fileURL)
                }catch {
                    resultHandler(nil)
                }
                return
            }
            resultHandler(localImageURL)
            return
        }
        DispatchQueue.global().async {
            if let imageData = self.getLocalImageData() {
                let imageURL = self.write(toFile: fileURL, imageData: imageData)
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
    private func getLocalImageAssetURL() -> URL? {
        if photoEdit == nil {
            return localImageAsset?.imageURL
        }else {
            return nil
        }
    }
    private func write(toFile fileURL:URL? = nil, imageData: Data) -> URL? {
        let imageURL = fileURL == nil ? PhotoTools.getImageTmpURL(imageData.isGif ? .gif : .jpg) : fileURL!
        do {
            if FileManager.default.fileExists(atPath: imageURL.path) {
                try FileManager.default.removeItem(at: imageURL)
            }
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            return nil
        }
    }
    func requestAssetImageURL(toFile fileURL:URL? = nil, filterEditor: Bool = false, resultHandler: @escaping (URL?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoEdit, !filterEditor {
            DispatchQueue.global().async {
                var imageURL: URL?
                if let imageData = PhotoTools.getImageData(for: photoEdit.editedImage) {
                    imageURL = self.write(toFile: fileURL, imageData: imageData)
                }
                DispatchQueue.main.async {
                    resultHandler(imageURL)
                }
            }
            return
        }
        if let videoEdit = videoEdit {
            DispatchQueue.global().async {
                var imageURL: URL?
                if let imageData = PhotoTools.getImageData(for: videoEdit.coverImage) {
                    imageURL = self.write(toFile: fileURL, imageData: imageData)
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
            requestImageData(iCloudHandler: nil, progressHandler: nil) { [weak self] (photoAsset, imageData, imageOrientation, info) in
                DispatchQueue.global().async {
                    let imageURL = self?.write(toFile: fileURL, imageData: imageData)
                    DispatchQueue.main.async {
                        resultHandler(imageURL)
                    }
                }
            } failure: { (photoAsset, ino) in
                resultHandler(nil)
            }
            return
        }
        var imageFileURL: URL
        if let fileURL = fileURL {
            imageFileURL = fileURL
        }else {
            var suffix: String
            if mediaSubType == .imageAnimated {
                suffix = "gif"
            }else {
                suffix = "jpeg"
            }
            imageFileURL = PhotoTools.getTmpURL(for: suffix)
        }
        let isGif = phAsset!.isImageAnimated
        AssetManager.requestImageURL(for: phAsset!, toFile: imageFileURL) { (imageURL) in
            if let imageURL = imageURL, isGif, self.mediaSubType != .imageAnimated {
                // 本质上是gif，需要变成静态图
                do {
                    let imageData = PhotoTools.getImageData(for: UIImage.init(contentsOfFile: imageURL.path))
                    if FileManager.default.fileExists(atPath: imageURL.path) {
                        try FileManager.default.removeItem(at: imageURL)
                    }
                    try imageData?.write(to: imageURL)
                    resultHandler(imageURL)
                } catch {
                    resultHandler(nil)
                }
            }else {
                resultHandler(imageURL)
            }
        }
    }
    func requestAssetVideoURL(toFile fileURL:URL? = nil, resultHandler: @escaping (URL?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            if let fileURL = fileURL {
                if fileURL.path == videoEdit.editedURL.path {
                    resultHandler(fileURL)
                    return
                }
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                    try FileManager.default.copyItem(at: videoEdit.editedURL, to: fileURL)
                    resultHandler(fileURL)
                } catch  {
                    resultHandler(nil)
                }
            }else {
                resultHandler(videoEdit.editedURL)
            }
            return
        }
        #endif
        let toFile = fileURL == nil ? PhotoTools.getVideoTmpURL() : fileURL!
        if mediaSubType == .livePhoto {
            AssetManager.requestLivePhoto(videoURL: phAsset!, toFile: toFile) { (videoURL, error) in
                resultHandler(videoURL)
            }
        }else {
            if mediaType == .photo {
                resultHandler(nil)
                return
            }
            AssetManager.requestVideoURL(for: phAsset!, toFile: toFile) { (videoURL) in
                resultHandler(videoURL)
            }
        }
    }
}
