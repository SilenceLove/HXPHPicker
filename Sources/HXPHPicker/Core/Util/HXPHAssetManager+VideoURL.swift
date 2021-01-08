//
//  HXPHAssetManager+VideoURL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import UIKit
import Photos

public typealias VideoURLResultHandler = (URL?) -> Void

// MARK: 获取视频地址
public extension HXPHAssetManager {
    
    /// 请求获取视频地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    class func requestVideoURL(for asset: PHAsset, resultHandler: @escaping VideoURLResultHandler) {
        _ = requestAVAsset(for: asset) { (reqeustID) in
        } progressHandler: { (progress, error, stop, info) in
        } resultHandler: { (avAsset, audioMix, info, downloadSuccess) in
            DispatchQueue.main.async {
                if avAsset is AVURLAsset {
                    let urlAsset = avAsset as! AVURLAsset
                    resultHandler(urlAsset.url)
                }else {
                    self.requestVideoURL(mp4Format: asset, resultHandler: resultHandler)
                }
            }
        }
    }
    
    /// 请求获取mp4格式的视频地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    class func requestVideoURL(mp4Format asset: PHAsset, resultHandler: @escaping VideoURLResultHandler) {
        let videoResource = PHAssetResource.assetResources(for: asset).first
        if videoResource == nil {
            resultHandler(nil)
            return
        }
        let videoURL = HXPHTools.getVideoTmpURL()
        let options = PHAssetResourceRequestOptions.init()
        options.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: videoResource!, toFile: videoURL, options: options) { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    resultHandler(videoURL)
                }else {
                    resultHandler(nil)
                }
            }
        }
    }
}
