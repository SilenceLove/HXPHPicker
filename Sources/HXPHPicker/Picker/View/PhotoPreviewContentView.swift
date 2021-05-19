//
//  PhotoPreviewContentView.swift
//  HXPHPickerExample
//
//  Created by Slience on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import PhotosUI

enum PhotoPreviewContentViewType: Int {
    case photo
    case livePhoto
    case video
}
class PhotoPreviewContentView: UIView, PHLivePhotoViewDelegate {
    
    lazy var imageView: GIFImageView = {
        let imageView = GIFImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    @available(iOS 9.1, *)
    lazy var livePhotoView: PHLivePhotoView = {
        let livePhotoView = PHLivePhotoView.init()
        livePhotoView.delegate = self
        return livePhotoView
    }()
    lazy var videoView: PhotoPreviewVideoView = {
        let videoView = PhotoPreviewVideoView.init()
        videoView.alpha = 0
        return videoView
    }()
    
    var isBacking: Bool = false
    
    var type: PhotoPreviewContentViewType = .photo
    var requestID: PHImageRequestID?
    var requestCompletion: Bool = false
    var videoPlayType: PhotoPreviewViewController.VideoPlayType = .normal  {
        didSet {
            if type == .video {
                videoView.videoPlayType = videoPlayType
            }
        }
    }
    var currentLoadAssetLocalIdentifier: String?
    var photoAsset: PhotoAsset! {
        didSet {
            if type == .livePhoto {
                if #available(iOS 9.1, *) {
                    livePhotoView.livePhoto = nil
                }
            }
            if photoAsset.mediaSubType == .localImage {
                requestCompletion = true
            }
            requestID = photoAsset.requestThumbnailImage(targetWidth: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), completion: { [weak self] (image, asset, info) in
                if asset == self?.photoAsset && image != nil {
                    self?.imageView.image = image
                }
            })
        }
    }
    var loadingView: ProgressHUD?
    
    init(type: PhotoPreviewContentViewType) {
        super.init(frame: CGRect.zero)
        self.type = type
        addSubview(imageView)
        if type == .livePhoto {
            if #available(iOS 9.1, *) {
                addSubview(livePhotoView)
            }
        }else if type == .video {
            addSubview(videoView)
        }
    }
    
    func requestPreviewAsset() {
        if requestCompletion {
            return
        }
        if photoAsset.mediaSubType == .localImage {
            return
        }
        var canRequest = true
        if let localIdentifier = currentLoadAssetLocalIdentifier, localIdentifier == photoAsset.phAsset?.localIdentifier {
            canRequest = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if loadingView == nil {
                loadingView = ProgressHUD.showLoading(addedTo: self, text: "正在下载".localized + "(" + String(Int(photoAsset.downloadProgress * 100)) + "%)", animated: true)
            }
        }else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if requestID != nil {
                PHImageManager.default().cancelImageRequest(requestID!)
                requestID = nil
            }
        }
        if type == .photo {
            if photoAsset.mediaSubType == .imageAnimated &&
                imageView.gifImage != nil {
                imageView.startAnimating()
            }else {
                if canRequest {
                    requestOriginalImage()
                }
            }
        }else if type == .livePhoto {
            if #available(iOS 9.1, *) {
                if canRequest {
                    requestLivePhoto()
                }
            }
        }else if type == PhotoPreviewContentViewType.video {
            if videoView.player.currentItem == nil && canRequest {
                requestAVAsset()
            }
        }
    }
    
    func requestOriginalImage() {
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoAsset.photoEdit {
            imageView.setImage(photoEdit.editedImage, animated: true)
            requestCompletion = true
            return
        }
        #endif
        requestID = photoAsset.requestImageData(iCloudHandler: { [weak self] (asset, iCloudRequestID) in
            if asset == self?.photoAsset {
                self?.requestShowDonwloadICloudHUD(iCloudRequestID: iCloudRequestID)
            }
        }, progressHandler: { [weak self] (asset, progress) in
            if asset == self?.photoAsset {
                self?.requestUpdateProgress(progress: progress)
            }
        }, success: { [weak self] (asset, imageData, imageOrientation, info) in
            if asset.mediaSubType == .imageAnimated {
                if asset == self?.photoAsset {
                    self?.requestSucceed()
                    let image = GIFImage.init(data: imageData)
                    self?.imageView.gifImage = image
                    self?.requestID = nil
                    self?.requestCompletion = true
                }
            }else {
                DispatchQueue.global().async {
                    var image = UIImage.init(data: imageData)
                    image = image?.scaleSuitableSize()
                    DispatchQueue.main.async {
                        if asset == self?.photoAsset {
                            self?.requestSucceed()
                            self?.imageView.setImage(image, animated: true)
                            self?.requestID = nil
                            self?.requestCompletion = true
                        }
                    }
                }
            }
        }, failure: { [weak self] (asset, info) in
            if asset == self?.photoAsset {
                self?.requestFailed(info: info)
            }
        })
    }
    @available(iOS 9.1, *)
    func requestLivePhoto() {
        #if HXPICKER_ENABLE_EDITOR
        if let photoEdit = photoAsset.photoEdit {
            imageView.setImage(photoEdit.editedImage, animated: true)
            requestCompletion = true
            return
        }
        #endif
        let targetSize : CGSize = size
        requestID = photoAsset.requestLivePhoto(targetSize: targetSize, iCloudHandler: { [weak self] (asset, requestID) in
            if asset == self?.photoAsset {
                self?.requestShowDonwloadICloudHUD(iCloudRequestID: requestID)
            }
        }, progressHandler: {  [weak self](asset, progress) in
            if asset == self?.photoAsset {
                self?.requestUpdateProgress(progress: progress)
            }
        }, success: { [weak self] (asset, livePhoto, info) in
            if asset == self?.photoAsset {
                self?.requestSucceed()
                self?.livePhotoView.livePhoto = livePhoto
                UIView.animate(withDuration: 0.25) {
                    self?.livePhotoView.alpha = 1
                }
                self?.livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
                self?.requestID = nil
                self?.requestCompletion = true
            }
        }, failure: { [weak self] (asset, info) in
            if asset == self?.photoAsset {
                self?.requestFailed(info: info)
            }
        })
    }
    func requestAVAsset() {
        requestID = photoAsset.requestAVAsset(iCloudHandler: { [weak self] (asset, requestID) in
            if asset == self?.photoAsset {
                self?.requestShowDonwloadICloudHUD(iCloudRequestID: requestID)
            }
        }, progressHandler: { [weak self] (asset, progress) in
            if asset == self?.photoAsset {
                self?.requestUpdateProgress(progress: progress)
            }
        }, success: { [weak self] (asset, avAsset, info) in
            if asset == self?.photoAsset {
                self?.requestSucceed()
                if self?.isBacking ?? true {
                    return
                }
                self?.videoView.avAsset = avAsset
                UIView.animate(withDuration: 0.25) {
                    self?.videoView.alpha = 1
                }
                self?.requestID = nil
                self?.requestCompletion = true
            }
        }, failure: { [weak self] (asset, info) in
            if asset == self?.photoAsset {
                self?.requestFailed(info: info)
            }
        })
    }
    func requestShowDonwloadICloudHUD(iCloudRequestID: PHImageRequestID) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestID = iCloudRequestID
        currentLoadAssetLocalIdentifier = photoAsset.phAsset?.localIdentifier
        loadingView = ProgressHUD.showLoading(addedTo: self, text: "正在下载".localized, animated: true)
    }
    func requestUpdateProgress(progress: Double) {
        loadingView?.updateText(text: "正在下载".localized + "(" + String(Int(progress * 100)) + "%)")
    }
    func requestSucceed() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        currentLoadAssetLocalIdentifier = nil
        loadingView = nil
        ProgressHUD.hide(forView: self, animated: true)
    }
    func requestFailed(info: [AnyHashable : Any]?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        loadingView?.removeFromSuperview()
        loadingView = nil
        currentLoadAssetLocalIdentifier = nil
        if !AssetManager.assetCancelDownload(for: info) {
            ProgressHUD.hide(forView: self, animated: true)
            ProgressHUD.showWarning(addedTo: self, text: "下载失败".localized, animated: true, delayHide: 2)
        }
    }
    func cancelRequest() {
        if photoAsset.mediaSubType == .localImage {
            requestCompletion = false
            return
        }
        currentLoadAssetLocalIdentifier = nil
        if requestID != nil {
            PHImageManager.default().cancelImageRequest(requestID!)
            requestID = nil
        }
        stopAnimatedImage()
        ProgressHUD.hide(forView: self, animated: false)
        if type == .livePhoto {
            if #available(iOS 9.1, *) {
                livePhotoView.stopPlayback()
                livePhotoView.alpha = 0
            }
        }else if type == .video {
            videoView.cancelPlayer()
            videoView.alpha = 0
        }
        requestCompletion = false
    }
    func stopVideo() {
        if photoAsset.mediaType == .video {
            videoView.stopPlay()
        }
    }
    func showOtherSubview() {
        if photoAsset.mediaType == .video {
            videoView.showPlayButton()
        }
    }
    func hiddenOtherSubview() {
        if photoAsset.mediaType == .video {
            videoView.hiddenPlayButton()
        }
        loadingView = nil
        ProgressHUD.hide(forView: self, animated: false)
    }
    func startAnimatedImage() {
        if photoAsset.mediaSubType == .imageAnimated {
            imageView.setupDisplayLink()
        }
    }
    func stopAnimatedImage() {
        if photoAsset.mediaSubType == .imageAnimated {
            imageView.displayLink?.invalidate()
            imageView.gifImage = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        if type == PhotoPreviewContentViewType.livePhoto {
            if #available(iOS 9.1, *) {
                livePhotoView.frame = bounds
            }
        }else if type == PhotoPreviewContentViewType.video {
            videoView.frame = bounds
        }
    }
    deinit {
        cancelRequest()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
