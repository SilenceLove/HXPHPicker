//
//  PhotoTools.swift
//  照片选择器-Swift
//
//  Created by Silence on 2019/6/29.
//  Copyright © 2019年 Silence. All rights reserved.
//

import UIKit
import Photos
#if canImport(Kingfisher)
import Kingfisher
#endif

public class PhotoTools {
    
    /// 跳转系统设置界面
    public class func openSettingsURL() {
        if let openURL = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(openURL)
            }
        }
    }
    
    /// 显示UIAlertController
    public class func showAlert(viewController: UIViewController? ,
                                title: String? ,
                                message: String? = nil,
                                leftActionTitle: String? ,
                                leftHandler: ((UIAlertAction) -> Void)?,
                                rightActionTitle: String? ,
                                rightHandler: ((UIAlertAction) -> Void)?) {
        guard let viewController = viewController else { return }
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if let leftActionTitle = leftActionTitle {
            let leftAction = UIAlertAction.init(title: leftActionTitle, style: UIAlertAction.Style.cancel, handler: leftHandler)
            alertController.addAction(leftAction)
        }
        if let rightActionTitle = rightActionTitle {
            let rightAction = UIAlertAction.init(title: rightActionTitle, style: UIAlertAction.Style.default, handler: rightHandler)
            alertController.addAction(rightAction)
        }
        if UIDevice.isPad {
            let pop = alertController.popoverPresentationController
            pop?.permittedArrowDirections = .any
            pop?.sourceView = viewController.view
            pop?.sourceRect = CGRect(x: viewController.view.width * 0.5, y: viewController.view.height, width: 0, height: 0)
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    public class func showConfirm(viewController: UIViewController? ,
                                  title: String? ,
                                  message: String?,
                                  actionTitle: String?,
                                  actionHandler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if UIDevice.isPad {
            let pop = alertController.popoverPresentationController
            pop?.permittedArrowDirections = .any
            pop?.sourceView = viewController?.view
            pop?.sourceRect = viewController?.view.bounds ?? .zero
        }
        if let actionTitle = actionTitle {
            let action = UIAlertAction.init(title: actionTitle, style: UIAlertAction.Style.cancel, handler: actionHandler)
            alertController.addAction(action)
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// 根据PHAsset资源获取对应的目标大小
    public class func transformTargetWidthToSize(targetWidth: CGFloat,
                                                 asset: PHAsset) -> CGSize {
        let scale:CGFloat = 0.8
        let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        var width = targetWidth
        if asset.pixelWidth < Int(targetWidth) {
            width *= 0.5
        }
        var height = width / aspectRatio
        let maxHeight = UIScreen.main.bounds.size.height
        if height > maxHeight {
            width = maxHeight / height * width * scale
            height = maxHeight * scale
        }
        if height < targetWidth && width >= targetWidth {
            width = targetWidth / height * width * scale
            height = targetWidth * scale
        }
        return CGSize.init(width: width, height: height)
    }
    
    /// 转换视频时长为 mm:ss 格式的字符串
    public class func transformVideoDurationToString(duration: TimeInterval) -> String {
        let time = Int(round(Double(duration)))
        if time < 10 {
            return String.init(format: "00:0%d", arguments: [time])
        }else if time < 60 {
            return String.init(format: "00:%d", arguments: [time])
        }else {
            var min = Int(time / 60)
            let sec = time - (min * 60)
            if min < 60 {
                if sec < 10 {
                    return String.init(format: "%d:0%d", arguments: [min,sec])
                }else {
                    return String.init(format: "%d:%d", arguments: [min,sec])
                }
            }else {
                let hour = Int(min / 60)
                min -= hour * 60
                if min < 10 {
                    if sec < 10 {
                        return String.init(format: "%d:0%d:0%d", arguments: [hour,min,sec])
                    }else {
                        return String.init(format: "%d:0%d:%d", arguments: [hour,min,sec])
                    }
                }else {
                    if sec < 10 {
                        return String.init(format: "%d:%d:0%d", arguments: [hour,min,sec])
                    }else {
                        return String.init(format: "%d:%d:%d", arguments: [hour,min,sec])
                    }
                }
            }
        }
    }
    
    /// 根据视频地址获取视频时长
    public class func getVideoDuration(videoURL: URL?) -> TimeInterval {
        if videoURL == nil {
            return 0
        }
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: false]
        let urlAsset = AVURLAsset.init(url: videoURL!, options: options)
//        let second = TimeInterval(urlAsset.duration.value) / TimeInterval(urlAsset.duration.timescale)
        return TimeInterval(round(urlAsset.duration.seconds))
    }
    
    /// 根据视频时长(00:00:00)获取秒
    class func getVideoTime(forVideo duration: String) -> TimeInterval {
        var m = 0
        var s = 0
        var ms = 0
        let components = duration.components(separatedBy: CharacterSet.init(charactersIn: ":."))
        if components.count >= 2 {
            m = Int(components[0]) ?? 0
            s = Int(components[1]) ?? 0
            if components.count == 3 {
                ms = Int(components[2]) ?? 0
            }
        }else {
            s = Int(INT_MAX)
        }
        return TimeInterval(CGFloat(m * 60) + CGFloat(s) + CGFloat(ms) * 0.001)
    }
    
    /// 根据视频地址获取视频封面
    public class func getVideoThumbnailImage(videoURL: URL?,
                                             atTime: TimeInterval) -> UIImage? {
        if videoURL == nil {
            return nil
        }
        let urlAsset = AVURLAsset.init(url: videoURL!)
        return getVideoThumbnailImage(avAsset: urlAsset as AVAsset, atTime: atTime)
    }
    
    /// 根据视频地址获取视频封面
    public class func getVideoThumbnailImage(avAsset: AVAsset?,
                                             atTime: TimeInterval) -> UIImage? {
        if let avAsset = avAsset {
            let assetImageGenerator = AVAssetImageGenerator.init(asset: avAsset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.apertureMode = .encodedPixels
            do {
                let thumbnailImageRef = try assetImageGenerator.copyCGImage(at: CMTime(value: CMTimeValue(atTime), timescale: avAsset.duration.timescale), actualTime: nil)
                let image = UIImage.init(cgImage: thumbnailImageRef)
                return image
            } catch { }
        }
        return nil
    }
    
    /// 获视频缩略图
    public class  func getVideoThumbnailImage(url: URL, atTime: TimeInterval, completion: @escaping (URL, UIImage) -> Void) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceAfter = .zero
            generator.requestedTimeToleranceBefore = .zero
            let time = CMTime(value: CMTimeValue(atTime), timescale: asset.duration.timescale)
            let array = [NSValue(time: time)]
            generator.generateCGImagesAsynchronously(forTimes: array) { (requestedTime, cgImage, actualTime, result, error) in
                if let image = cgImage, result == .succeeded {
                    DispatchQueue.main.async {
                        completion(url, UIImage(cgImage: image))
                    }
                }
            }
        }
    }
    
    #if canImport(Kingfisher)
    public class func downloadNetworkImage(
        with url: URL,
        cancelOrigianl: Bool = true,
        options: KingfisherOptionsInfo,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((UIImage?) -> Void)? = nil)
    {
        let key = url.cacheKey
        if ImageCache.default.isCached(forKey: key) {
            ImageCache.default.retrieveImage(
                forKey: key,
                options: options)
            { (result) in
                switch result {
                case .success(let value):
                    completionHandler?(value.image)
                case .failure(_):
                    completionHandler?(nil)
                }
            }
            return
        }
        ImageDownloader.default.downloadImage(with: url, options: options, progressBlock: progressBlock) { (result) in
            switch result {
            case .success(let value):
                if let gifImage = DefaultImageProcessor.default.process(item: .data(value.originalData), options: .init([]))  {
                    if cancelOrigianl {
                        ImageCache.default.store(gifImage, original: value.originalData, forKey: key)
                    }
                    completionHandler?(gifImage)
                    return
                }
                if cancelOrigianl {
                    ImageCache.default.store(value.image, original: value.originalData, forKey: key)
                }
                completionHandler?(value.image)
            case .failure(_):
                completionHandler?(nil)
            }
        }
    }
    #endif
    
    class func transformImageSize(_ imageSize: CGSize, to view: UIView) -> CGRect {
        return transformImageSize(imageSize, toViewSize: view.size)
    }
    
    class func transformImageSize(_ imageSize: CGSize, toViewSize viewSize: CGSize, directions: [PhotoToolsTransformImageSizeDirections] = [.horizontal, .vertical]) -> CGRect {
        var size: CGSize = .zero
        var center: CGPoint = .zero
        
        func handleVertical(_ imageSize: CGSize, _ viewSize: CGSize) -> (CGSize, CGPoint) {
            let aspectRatio = viewSize.width / imageSize.width
            let contentWidth = viewSize.width
            let contentHeight = imageSize.height * aspectRatio
            let _size = CGSize(width: contentWidth, height: contentHeight)
            if contentHeight < viewSize.height {
                let center = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.5)
                return (_size, center)
            }
            return (_size, .zero)
        }
        func handleHorizontal(_ imageSize: CGSize, _ viewSize: CGSize) -> (CGSize, CGPoint) {
            let aspectRatio = viewSize.height / imageSize.height
            var contentWidth = imageSize.width * aspectRatio
            var contentHeight = viewSize.height
            if contentWidth > viewSize.width {
                contentHeight = viewSize.width / contentWidth * contentHeight
                contentWidth = viewSize.width
            }
            let _size = CGSize(width: contentWidth, height: contentHeight)
            if contentHeight < viewSize.height {
                let center = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.5)
                return (_size, center)
            }
            return (_size, .zero)
        }
        
        if directions.contains(.horizontal) && directions.contains(.vertical) {
            if UIDevice.isPortrait {
                let content = handleVertical(imageSize, viewSize)
                size = content.0
                center = content.1
            }else {
                let content = handleHorizontal(imageSize, viewSize)
                size = content.0
                if !content.1.equalTo(.zero) {
                    center = content.1
                }
            }
        }else if directions.contains(.horizontal) {
            size = handleHorizontal(imageSize, viewSize).0
        }else if directions.contains(.vertical) {
            let content = handleVertical(imageSize, viewSize)
            size = content.0
            center = content.1
        }
//        if UIDevice.isPortrait {
//            let aspectRatio = viewSize.width / imageSize.width
//            let contentWidth = viewSize.width
//            let contentHeight = imageSize.height * aspectRatio
//            imageSize = CGSize(width: contentWidth, height: contentHeight)
//            if contentHeight < viewSize.height {
//                imageCenter = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.5)
//            }
//        }else {
//            let aspectRatio = viewSize.height / imageSize.height
//            let contentWidth = imageSize.width * aspectRatio
//            let contentHeight = viewSize.height
//            imageSize = CGSize(width: contentWidth, height: contentHeight)
//        }
        var rectY: CGFloat
        if center.equalTo(.zero) {
            rectY = 0
        }else {
            rectY = (viewSize.height - size.height) * 0.5
        }
        return CGRect(x: (viewSize.width - size.width) * 0.5, y: rectY, width: size.width, height: size.height)
    }
    
    class func exportSessionFileLengthLimit(
        seconds: Double,
        exportPreset: ExportPreset,
        videoQuality: Int) -> Int64
    {
        if videoQuality > 0 {
            var ratioParam: Double = 0
            if exportPreset == .ratio_640x480 {
                ratioParam = 0.02
            }else if exportPreset == .ratio_960x540 {
                ratioParam = 0.04
            }else if exportPreset == .ratio_1280x720 {
                ratioParam = 0.08
            }
            let quality = Double(min(videoQuality, 10))
            return Int64(seconds * ratioParam * quality * 1000 * 1000)
        }
        return 0
    }
}

enum PhotoToolsTransformImageSizeDirections {
    case horizontal
    case vertical
}
