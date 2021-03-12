//
//  PickerResult.swift
//  HXPHPicker
//
//  Created by Slience on 2021/3/8.
//

import Foundation

public struct PickerResult {
    
    /// 已选的资源
    public let photoAssets: [PhotoAsset]
    
    /// 是否选择的原图
    public let isOriginal: Bool
    
    /// 获取已选资源的地址
    /// - Parameters:
    ///   - type: 获取的类型
    ///     type = photo    视频获取的是封面图片地址，LivePhoto获取的URL为封面图片地址
    ///     type = video    LivePhoto获取的URL为内部视频地址，会过滤其他图片
    ///     type = any      LivePhoto获取的URL为封面图片地址     
    ///   - completion: result
    public func getURLs(type: URLType = .any, completion: @escaping ([URL]) -> Void) {
        let group = DispatchGroup.init()
        let queue = DispatchQueue.init(label: "hxphpicker.request.imageurl")
        var urls: [URL] = []
        for photoAsset in photoAssets {
            queue.async(group: group, execute: DispatchWorkItem.init(block: {
                let semaphore = DispatchSemaphore.init(value: 0)
                var mediatype: PhotoAsset.MediaType
                if type == .any {
                    mediatype = photoAsset.mediaType
                }else if type == .photo {
                    mediatype = .photo
                }else {
                    mediatype = .video
                }
                if mediatype == .photo {
                    photoAsset.requestImageURL { (url) in
                        if let url = url {
                            urls.append(url)
                        }
                        semaphore.signal()
                    }
                }else {
                    photoAsset.requestVideoURL { (url) in
                        if let url = url {
                            urls.append(url)
                        }
                        semaphore.signal()
                    }
                }
                semaphore.wait()
            }))
        }
        group.notify(queue: .main) {
            completion(urls)
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - photoAssets: 对应 PhotoAsset 数据的数组
    ///   - isOriginal: 是否原图
    public init(photoAssets: [PhotoAsset], isOriginal: Bool) {
        self.photoAssets = photoAssets
        self.isOriginal = isOriginal
    }
}
