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
            weak var weakSelf = self
            
            requestID = photoAsset.requestThumbnailImage(targetWidth: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), completion: { (image, asset, info) in
                if asset == weakSelf?.photoAsset && image != nil {
                    weakSelf?.imageView.image = image
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
                loadingView = ProgressHUD.showLoadingHUD(addedTo: self, text: "正在下载".localized + "(" + String(Int(photoAsset.downloadProgress * 100)) + "%)", animated: true)
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
        weak var weakSelf = self
        requestID = photoAsset.requestImageData(iCloudHandler: { (asset, iCloudRequestID) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestShowDonwloadICloudHUD(iCloudRequestID: iCloudRequestID)
            }
        }, progressHandler: { (asset, progress) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestUpdateProgress(progress: progress)
            }
        }, success: { (asset, imageData, imageOrientation, info) in
            if asset.mediaSubType == .imageAnimated {
                if asset == weakSelf?.photoAsset {
                    weakSelf?.requestSucceed()
                    let image = HXPHGIFImage.init(data: imageData)
                    weakSelf?.imageView.gifImage = image
                    weakSelf?.requestID = nil
                    weakSelf?.requestCompletion = true
                }
            }else {
                DispatchQueue.global().async {
                    var image = UIImage.init(data: imageData)
                    image = image?.scaleSuitableSize()
                    DispatchQueue.main.async {
                        if asset == weakSelf?.photoAsset {
                            weakSelf?.requestSucceed()
                            weakSelf?.imageView.setImage(image, animated: true)
                            weakSelf?.requestID = nil
                            weakSelf?.requestCompletion = true
                        }
                    }
                }
            }
        }, failure: { (asset, info) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestFailed(info: info)
            }
        })
    }
    @available(iOS 9.1, *)
    func requestLivePhoto() {
        let targetSize : CGSize = size
        weak var weakSelf = self
        requestID = photoAsset.requestLivePhoto(targetSize: targetSize, iCloudHandler: { (asset, requestID) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestShowDonwloadICloudHUD(iCloudRequestID: requestID)
            }
        }, progressHandler: { (asset, progress) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestUpdateProgress(progress: progress)
            }
        }, success: { (asset, livePhoto, info) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestSucceed()
                weakSelf?.livePhotoView.livePhoto = livePhoto
                UIView.animate(withDuration: 0.25) {
                    weakSelf?.livePhotoView.alpha = 1
                }
                weakSelf?.livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
                weakSelf?.requestID = nil
                weakSelf?.requestCompletion = true
            }
        }, failure: { (asset, info) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestFailed(info: info)
            }
        })
    }
    func requestAVAsset() {
        weak var weakSelf = self
        requestID = photoAsset.requestAVAsset(iCloudHandler: { (asset, requestID) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestShowDonwloadICloudHUD(iCloudRequestID: requestID)
            }
        }, progressHandler: { (asset, progress) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestUpdateProgress(progress: progress)
            }
        }, success: { (asset, avAsset, info) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestSucceed()
                if weakSelf?.isBacking ?? true {
                    return
                }
                weakSelf?.videoView.avAsset = avAsset
                UIView.animate(withDuration: 0.25) {
                    weakSelf?.videoView.alpha = 1
                }
                weakSelf?.requestID = nil
                weakSelf?.requestCompletion = true
            }
        }, failure: { (asset, info) in
            if asset == weakSelf?.photoAsset {
                weakSelf?.requestFailed(info: info)
            }
        })
    }
    func requestShowDonwloadICloudHUD(iCloudRequestID: PHImageRequestID) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestID = iCloudRequestID
        currentLoadAssetLocalIdentifier = photoAsset.phAsset?.localIdentifier
        loadingView = ProgressHUD.showLoadingHUD(addedTo: self, text: "正在下载".localized, animated: true)
    }
    func requestUpdateProgress(progress: Double) {
        loadingView?.updateText(text: "正在下载".localized + "(" + String(Int(progress * 100)) + "%)")
    }
    func requestSucceed() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        currentLoadAssetLocalIdentifier = nil
        loadingView = nil
        ProgressHUD.hideHUD(forView: self, animated: true)
    }
    func requestFailed(info: [AnyHashable : Any]?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        loadingView?.removeFromSuperview()
        loadingView = nil
        currentLoadAssetLocalIdentifier = nil
        if !AssetManager.assetCancelDownload(for: info) {
            ProgressHUD.hideHUD(forView: self, animated: true)
            ProgressHUD.showWarningHUD(addedTo: self, text: "下载失败".localized, animated: true, delay: 2)
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
        ProgressHUD.hideHUD(forView: self, animated: false)
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
        ProgressHUD.hideHUD(forView: self, animated: false)
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
