//
//  PhotoAsset+URL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/7/19.
//

import UIKit

public extension PhotoAsset {
    
    typealias AssetURLCompletion = (Result<AssetURLResult, AssetError>) -> Void
    
    enum AssetError: Error {
        /// 写入文件失败
        case fileWriteFailed
        /// 导出失败
        case exportFailed(Error?)
        /// 无效的 Data
        case invalidData
        /// phAsset为空
        case invalidPHAsset
        /// 网络地址为空
        case networkURLIsEmpty
        /// 本地地址为空
        case localURLIsEmpty
        /// 类型错误，例：本来是 .photo 却去获取 videoURL
        case typeError
        /// 从系统相册获取数据失败, [AnyHashable : Any]?: 系统获取失败的信息
        case requestFailed([AnyHashable : Any]?)
        /// 需要同步ICloud上的资源
        case needSyncICloud
        /// 同步ICloud失败
        case syncICloudFailed([AnyHashable : Any]?)
        /// 指定地址存在其他文件，删除已存在的文件时发生错误
        case removeFileFailed
        /// PHAssetResource 为空
        case assetResourceIsEmpty
        /// PHAssetResource写入数据错误
        case assetResourceWriteDataFailed(Error)
    }
    
    struct AssetURLResult {
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
    ///   - exportPreset: 导出质量，不传获取的就是原始视频
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
