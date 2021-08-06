//
//  PhotoPickerViewController+Editor.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/4.
//

import UIKit

#if HXPICKER_ENABLE_EDITOR && HXPICKER_ENABLE_PICKER
// MARK: PhotoEditorViewControllerDelegate
extension PhotoPickerViewController: PhotoEditorViewControllerDelegate {
    public func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinish result: PhotoEditResult) {
        let photoAsset = photoEditorViewController.photoAsset!
        photoAsset.photoEdit = result
        pickerController?.didEditAsset(photoAsset: photoAsset, atIndex: assets.firstIndex(of: photoAsset) ?? 0)
        if !isMultipleSelect {
            if pickerController!.canSelectAsset(for: photoAsset, showHUD: true) {
                pickerController!.singleFinishCallback(for: photoAsset)
            }
            return
        }
        if !photoAsset.isSelected {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
            if pickerController!.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }else {
            reloadCell(for: photoAsset)
        }
        bottomView.updateFinishButtonTitle()
    }
    public func photoEditorViewController(didFinishWithUnedited photoEditorViewController: PhotoEditorViewController) {
        let photoAsset = photoEditorViewController.photoAsset!
        let beforeHasEdit = photoAsset.photoEdit != nil
        photoAsset.photoEdit = nil;
        if beforeHasEdit {
            pickerController?.didEditAsset(photoAsset: photoAsset, atIndex: assets.firstIndex(of: photoAsset) ?? 0)
        }
        if !isMultipleSelect {
            if pickerController!.canSelectAsset(for: photoAsset, showHUD: true) {
                pickerController!.singleFinishCallback(for: photoAsset)
            }
            return
        }
        let cell = getCell(for: photoAsset)
        cell?.requestThumbnailImage()
        if !photoAsset.isSelected {
            if pickerController!.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
            bottomView.updateFinishButtonTitle()
        }
    }
    public func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, loadTitleChartlet response: @escaping ([EditorChartlet]) -> Void) {
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(pickerController, loadTitleChartlet: photoEditorViewController, response: response)
        }
    }
    public func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, titleChartlet: EditorChartlet, titleIndex: Int, loadChartletList response: @escaping (Int, [EditorChartlet]) -> Void) {
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(pickerController, loadChartletList: photoEditorViewController, titleChartlet: titleChartlet, titleIndex: titleIndex, response: response)
        }
    }
    public func photoEditorViewController(didCancel photoEditorViewController: PhotoEditorViewController) {
        
    }
}
// MARK: VideoEditorViewControllerDelegate
extension PhotoPickerViewController: VideoEditorViewControllerDelegate {
    public func videoEditorViewController(shouldClickMusicTool videoEditorViewController: VideoEditorViewController) -> Bool {
        if let pickerController = pickerController,
           let shouldClick = pickerController.pickerDelegate?.pickerController(pickerController, videoEditorShouldClickMusicTool: videoEditorViewController) {
            return shouldClick
        }
        return true
    }
    public func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, loadMusic completionHandler: @escaping ([VideoEditorMusicInfo]) -> Void) -> Bool {
        if let pickerController = pickerController,
           let showLoading = pickerController.pickerDelegate?.pickerController(pickerController, videoEditor: videoEditorViewController, loadMusic: completionHandler) {
            return showLoading
        }
        return false
    }
    public func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didSearch text: String?, completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(pickerController, videoEditor: videoEditorViewController, didSearch: text, completionHandler: completionHandler)
        }
    }
    public func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, loadMore text: String?, completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(pickerController, videoEditor: videoEditorViewController, loadMore: text, completionHandler: completionHandler)
        }
    }
    public func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didFinish result: VideoEditResult) {
        let photoAsset = videoEditorViewController.photoAsset!
        photoAsset.videoEdit = result
        pickerController?.didEditAsset(photoAsset: photoAsset, atIndex: assets.firstIndex(of: photoAsset) ?? 0)
        if (photoAsset.mediaType == .video && videoLoadSingleCell) || !isMultipleSelect {
            if pickerController!.canSelectAsset(for: photoAsset, showHUD: true) {
                pickerController!.singleFinishCallback(for: photoAsset)
            }
            return
        }
        if !photoAsset.isSelected {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
            if pickerController!.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }else {
            reloadCell(for: photoAsset)
        }
        bottomView.updateFinishButtonTitle()
    }
    public func videoEditorViewController(didCancel videoEditorViewController: VideoEditorViewController) {
        
    }
    public func videoEditorViewController(didFinishWithUnedited videoEditorViewController: VideoEditorViewController) {
        let photoAsset = videoEditorViewController.photoAsset!
        let beforeHasEdit = photoAsset.videoEdit != nil
        photoAsset.videoEdit = nil
        if beforeHasEdit {
            pickerController?.didEditAsset(photoAsset: photoAsset, atIndex: assets.firstIndex(of: photoAsset) ?? 0)
        }
        if (photoAsset.mediaType == .video && videoLoadSingleCell) || !isMultipleSelect {
            if pickerController!.canSelectAsset(for: photoAsset, showHUD: true) {
                pickerController!.singleFinishCallback(for: photoAsset)
            }
            return
        }
        if beforeHasEdit {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
        }
        if !photoAsset.isSelected {
            if pickerController!.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
            bottomView.updateFinishButtonTitle()
        }
    }
}
#endif
