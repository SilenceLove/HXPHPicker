//
//  PhotoTools.swift
//  照片选择器-Swift
//
//  Created by Silence on 2019/6/29.
//  Copyright © 2019年 Silence. All rights reserved.
//

import UIKit
import Photos

public typealias statusHandler = (PHAuthorizationStatus) -> ()

public class PhotoTools {
    
    /// 跳转系统设置界面
    public class func openSettingsURL() {
        if #available(iOS 10, *) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    /// 显示UIAlertController
    public class func showAlert(viewController: UIViewController? , title: String? , message: String? , leftActionTitle: String? ,  leftHandler: ((UIAlertAction) -> Void)?, rightActionTitle: String? , rightHandler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if let leftActionTitle = leftActionTitle {
            let leftAction = UIAlertAction.init(title: leftActionTitle, style: UIAlertAction.Style.cancel, handler: leftHandler)
            alertController.addAction(leftAction)
        }
        if let rightActionTitle = rightActionTitle {
            let rightAction = UIAlertAction.init(title: rightActionTitle, style: UIAlertAction.Style.default, handler: rightHandler)
            alertController.addAction(rightAction)
        }
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    /// 根据PHAsset资源获取对应的目标大小
    public class func transformTargetWidthToSize(targetWidth: CGFloat, asset: PHAsset) -> CGSize {
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
    /// 获取对应后缀的临时路径
    public class func getTmpURL(for suffix: String) -> URL {
        var tmpPath = NSTemporaryDirectory()
        tmpPath.append(contentsOf: String.fileName(suffix: suffix))
        let tmpURL = URL.init(fileURLWithPath: tmpPath)
        return tmpURL
    }
    /// 获取图片临时路径
    public class func getImageTmpURL() -> URL {
        return getTmpURL(for: "jpeg")
    }
    /// 获取视频临时路径
    public class func getVideoTmpURL() -> URL {
        return getTmpURL(for: "mp4")
    }
    
    /// 转换视频时长为 mm:ss 格式的字符串
    public class func transformVideoDurationToString(duration: TimeInterval) -> String {
        let time = Int(round(Double(duration)))
        if time < 10 {
            return String.init(format: "00:0%d", arguments: [time])
        }else if time < 60 {
            return String.init(format: "00:%d", arguments: [time])
        }else {
            let min = Int(time / 60)
            let sec = time - (min * 60)
            if sec < 10 {
                return String.init(format: "%d:0%d", arguments: [min,sec])
            }else {
                return String.init(format: "%d:%d", arguments: [min,sec])
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
        let second = Int(urlAsset.duration.value) / Int(urlAsset.duration.timescale)
        return TimeInterval(second)
    }
    
    /// 导出编辑视频
    /// - Parameters:
    ///   - avAsset: 视频对应的 AVAsset 数据
    ///   - startTime: 需要裁剪的开始时间
    ///   - endTime: 需要裁剪的结束时间
    ///   - presentName: 导出的质量
    ///   - completion: 导出完成
    public class func exportEditVideo(for avAsset: AVAsset, startTime: TimeInterval, endTime: TimeInterval, presentName: String, completion:@escaping (URL?, Error?) -> Void) {
        let timescale = avAsset.duration.timescale
        let start = CMTime(value: CMTimeValue(startTime * TimeInterval(timescale)), timescale: timescale)
        let end = CMTime(value: CMTimeValue(endTime * TimeInterval(timescale)), timescale: timescale)
        let timeRang = CMTimeRange(start: start, end: end)
        exportEditVideo(for: avAsset, timeRang: timeRang, presentName: presentName, completion: completion)
    }
    
    /// 导出编辑视频
    /// - Parameters:
    ///   - avAsset: 视频对应的 AVAsset 数据
    ///   - timeRang: 需要裁剪的时间区域
    ///   - presentName: 导出的质量
    ///   - completion: 导出完成
    public class func exportEditVideo(for avAsset: AVAsset, timeRang: CMTimeRange, presentName: String, completion:@escaping (URL?, Error?) -> Void) {
        if AVAssetExportSession.allExportPresets().contains(presentName) {
            let videoURL = PhotoTools.getVideoTmpURL()
            if let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: presentName) {
                let supportedTypeArray = exportSession.supportedFileTypes
                exportSession.outputURL = videoURL
                if supportedTypeArray.contains(AVFileType.mp4) {
                    exportSession.outputFileType = .mp4
                }else if supportedTypeArray.isEmpty {
                    completion(nil, PhotoError.error(message: "不支持导出该类型视频"))
                    return
                }else {
                    exportSession.outputFileType = supportedTypeArray.first
                }
                exportSession.timeRange = timeRang
                exportSession.exportAsynchronously(completionHandler: {
                    DispatchQueue.main.async {
                        switch exportSession.status {
                        case .completed:
                            completion(videoURL, nil)
                            break
                        case .failed, .cancelled:
                            completion(nil, exportSession.error)
                            break
                        default: break
                        }
                    }
                })
            }else {
                completion(nil, PhotoError.error(message: "不支持导出该类型视频"))
                return
            }
        }else {
            completion(nil, PhotoError.error(message: "设备不支持导出：" + presentName))
            return
        }
    }
    
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
}

enum PhotoToolsTransformImageSizeDirections {
    case horizontal
    case vertical
}
