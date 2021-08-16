//
//  Picker+PhotoTools.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/7.
//

import UIKit
import Photos

extension PhotoTools {
    
    /// 显示没有权限的弹窗
    /// - Parameters:
    ///   - viewController: 需要弹窗的viewController
    ///   - status: 权限类型
    public class func showNotAuthorizedAlert(viewController : UIViewController? ,
                                             status : PHAuthorizationStatus) {
        guard let vc = viewController else { return }
        if status == .denied ||
            status == .restricted {
            showAlert(viewController: vc, title: "无法访问相册中照片".localized, message: "当前无照片访问权限，建议前往系统设置，\n允许访问「照片」中的「所有照片」。".localized, leftActionTitle: "取消".localized, leftHandler: {_ in }, rightActionTitle: "前往系统设置".localized) { (alertAction) in
                openSettingsURL()
            }
        }
    }
    
    /// 显示没有相机权限弹窗
    public class func showNotCameraAuthorizedAlert(viewController : UIViewController?) {
        guard let vc = viewController else { return }
        showAlert(viewController: vc, title: "无法使用相机功能".localized, message: "请前往系统设置中，允许访问「相机」。".localized, leftActionTitle: "取消".localized, leftHandler: {_ in }, rightActionTitle: "前往系统设置".localized) { (alertAction) in
            openSettingsURL()
        }
    }
    
    /// 转换相册名称为当前语言
    public class func transformAlbumName(for collection: PHAssetCollection) -> String? {
        if collection.assetCollectionType == .album {
            return collection.localizedTitle
        }
        var albumName : String?
        let type = PhotoManager.shared.languageType
        if type == .system {
            albumName = collection.localizedTitle
        }else {
            if collection.localizedTitle == "最近项目" ||
                collection.localizedTitle == "最近添加"  {
                albumName = "HXAlbumRecents".localized
            }else if collection.localizedTitle == "Camera Roll" ||
                        collection.localizedTitle == "相机胶卷" {
                albumName = "HXAlbumCameraRoll".localized
            }else {
                switch collection.assetCollectionSubtype {
                case .smartAlbumUserLibrary:
                    albumName = "HXAlbumCameraRoll".localized
                    break
                case .smartAlbumVideos:
                    albumName = "HXAlbumVideos".localized
                    break
                case .smartAlbumPanoramas:
                    albumName = "HXAlbumPanoramas".localized
                    break
                case .smartAlbumFavorites:
                    albumName = "HXAlbumFavorites".localized
                    break
                case .smartAlbumTimelapses:
                    albumName = "HXAlbumTimelapses".localized
                    break
                case .smartAlbumRecentlyAdded:
                    albumName = "HXAlbumRecentlyAdded".localized
                    break
                case .smartAlbumBursts:
                    albumName = "HXAlbumBursts".localized
                    break
                case .smartAlbumSlomoVideos:
                    albumName = "HXAlbumSlomoVideos".localized
                    break
                case .smartAlbumSelfPortraits:
                    albumName = "HXAlbumSelfPortraits".localized
                    break
                case .smartAlbumScreenshots:
                    albumName = "HXAlbumScreenshots".localized
                    break
                case .smartAlbumDepthEffect:
                    albumName = "HXAlbumDepthEffect".localized
                    break
                case .smartAlbumLivePhotos:
                    albumName = "HXAlbumLivePhotos".localized
                    break
                case .smartAlbumAnimated:
                    albumName = "HXAlbumAnimated".localized
                    break
                default:
                    albumName = collection.localizedTitle
                    break
                }
            }
        }
        return albumName
    }
    class func cameraPreviewImageURL() -> URL {
        var cachePath = getImageCacheFolderPath()
        cachePath.append(contentsOf: "/" + "cameraPreviewImage".md5)
        return URL(fileURLWithPath: cachePath)
    }
    class func isCacheCameraPreviewImage() -> Bool {
        let imageCacheURL = cameraPreviewImageURL()
        return FileManager.default.fileExists(atPath: imageCacheURL.path)
    }
    class func saveCameraPreviewImage(_ image: UIImage) {
        if let data = getImageData(for: image),
           !data.isEmpty {
            do {
                let cachePath = getImageCacheFolderPath()
                let fileManager = FileManager.default
                if !fileManager.fileExists(atPath: cachePath) {
                    try fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
                }
                let imageCacheURL = cameraPreviewImageURL()
                if fileManager.fileExists(atPath: imageCacheURL.path) {
                    try fileManager.removeItem(at: imageCacheURL)
                }
                try data.write(to: cameraPreviewImageURL())
            } catch {
                print("saveError:\n", error)
            }
        }
    }
    class func getCameraPreviewImage() -> UIImage? {
        do {
            let cacheURL = cameraPreviewImageURL()
            if !FileManager.default.fileExists(atPath: cacheURL.path) {
                return nil
            }
            let data = try Data(contentsOf: cacheURL)
            return UIImage(data: data)
        } catch {
            print("getError:\n", error)
        }
        return nil
    }
    public class func getVideoCoverImage(for photoAsset: PhotoAsset, completionHandler: @escaping (PhotoAsset, UIImage) -> Void) {
        if photoAsset.mediaType == .video {
            var url: URL?
            if let videoAsset = photoAsset.localVideoAsset,
               photoAsset.isLocalAsset {
                if let coverImage = videoAsset.image {
                    completionHandler(photoAsset, coverImage)
                    return
                }
                url = videoAsset.videoURL
            }else if let videoAsset = photoAsset.networkVideoAsset,
                     photoAsset.isNetworkAsset {
                if let coverImage = videoAsset.coverImage {
                    completionHandler(photoAsset, coverImage)
                    return
                }
                let key = videoAsset.videoURL.absoluteString
                if isCached(forVideo: key) {
                    url = getVideoCacheURL(for: key)
                }else {
                    url = videoAsset.videoURL
                }
            }
            if let url = url {
                getVideoThumbnailImage(url: url, atTime: 0.1) { (videoURL, coverImage) in
                    if photoAsset.isNetworkAsset {
                        photoAsset.networkVideoAsset?.coverImage = coverImage
                    }else {
                        photoAsset.localVideoAsset?.image = coverImage
                    }
                    completionHandler(photoAsset, coverImage)
                }
            }
        }
    }
    
