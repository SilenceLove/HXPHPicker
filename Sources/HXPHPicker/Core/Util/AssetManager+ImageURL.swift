//
//  AssetManager+ImageURL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import UIKit
import Photos

public typealias ImageURLResultHandler = (URL?) -> Void

// MARK: 获取图片地址
public extension AssetManager {
    
    /// 请求获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    class func requestImageURL(for asset: PHAsset, resultHandler: @escaping ImageURLResultHandler) {
        requestImageURL(for: asset, suffix: "jpeg", resultHandler: resultHandler)
    }
    
    /// 请求获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - suffix: 后缀格式
    ///   - resultHandler: 获取结果
    class func requestImageURL(for asset: PHAsset, suffix: String, resultHandler: @escaping ImageURLResultHandler) {
        let imageResource = PHAssetResource.assetResources(for: asset).first
        if imageResource == nil {
            resultHandler(nil)
            return
        }
        let imageURL = PhotoTools.getTmpURL(for: suffix)
        let options = PHAssetResourceRequestOptions.init()
        options.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: imageResource!, toFile: imageURL, options: options) { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    resultHandler(imageURL)
                }else {
                    resultHandler(nil)
                }
            }
        }
    }
    
    /// 请求获取图片地址，不建议使用此方法获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    /// - Returns: 请求ID
    class func requestImageURL(for asset: PHAsset, resultHandler: @escaping (URL?, UIImage?) -> Void) -> PHContentEditingInputRequestID {
        let options = PHContentEditingInputRequestOptions.init()
        options.isNetworkAccessAllowed = true
        return asset.requestContentEditingInput(with: options) { (input, info) in
            DispatchQueue.main.async {
                resultHandler(input?.fullSizeImageURL, input?.displaySizeImage)
            }
        }
    }
}
