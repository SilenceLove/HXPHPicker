//
//  PhotoAsset+Network.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/24.
//

#if canImport(Kingfisher)
import UIKit
import Kingfisher

public enum DonwloadURLType {
    case thumbnail
    case original
}

public extension PhotoAsset {
    
    /// 获取网络图片的地址，编辑过就是本地地址，未编辑就是网络地址
    /// - Parameter resultHandler: 地址、是否为网络地址
    func getNetworkImageURL(resultHandler: @escaping (URL?, Bool) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if photoEdit != nil {
            requestLocalImageURL { (url) in
                resultHandler(url, false)
            }
            return
        }
        #endif
        resultHandler(networkImageAsset?.originalURL, true)
    }
    
    /// 获取网络图片
    /// - Parameters:
    ///   - filterEditor: 过滤编辑的数据
    ///   - resultHandler: 获取结果
    func getNetworkImage(urlType: DonwloadURLType = .original, filterEditor: Bool = false, resultHandler: @escaping (UIImage?) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if photoEdit != nil && !filterEditor {
            let image = getOriginalImage()
            resultHandler(image)
            return
        }
        #endif
        let url = networkImageAsset!.originalURL
        let key = url.cacheKey
        if ImageCache.default.isCached(forKey: key) {
            ImageCache.default.retrieveImage(forKey: key) { (result) in
                switch result {
                case .success(let value):
                    resultHandler(value.image)
                case .failure(_):
                    resultHandler(nil)
                }
            }
            return
        }
        ImageDownloader.default.downloadImage(with: url, options: [.backgroundDecode, .onlyLoadFirstFrame, .cacheOriginalImage]) { (result) in
            switch result {
            case .success(let value):
                ImageCache.default.store(value.image, forKey: key)
                resultHandler(value.image)
            case .failure(_):
                resultHandler(nil)
            }
        }
    }
}
#endif
