//
//  PhotoPickerViewController+Camera.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/4.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos

// MARK: UIImagePickerControllerDelegate
extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentCameraViewController() {
        guard let pickerController = pickerController,
              pickerController.shouldPresentCamera() else {
            return
        }
        let imagePickerController = CameraViewController.init()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.videoMaximumDuration = config.camera.videoMaximumDuration
        imagePickerController.videoQuality = config.camera.videoQuality
        imagePickerController.allowsEditing = config.camera.allowsEditing
        imagePickerController.cameraDevice = config.camera.cameraDevice
        var mediaTypes: [String] = []
        if !config.camera.mediaTypes.isEmpty {
            mediaTypes = config.camera.mediaTypes
        }else {
            if pickerController.config.selectOptions.isPhoto {
                mediaTypes.append(kUTTypeImage as String)
            }
            if pickerController.config.selectOptions.isVideo {
                mediaTypes.append(kUTTypeMovie as String)
            }
        }
        imagePickerController.mediaTypes = mediaTypes
        present(imagePickerController, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ProgressHUD.showLoading(addedTo: self.navigationController?.view, animated: true)
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.global().async {
            let mediaType = info[.mediaType] as! String
            var photoAsset: PhotoAsset
            if mediaType == kUTTypeImage as String {
                var image: UIImage? = (info[.editedImage] ?? info[.originalImage]) as? UIImage
                image = image?.scaleSuitableSize()
                if let image = image {
                    if self.config.saveSystemAlbum {
                        self.saveSystemAlbum(for: image, mediaType: .image)
                        return
                    }
                    photoAsset = PhotoAsset.init(localImageAsset: .init(image: image))
                }else {
                    return
                }
            }else {
                let startTime = info[UIImagePickerController.InfoKey.init(rawValue: "_UIImagePickerControllerVideoEditingStart")] as? TimeInterval
                let endTime = info[UIImagePickerController.InfoKey.init(rawValue: "_UIImagePickerControllerVideoEditingEnd")] as? TimeInterval
                let videoURL: URL? = info[.mediaURL] as? URL
                if let startTime = startTime, let endTime = endTime, let videoURL = videoURL  {
                    let avAsset = AVAsset.init(url: videoURL)
                    PhotoTools.exportEditVideo(
                        for: avAsset,
                        startTime: startTime,
                        endTime: endTime,
                        exportPreset: self.config.camera.editExportPreset,
                        videoQuality: self.config.camera.editVideoQuality)
                    { (url, error) in
                        if let url = url, error == nil {
                            if self.config.saveSystemAlbum {
                                self.saveSystemAlbum(for: url, mediaType: .video)
                                return
                            }
                            let phAsset: PhotoAsset = PhotoAsset.init(localVideoAsset: .init(videoURL: url))
                            self.addedCameraPhotoAsset(phAsset)
                        }else {
                            ProgressHUD.hide(forView: self.navigationController?.view, animated: false)
                            ProgressHUD.showWarning(addedTo: self.navigationController?.view, text: "视频导出失败".localized, animated: true, delayHide: 1.5)
                        }
                    }
                    return
                }else {
                    if let videoURL = videoURL {
                        if self.config.saveSystemAlbum {
                            self.saveSystemAlbum(for: videoURL, mediaType: .video)
                            return
                        }
                        photoAsset = PhotoAsset.init(localVideoAsset: .init(videoURL: videoURL))
                    }else {
                        return
                    }
                }
            }
            self.addedCameraPhotoAsset(photoAsset)
        }
    }
    func saveSystemAlbum(for asset: Any, mediaType: PHAssetMediaType) {
        AssetManager.saveSystemAlbum(forAsset: asset, mediaType: mediaType, customAlbumName: config.customAlbumName, creationDate: nil, location: nil) { (phAsset) in
            if let phAsset = phAsset {
                self.addedCameraPhotoAsset(PhotoAsset.init(asset: phAsset))
            }else {
                DispatchQueue.main.async {
                    ProgressHUD.hide(forView: self.navigationController?.view, animated: true)
                    ProgressHUD.showWarning(addedTo: self.navigationController?.view, text: "保存失败".localized, animated: true, delayHide: 1.5)
                }
            }
        }
    }
    func addedCameraPhotoAsset(_ photoAsset: PhotoAsset) {
        func addPhotoAsset(_ photoAsset: PhotoAsset) {
            ProgressHUD.hide(forView: self.navigationController?.view, animated: true)
            if self.config.takePictureCompletionToSelected {
                if self.pickerController!.addedPhotoAsset(photoAsset: photoAsset) {
                    self.updateCellSelectedTitle()
                }
            }
            self.pickerController?.updateAlbums(coverImage: photoAsset.originalImage, count: 1)
            if photoAsset.isLocalAsset {
                self.pickerController?.addedLocalCameraAsset(photoAsset: photoAsset)
            }
            if self.pickerController!.config.albumShowMode == .popup {
                self.albumView.tableView.reloadData()
            }
            self.addedPhotoAsset(for: photoAsset)
            self.bottomView.updateFinishButtonTitle()
            self.setupEmptyView()
        }
        if DispatchQueue.isMain {
            addPhotoAsset(photoAsset)
        }else {
            DispatchQueue.main.async {
                addPhotoAsset(photoAsset)
            }
        }
    }
}
