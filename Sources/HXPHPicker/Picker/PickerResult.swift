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
    
    /// 获取已选资源的地址（原图）
    /// - Parameters:
    ///   - options: 获取的类型
    ///         photo    视频获取的是封面图片地址，LivePhoto获取的URL为封面图片地址
    ///         video    LivePhoto获取的URL为内部视频地址，会过滤其他图片
    ///                  LivePhoto如果编辑过，获取的只会是编辑后的图片URL
    ///   - completion: result
    public func getURLs(options: Options = .any, completion: @escaping ([URL]) -> Void) {
        let group = DispatchGroup.init()
        let queue = DispatchQueue.init(label: "hxphpicker.request.urls")
        var urls: [URL] = []
        for photoAsset in photoAssets {
            queue.async(group: group, execute: DispatchWorkItem.init(block: {
                let semaphore = DispatchSemaphore.init(value: 0)
                var mediatype: PhotoAsset.MediaType
                if options.contains([.photo]) {
                    mediatype = .photo
                }else if options.contains([.video]){
                    mediatype = .video
                }else {
                    mediatype = photoAsset.mediaType
                }
                if photoAsset.mediaSubType == .livePhoto && photoAsset.photoEdit != nil {
                    mediatype = .photo
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