    public class func getVideoDuration(for photoAsset: PhotoAsset, completionHandler: @escaping (PhotoAsset, TimeInterval) -> Void) {
        if photoAsset.mediaType == .video {
            var url: URL?
            if let videoAsset = photoAsset.localVideoAsset,
               photoAsset.isLocalAsset {
                if videoAsset.duration > 0 {
                    completionHandler(photoAsset, videoAsset.duration)
                    return
                }
                url = videoAsset.videoURL
            }else if let videoAsset = photoAsset.networkVideoAsset,
                     photoAsset.mediaSubType.isNetwork {
                if videoAsset.duration > 0 {
                    completionHandler(photoAsset, videoAsset.duration)
                    return
                }
                let key = videoAsset.videoURL.absoluteString
                if isCached(forVideo: key) {
                    url = getVideoCacheURL(for: key)
                }else {
                    url = videoAsset.videoURL
                }
            }
            if let url = url {
                let avAsset = AVAsset.init(url: url)
                avAsset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    let duration = avAsset.duration.seconds
                    if photoAsset.isNetworkAsset {
                        photoAsset.networkVideoAsset?.duration = duration
                    }else {
                        photoAsset.localVideoAsset?.duration = duration
                    }
                    photoAsset.updateVideoDuration(duration)
                    DispatchQueue.main.async {
                        completionHandler(photoAsset, duration)
                    }
                }
            }
        }
    }
    
    /// 将字节转换成字符串
    public class func transformBytesToString(bytes: Int) -> String {
        if CGFloat(bytes) >= 0.5 * 1000 * 1000 {
            return String.init(format: "%0.1fM", arguments: [CGFloat(bytes) / 1000 / 1000])
        }else if bytes >= 1000 {
            return String.init(format: "%0.0fK", arguments: [CGFloat(bytes) / 1000])
        }else {
            return String.init(format: "%dB", arguments: [bytes])
        }
    }
    
    /// 获取和微信主题一致的配置
    public class func getWXPickerConfig(isMoment: Bool = false) -> PickerConfiguration {
        let config = PickerConfiguration.init()
        if isMoment {
            config.maximumSelectedCount = 9
            config.maximumSelectedVideoCount = 1
            config.videoSelectionTapAction = .openEditor
            config.allowSelectedTogether = false
            config.maximumSelectedVideoDuration = 15
        }else {
            config.maximumSelectedVideoDuration = 480
            config.maximumSelectedCount = 9
            config.maximumSelectedVideoCount = 0
            config.allowSelectedTogether = true
        }
        let wxColor = "#07C160".color
        config.selectOptions = [.gifPhoto, .video]
        config.albumShowMode = .popup
        config.appearanceStyle = .normal
        config.navigationViewBackgroundColor = "#2E2F30".color
        config.navigationTitleColor = .white
        config.navigationTintColor = .white
        config.statusBarStyle = .lightContent
        config.navigationBarStyle = .black
        
        config.albumList.backgroundColor = "#2E2F30".color
        config.albumList.cellHeight = 60
        config.albumList.cellBackgroundColor = "#2E2F30".color
        config.albumList.cellSelectedColor = UIColor.init(red: 0.125, green: 0.125, blue: 0.125, alpha: 1)
        config.albumList.albumNameColor = .white
        config.albumList.photoCountColor = .white
        config.albumList.separatorLineColor = "#434344".color.withAlphaComponent(0.6)
        config.albumList.tickColor = wxColor
        
        config.photoList.backgroundColor = "#2E2F30".color
        config.photoList.cancelPosition = .left
        config.photoList.cancelType = .image
        
        config.photoList.titleView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        config.photoList.titleView.arrowBackgroundColor = "#B2B2B2".color
        config.photoList.titleView.arrowColor = "#2E2F30".color
        
        config.photoList.cell.targetWidth = 250
        config.photoList.cell.selectBox.selectedBackgroundColor = wxColor
        config.photoList.cell.selectBox.titleColor = .white
        
        config.photoList.cameraCell.cameraImageName = "hx_picker_photoList_photograph_white"
        
        config.photoList.bottomView.barStyle = .black
        config.photoList.bottomView.previewButtonTitleColor = .white
        
        config.photoList.bottomView.originalButtonTitleColor = .white
        config.photoList.bottomView.originalSelectBox.backgroundColor = .clear
        config.photoList.bottomView.originalSelectBox.borderColor = .white
        config.photoList.bottomView.originalSelectBox.tickColor = .white
        config.photoList.bottomView.originalSelectBox.selectedBackgroundColor = wxColor
        config.photoList.bottomView.originalLoadingStyle = .white
        
        config.photoList.bottomView.finishButtonTitleColor = .white
        config.photoList.bottomView.finishButtonBackgroundColor = wxColor
        config.photoList.bottomView.finishButtonDisableBackgroundColor = "#666666".color.withAlphaComponent(0.3)
        
        config.photoList.bottomView.promptTitleColor = UIColor.white.withAlphaComponent(0.6)
        config.photoList.bottomView.promptIconColor = "#f5a623".color
        config.photoList.bottomView.promptArrowColor = UIColor.white.withAlphaComponent(0.6)
        
        config.photoList.emptyView.titleColor = "#ffffff".color
        config.photoList.emptyView.subTitleColor = .lightGray
        
        config.previewView.cancelType = .image
        config.previewView.cancelPosition = .left
        config.previewView.backgroundColor = .black
        config.previewView.selectBox.tickColor = .white
        config.previewView.selectBox.selectedBackgroundColor = wxColor
        
        config.previewView.bottomView.barStyle = .black
        
        config.previewView.bottomView.originalButtonTitleColor = .white
        config.previewView.bottomView.originalSelectBox.backgroundColor = .clear
        config.previewView.bottomView.originalSelectBox.borderColor = .white
        config.previewView.bottomView.originalSelectBox.tickColor = .white
        config.previewView.bottomView.originalSelectBox.selectedBackgroundColor = wxColor
        config.previewView.bottomView.originalLoadingStyle = .white
        
        config.previewView.bottomView.finishButtonTitleColor = .white
        config.previewView.bottomView.finishButtonBackgroundColor = wxColor
        config.previewView.bottomView.finishButtonDisableBackgroundColor = "#666666".color.withAlphaComponent(0.3)
        
        config.previewView.bottomView.selectedViewTickColor = wxColor
        
        
        #if HXPICKER_ENABLE_EDITOR
        config.previewView.bottomView.editButtonTitleColor = .white
        config.videoEditor.cropping.maximumVideoCroppingTime = 15
        config.videoEditor.cropView.finishButtonBackgroundColor = wxColor
        config.videoEditor.cropView.finishButtonDarkBackgroundColor = wxColor
        config.videoEditor.toolView.finishButtonBackgroundColor = wxColor
        config.videoEditor.toolView.finishButtonDarkBackgroundColor = wxColor
        config.videoEditor.toolView.toolSelectedColor = wxColor
        config.videoEditor.toolView.musicSelectedColor = wxColor
        config.videoEditor.music.tintColor = wxColor
        config.videoEditor.text.tintColor = wxColor
        
        config.photoEditor.toolView.toolSelectedColor = wxColor
        config.photoEditor.toolView.finishButtonBackgroundColor = wxColor
        config.photoEditor.toolView.finishButtonDarkBackgroundColor = wxColor
        config.photoEditor.cropConfimView.finishButtonBackgroundColor = wxColor
        config.photoEditor.cropConfimView.finishButtonDarkBackgroundColor = wxColor
        config.photoEditor.cropping.aspectRatioSelectedColor = wxColor
        config.photoEditor.filter = .init(infos: defaultFilters(),
                                                selectedColor: wxColor)
        config.photoEditor.text.tintColor = wxColor
        #endif
        
        config.notAuthorized.closeButtonImageName = "hx_picker_notAuthorized_close_dark"
        config.notAuthorized.backgroundColor = "#2E2F30".color
        config.notAuthorized.titleColor = .white
        config.notAuthorized.subTitleColor = .white
        config.notAuthorized.jumpButtonTitleColor = .white
        config.notAuthorized.jumpButtonBackgroundColor = wxColor
        
        return config
    }
}
