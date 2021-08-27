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
    
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        ProgressHUD.showLoading(
            addedTo: self.navigationController?.view,
            animated: true
        )
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.global().async {
            let mediaType = info[.mediaType] as! String
            if mediaType == kUTTypeImage as String {
                self.pickingImage(info: info)
            }else {
                self.pickingVideo(info: info)
            }
        }
    }
    func pickingImage(info: [UIImagePickerController.InfoKey: Any]) {
        var image: UIImage? = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        image = image?.scaleSuitableSize()
        if let image = image {
            if config.saveSystemAlbum {
                saveSystemAlbum(for: image, mediaType: .image)
                return
            }
            addedCameraPhotoAsset(PhotoAsset(
                localImageAsset: .init(image: image)
            ))
            return
        }
        DispatchQueue.main.async {
            ProgressHUD.hide(
                forView: self.navigationController?.view,
                animated: false
            )
        }
    }
    func pickingVideo(info: [UIImagePickerController.InfoKey: Any]) {
        let startTime = info[
            UIImagePickerController.InfoKey(
                rawValue: "_UIImagePickerControllerVideoEditingStart"
            )
        ] as? TimeInterval
        let endTime = info[
            UIImagePickerController.InfoKey(
                rawValue: "_UIImagePickerControllerVideoEditingEnd"
            )
        ] as? TimeInterval
        let videoURL: URL? = info[.mediaURL] as? URL
        guard let videoURL = videoURL else {
            DispatchQueue.main.async {
                ProgressHUD.hide(
                    forView: self.navigationController?.view,
                    animated: false
                )
            }
            return
        }
        guard let startTime = startTime,
              let endTime = endTime  else {
            if config.saveSystemAlbum {
                saveSystemAlbum(for: videoURL, mediaType: .video)
                return
            }
            addedCameraPhotoAsset(
                PhotoAsset(
                    localVideoAsset: .init(videoURL: videoURL)
                )
            )
            return
        }
        let avAsset = AVAsset.init(url: videoURL)
        PhotoTools.exportEditVideo(
            for: avAsset,
            startTime: startTime,
            endTime: endTime,
            exportPreset: config.camera.editExportPreset,
            videoQuality: config.camera.editVideoQuality
        ) { (url, error) in
            guard let url = url, error == nil else {
                ProgressHUD.hide(forView: self.navigationController?.view, animated: false)
                ProgressHUD.showWarning(
                    addedTo: self.navigationController?.view,
                    text: "视频导出失败".localized,
                    animated: true,
                    delayHide: 1.5
                )
                return
            }
            if self.config.saveSystemAlbum {
                self.saveSystemAlbum(for: url, mediaType: .video)
                return
            }
            let phAsset: PhotoAsset = PhotoAsset.init(localVideoAsset: .init(videoURL: url))
            self.addedCameraPhotoAsset(phAsset)
        }
    }
    func saveSystemAlbum(for asset: Any, mediaType: PHAssetMediaType) {
        AssetManager.saveSystemAlbum(
            forAsset: asset,
            mediaType: mediaType,
            customAlbumName: config.customAlbumName,
            creationDate: nil,
            location: nil
        ) { (phAsset) in
            if let phAsset = phAsset {
                self.addedCameraPhotoAsset(PhotoAsset.init(asset: phAsset))
            }else {
                DispatchQueue.main.async {
                    ProgressHUD.hide(
                        forView: self.navigationController?.view,
                        animated: true
                    )
                    ProgressHUD.showWarning(
                        addedTo: self.navigationController?.view,
                        text: "保存失败".localized,
                        animated: true,
                        delayHide: 1.5
                    )
                }
            }
        }
    }
    func addedCameraPhotoAsset(_ photoAsset: PhotoAsset) {
        func addPhotoAsset(_ photoAsset: PhotoAsset) {
            guard let picker = pickerController else { return }
            ProgressHUD.hide(forView: navigationController?.view, animated: true)
            if config.takePictureCompletionToSelected {
                if picker.addedPhotoAsset(photoAsset: photoAsset) {
                    updateCellSelectedTitle()
                }
            }
            picker.updateAlbums(coverImage: photoAsset.originalImage, count: 1)
            if photoAsset.isLocalAsset {
                picker.addedLocalCameraAsset(photoAsset: photoAsset)
            }
            if picker.config.albumShowMode == .popup {
                albumView.tableView.reloadData()
            }
            addedPhotoAsset(for: photoAsset)
            bottomView.updateFinishButtonTitle()
            setupEmptyView()
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
