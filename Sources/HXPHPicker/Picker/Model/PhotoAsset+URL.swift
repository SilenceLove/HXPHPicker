//
//  PhotoAsset+URL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/7/19.
//

import UIKit

public typealias AssetURLCompletion = (Result<PhotoAssetURLResponse, PhotoAssetError>) -> Void

public enum PhotoAssetError: Error {
    /// 写入文件失败
    case fileWriteFailed
    /// 导出失败
    case exportFailed
    /// 无效的 Data
    case invalidData
    /// phAsset为空
    case invalidPHAsset
    /// 网络地址为空
    case emptyNetworkURL
    /// 本地地址为空
    case emptyLocalURL
    /// 类型错误
    case typeError
}

public struct PhotoAssetURLResponse {
    public enum URLType {
        /// 本地
        case local
        /// 网络
        case network
    }
    /// 地址
    public let url: URL
    /// URL类型
    public let urlType: URLType
    /// 媒体类型
    public let mediaType: PhotoAsset.MediaType
}

public extension PhotoAsset {
    
    /// 获取url
    ///   - completion: result 
    func getAssetURL(completion: @escaping AssetURLCompletion) {
        if mediaType == .photo {
            getImageURL(completion: completion)
        }else {
            getVideoURL(completion: completion)
        }
    }
    
    /// 获取图片url
    ///   - completion: result
    func getImageURL(completion: @escaping AssetURLCompletion) {
        #if canImport(Kingfisher)
        if isNetworkAsset {
            getNetworkImageURL(resultHandler: completion)
            return
        }
        #endif
        requestImageURL(resultHandler: completion)
    }
    
    /// 获取视频url
    /// - Parameters:
    ///   - exportPreset: 导出质量
    ///   - completion: result
    func getVideoURL(exportPreset: String? = nil,
                     completion: @escaping AssetURLCompletion) {
        if isNetworkAsset {
            getNetworkVideoURL(resultHandler: completion)
            return
        }
        requestVideoURL(exportPreset: exportPreset, resultHandler: completion)
    }
}
