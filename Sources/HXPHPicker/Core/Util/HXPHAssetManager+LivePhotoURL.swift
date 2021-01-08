//
//  HXPHAssetManager+LivePhotoURL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import Foundation
import Photos

public extension HXPHAssetManager {
    
    // MARK: 获取LivePhoto里的图片Data和视频地址
    class func requestLivePhoto(content asset: PHAsset, imageDataHandler: @escaping (Data?) -> Void, videoHandler: @escaping (URL?) -> Void, completionHandler: @escaping (HXPHLivePhotoError?) -> Void) {
        if #available(iOS 9.1, *) {
            _ = requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize) { (ID) in
            } progressHandler: { (progress, error, stop, info) in
            } resultHandler: { (livePhoto, info, downloadSuccess) in
                if livePhoto == nil {
                    completionHandler(.allError(HXPHError.error(message: "livePhoto为nil，获取失败"), HXPHError.error(message: "livePhoto为nil，获取失败")))
                    return
                }
                let assetResources: [PHAssetResource] = PHAssetResource.assetResources(for: livePhoto!)
                if assetResources.isEmpty {
                    completionHandler(.allError(HXPHError.error(message: "assetResources为nil，获取失败"), HXPHError.error(message: "assetResources为nil，获取失败")))
                    return
                }
                let options = PHAssetResourceRequestOptions.init()
                options.isNetworkAccessAllowed = true
                var imageCompletion = false
                var imageError: Error?
                var videoCompletion = false
                var videoError: Error?
                var imageData: Data?
                let videoURL = HXPHTools.getVideoTmpURL()
                let callback = {(imageError: Error?, videoError: Error?) in
                    if imageError != nil && videoError != nil {
                        completionHandler(.allError(imageError, videoError))
                    }else if imageError != nil {
                        completionHandler(.imageError(imageError))
                    }else if videoError != nil {
                        completionHandler(.videoError(videoError))
                    }else {
                        completionHandler(nil)
                    }
                }
                for assetResource in assetResources {
                    if assetResource.type == .photo {
                        PHAssetResourceManager.default().requestData(for: assetResource, options: options) { (data) in
                            imageData = data
                            DispatchQueue.main.async {
                                imageDataHandler(imageData)
                            }
                        } completionHandler: { (error) in
                            imageError = error
                            DispatchQueue.main.async {
                                if videoCompletion {
                                    callback(imageError, videoError)
                                }
                                imageCompletion = true
                            }
                        }
                    }else if assetResource.type == .pairedVideo {
                        PHAssetResourceManager.default().writeData(for: assetResource, toFile: videoURL, options: options) { (error) in
                            DispatchQueue.main.async {
                                if error == nil {
                                    videoHandler(videoURL)
                                }
                                videoCompletion = true
                                videoError = error
                                if imageCompletion {
                                    callback(imageError, videoError)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            completionHandler(.allError(HXPHError.error(message: "系统版本低于9.1"), HXPHError.error(message: "系统版本低于9.1")))
        }
    }
    // MARK: 获取LivePhoto里的图片地址和视频地址
    class func requestLivePhoto(contentURL asset: PHAsset, imageURLHandler: @escaping (URL?) -> Void, videoHandler: @escaping (URL?) -> Void, completionHandler: @escaping (HXPHLivePhotoError?) -> Void) {
        if #available(iOS 9.1, *) {
            _ = requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize) { (ID) in
            } progressHandler: { (progress, error, stop, info) in
            } resultHandler: { (livePhoto, info, downloadSuccess) in
                if livePhoto == nil {
                    completionHandler(.allError(HXPHError.error(message: "livePhoto为nil，获取失败"), HXPHError.error(message: "livePhoto为nil，获取失败")))
                    return
                }
                let assetResources: [PHAssetResource] = PHAssetResource.assetResources(for: livePhoto!)
                if assetResources.isEmpty {
                    completionHandler(.allError(HXPHError.error(message: "assetResources为nil，获取失败"), HXPHError.error(message: "assetResources为nil，获取失败")))
                    return
                }
                let options = PHAssetResourceRequestOptions.init()
                options.isNetworkAccessAllowed = true
                var imageCompletion = false
                var imageError: Error?
                var videoCompletion = false
                var videoError: Error?
                let imageURL = HXPHTools.getImageTmpURL()
                let videoURL = HXPHTools.getVideoTmpURL()
                let callback = {(imageError: Error?, videoError: Error?) in
                    if imageError != nil && videoError != nil {
                        completionHandler(.allError(imageError, videoError))
                    }else if imageError != nil {
                        completionHandler(.imageError(imageError))
                    }else if videoError != nil {
                        completionHandler(.videoError(videoError))
                    }else {
                        completionHandler(nil)
                    }
                }
                for assetResource in assetResources {
                    if assetResource.type == .photo {
                        PHAssetResourceManager.default().writeData(for: assetResource, toFile: imageURL, options: options) { (error) in
                            DispatchQueue.main.async {
                                if error == nil {
                                    imageURLHandler(imageURL)
                                }
                                imageCompletion = true
                                imageError = error
                                if videoCompletion {
                                    callback(imageError, videoError)
                                }
                            }
                        }
                    }else if assetResource.type == .pairedVideo {
                        PHAssetResourceManager.default().writeData(for: assetResource, toFile: videoURL, options: options) { (error) in
                            DispatchQueue.main.async {
                                if error == nil {
                                    videoHandler(videoURL)
                                }
                                videoCompletion = true
                                videoError = error
                                if imageCompletion {
                                    callback(imageError, videoError)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            completionHandler(.allError(HXPHError.error(message: "系统版本低于9.1"), HXPHError.error(message: "系统版本低于9.1")))
        }
    }
}
