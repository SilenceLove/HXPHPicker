//
//  PhotoAsset+Request.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/11.
//

import UIKit
import Photos


// MARK: Request Photo
public extension PhotoAsset {
    
    /// 获取原始图片地址
    func requestImageURL(resultHandler: @escaping (URL?) -> Void) {
        if phAsset == nil {
            requestLocalImageURL(resultHandler: resultHandler)
            return
        }
        requestAssetImageURL(resultHandler: resultHandler)
    }
    
    /// 请求获取缩略图
    /// - Parameter completion: 完成回调
    /// - Returns: 请求ID
    func requestThumbnailImage(targetWidth: CGFloat = 180, completion: ((UIImage?, PhotoAsset, [AnyHashable : Any]?) -> Void)?) -> PHImageRequestID? {
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoEdit {
            completion?(photoEdit.editedImage, self, nil)
            return nil
        }
        if let videoEdit = videoEdit {
            completion?(videoEdit.coverImage, self, nil)
            return nil
        }
        #endif
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
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoEdit {
            DispatchQueue.global().async {
                let imageData = PhotoTools.getImageData(for: photoEdit.editedImage)
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        success?(self, imageData, photoEdit.editedImage.imageOrientation, nil)
                    }else {
                        failure?(self, nil)
                    }
                }
            }
            return 0
        }
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
        #endif
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
}

// MARK: Request LivePhoto
public extension PhotoAsset {
    
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
}


// MARK: Request Video
public extension PhotoAsset {
    
    /// 获取原始视频地址
    func requestVideoURL(resultHandler: @escaping (URL?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit {
            resultHandler(videoEdit.editedURL)
            return
        }
        #endif
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
    
    /// 请求AVAsset，如果资源在iCloud上会自动下载。如果需要更细节的处理请查看 PHAssetManager+Asset
    /// - Parameters:
    ///   - filterEditor: 过滤编辑过的视频，取原视频
    ///   - iCloudHandler: 下载iCloud上的资源时回调iCloud的请求ID
    ///   - progressHandler: iCloud下载进度
    /// - Returns: 请求ID
    func requestAVAsset(filterEditor: Bool = false, deliveryMode: PHVideoRequestOptionsDeliveryMode = .automatic, iCloudHandler: PhotoAssetICloudHandlerHandler?, progressHandler: PhotoAssetProgressHandler?, success: ((PhotoAsset, AVAsset, [AnyHashable : Any]?) -> Void)?, failure: PhotoAssetFailureHandler?) -> PHImageRequestID {
        #if HXPICKER_ENABLE_EDITOR
        if let videoEdit = videoEdit, !filterEditor {
            success?(self, AVAsset.init(url: videoEdit.editedURL), nil)
            return 0
        }
        #endif
        if phAsset == nil {
            if localVideoURL != nil {
                success?(self, AVAsset.init(url: localVideoURL!), nil)
            }else {
                failure?(self, nil)
            }
            return 0
        }
        downloadStatus = .downloading
        return AssetManager.requestAVAsset(for: phAsset!, deliveryMode: deliveryMode) { (iCloudRequestID) in
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
}
