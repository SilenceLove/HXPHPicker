//
//  AssetManager+AVAssetExportSession.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/9.
//

import UIKit
import Photos

public typealias AVAssetExportSessionResultHandler = (AVAssetExportSession?, [AnyHashable : Any]?) -> Void
public extension AssetManager {
    
    /// 获取 AVAssetExportSession
    /// - Parameters:
    ///   - asset: 对应视频的 PHAsset 对象
    ///   - exportPreset: 导出预设
    ///   - iCloudHandler: 如果资源在iCloud上，下载之前回先回调出请求ID
    ///   - progressHandler: iCloud下载进度
    ///   - resultHandler: AVAssetExportSession
    /// - Returns: 请求ID
    @discardableResult
    class func requestExportSession(forVideo asset: PHAsset,
                                           exportPreset: String,
                                           deliveryMode: PHVideoRequestOptionsDeliveryMode = .automatic,
                                           iCloudHandler: ((PHImageRequestID) -> Void)?,
                                           progressHandler: PHAssetVideoProgressHandler?,
                                           resultHandler: @escaping (AVAssetExportSession?, [AnyHashable : Any]?, Bool) -> Void) -> PHImageRequestID {
        let version = PHVideoRequestOptionsVersion.current
        return requestExportSession(forVideo: asset, exportPreset: exportPreset, version: version, deliveryMode: deliveryMode, isNetworkAccessAllowed: false, progressHandler: progressHandler) { (exportSession, info) in
            DispatchQueue.main.async {
                if self.assetDownloadFinined(for: info) {
                    resultHandler(exportSession, info, true)
                }else {
                    if self.assetIsInCloud(for: info) {
                        let iCloudRequestID = self.requestExportSession(forVideo: asset, exportPreset: exportPreset, version: version, deliveryMode: deliveryMode, isNetworkAccessAllowed: true, progressHandler: progressHandler) { (iCloudExportSession, iCloudInfo) in
                            DispatchQueue.main.async {
                                if self.assetDownloadFinined(for: iCloudInfo) {
                                    resultHandler(iCloudExportSession, iCloudInfo, true)
                                }else {
                                    resultHandler(nil, iCloudInfo, false)
                                }
                            }
                        }
                        iCloudHandler?(iCloudRequestID)
                    }else {
                        resultHandler(nil, info, false)
                    }
                }
            }
        }
    }
    
    /// 获取 AVAssetExportSession
    @discardableResult
    class func requestExportSession(forVideo asset: PHAsset,
                                    exportPreset: String,
                                    version: PHVideoRequestOptionsVersion,
                                    deliveryMode: PHVideoRequestOptionsDeliveryMode,
                                    isNetworkAccessAllowed: Bool,
                                    progressHandler: PHAssetVideoProgressHandler?,
                                    resultHandler: @escaping AVAssetExportSessionResultHandler) -> PHImageRequestID {
        let options = PHVideoRequestOptions.init()
        options.version = version
        options.deliveryMode = deliveryMode
        options.isNetworkAccessAllowed = isNetworkAccessAllowed
        options.progressHandler = progressHandler
        return requestExportSession(forVideo: asset, options: options, exportPreset: exportPreset, resultHandler: resultHandler)
    }
    
    
    /// 获取 AVAssetExportSession
    @discardableResult
    class func requestExportSession(forVideo asset: PHAsset,
                                           options: PHVideoRequestOptions,
                                           exportPreset: String,
                                           resultHandler: @escaping AVAssetExportSessionResultHandler) -> PHImageRequestID {
        
        return PHImageManager.default().requestExportSession(forVideo: asset,
                                                             options: options,
                                                             exportPreset: exportPreset, resultHandler:
                                                                resultHandler)
    }
}
