//
//  Picker+UIImageView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/26.
//

import UIKit
#if canImport(Kingfisher)
import Kingfisher
#endif

extension UIImageView {
    
    #if canImport(Kingfisher)
    func setImage(
        for asset: PhotoAsset,
        urlType: DonwloadURLType,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((UIImage?, KingfisherError?) -> Void)? = nil) {
        
        if let imageAsset = asset.networkImageAsset {
            if let photoEdit = asset.photoEdit {
                image = photoEdit.editedImage
                completionHandler?(photoEdit.editedImage, nil)
                return
            }
            let isThumbnail = urlType == .thumbnail
            if isThumbnail {
                kf.indicatorType = .activity
            }
            let url = isThumbnail ? imageAsset.thumbnailURL : imageAsset.originalURL
            let placeholderImage = UIImage.image(for: imageAsset.placeholder)
            let processor = DownsamplingImageProcessor(size: imageAsset.thumbnailSize)
            let options: KingfisherOptionsInfo = isThumbnail ? [.onlyLoadFirstFrame, .backgroundDecode, .processor(processor), .cacheOriginalImage] : [.backgroundDecode]
            
            kf.setImage(with: url, placeholder: placeholderImage, options: options, progressBlock: progressBlock) { (result) in
                switch result {
                case .success(let value):
                    if asset.localImageAsset == nil {
                        let localImageAsset = LocalImageAsset.init(image: value.image)
                        asset.localImageAsset = localImageAsset
                    }
                    asset.networkImageAsset?.imageSize = value.image.size
                    if asset.localImageType != .original && !isThumbnail {
                        if let imageData = value.image.kf.data(format: asset.mediaSubType.isGif ? .GIF : .unknown) {
                            asset.networkImageAsset?.fileSize = imageData.count
                        }
                        asset.localImageType = urlType
                    }
                    completionHandler?(value.image, nil)
                case .failure(let error):
                    completionHandler?(nil, error)
                }
            }
        }
    }
    #endif
    
}
