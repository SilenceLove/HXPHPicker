//
//  HXPHPickerViewController+SwipeSelect.swift
//  HXPHPicker
//
//  Created by Slience on 2020/12/31.
//

import UIKit

// MARK: 滑动选择
extension HXPHPickerViewController {
    
    @objc func panGestureRecognizer(panGR: UIPanGestureRecognizer) {
        let localPoint = panGR.location(in: collectionView)
        switch panGR.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: localPoint), let cell = getCell(for: indexPath.item) {
                swipeSelectedIndexArray = []
                swipeSelectBeganIndexPath = collectionView.indexPathForItem(at: localPoint)
                swipeSelectState = cell.photoAsset!.isSelected ? .unselect : .select
                updateCellSelectedState(for: indexPath.item, isSelected: swipeSelectState == .select)
                swipeSelectedIndexArray?.append(indexPath.item)
            }
            break
        case .changed:
            let lastIndexPath = collectionView.indexPathForItem(at: localPoint)
            if let lastIndex = lastIndexPath?.item, let lastIndexPath = lastIndexPath {
                if let beganIndex = swipeSelectBeganIndexPath?.item, let swipeSelectState = swipeSelectState, let swipeSelectedIndexArray = swipeSelectedIndexArray {
                    if let swipeSelectLastIndex = swipeSelectLastIndexPath?.item {
                        if swipeSelectState == .select {
                            // 取消已选
                            if beganIndex <= lastIndex && swipeSelectLastIndex > lastIndex {
                                // 往下
                                for index in lastIndex ... swipeSelectLastIndex {
                                    if index == lastIndex {
                                        continue
                                    }
                                    if !swipeSelectedIndexArray.contains(index) {
                                        continue
                                    }
                                    updateCellSelectedState(for: index, isSelected: false)
                                    if let firstIndex = self.swipeSelectedIndexArray?.firstIndex(of: index) {
                                        self.swipeSelectedIndexArray?.remove(at: firstIndex)
                                    }
                                }
                            }else if beganIndex >= lastIndex && swipeSelectLastIndex < lastIndex {
                                // 往上
                                for index in swipeSelectLastIndex ..< lastIndex {
                                    if !swipeSelectedIndexArray.contains(index) {
                                        continue
                                    }
                                    updateCellSelectedState(for: index, isSelected: false)
                                    if let firstIndex = self.swipeSelectedIndexArray?.firstIndex(of: index) {
                                        self.swipeSelectedIndexArray?.remove(at: firstIndex)
                                    }
                                }
                            }
                        }else {
                            // 取消反选
                            if beganIndex <= lastIndex {
                                // 往下
                                if swipeSelectLastIndex > lastIndex {
                                    for index in lastIndex ... swipeSelectLastIndex {
                                        if !swipeSelectedIndexArray.contains(index) {
                                            continue
                                        }
                                        let photoAsset = getPhotoAsset(for: index)
                                        _ = pickerController?.removePhotoAsset(photoAsset: photoAsset)
                                        updateCellSelectedState(for: index, isSelected: true)
                                    }
                                }else if swipeSelectLastIndex < lastIndex && swipeSelectLastIndex < beganIndex  {
                                    for index in swipeSelectLastIndex ... beganIndex {
                                        if !swipeSelectedIndexArray.contains(index) {
                                            continue
                                        }
                                        let photoAsset = getPhotoAsset(for: index)
                                        _ = pickerController?.removePhotoAsset(photoAsset: photoAsset)
                                        updateCellSelectedState(for: index, isSelected: true)
                                    }
                                }
                            }else if beganIndex >= lastIndex {
                                // 往上
                                if swipeSelectLastIndex < lastIndex {
                                    for index in swipeSelectLastIndex ... lastIndex {
                                        if !swipeSelectedIndexArray.contains(index) {
                                            continue
                                        }
                                        let photoAsset = getPhotoAsset(for: index)
                                        _ = pickerController?.removePhotoAsset(photoAsset: photoAsset)
                                        updateCellSelectedState(for: index, isSelected: true)
                                    }
                                }else if swipeSelectLastIndex > lastIndex && swipeSelectLastIndex > beganIndex {
                                    for index in beganIndex ... swipeSelectLastIndex {
                                        if !swipeSelectedIndexArray.contains(index) {
                                            continue
                                        }
                                        let photoAsset = getPhotoAsset(for: index)
                                        _ = pickerController?.removePhotoAsset(photoAsset: photoAsset)
                                        updateCellSelectedState(for: index, isSelected: true)
                                    }
                                }
                            }
                        }
                    }
                    if beganIndex > lastIndex {
                        var index = beganIndex
                        while index >= lastIndex {
                            if swipeSelectState == .select {
                                if !swipeSelectedIndexArray.contains(index){
                                    self.swipeSelectedIndexArray?.append(index)
                                }
                            }else {
                                let photoAsset = getPhotoAsset(for: index)
                                if !swipeSelectedIndexArray.contains(index) && photoAsset.isSelected {
                                    self.swipeSelectedIndexArray?.append(index)
                                }
                            }
                            updateCellSelectedState(for: index, isSelected: swipeSelectState == .select)
                            index -= 1
                        }
                    }else if beganIndex < lastIndex{
                        for index in beganIndex ... lastIndex {
                            if swipeSelectState == .select {
                                if !swipeSelectedIndexArray.contains(index){
                                    self.swipeSelectedIndexArray?.append(index)
                                }
                            }else {
                                let photoAsset = getPhotoAsset(for: index)
                                if !swipeSelectedIndexArray.contains(index) && photoAsset.isSelected {
                                    self.swipeSelectedIndexArray?.append(index)
                                }
                            }
                            updateCellSelectedState(for: index, isSelected: swipeSelectState == .select)
                        }
                    }else {
                        if swipeSelectState == .select {
                            if !swipeSelectedIndexArray.contains(beganIndex){
                                self.swipeSelectedIndexArray?.append(beganIndex)
                            }
                        }else {
                            let photoAsset = getPhotoAsset(for: beganIndex)
                            if !swipeSelectedIndexArray.contains(beganIndex) && photoAsset.isSelected {
                                self.swipeSelectedIndexArray?.append(beganIndex)
                            }
                        }
                        updateCellSelectedState(for: beganIndex, isSelected: swipeSelectState == .select)
                    }
                    updateCellSelectedTitle()
                    if swipeSelectState == .select {
                        if swipeSelectLastIndexPath?.item != lastIndex {
                            swipeSelectLastIndexPath = lastIndexPath
                        }
                    }else {
                        if let selectLastIndex = swipeSelectLastIndexPath?.item {
                            if beganIndex < lastIndex {
                                // 往下
                                if lastIndex > selectLastIndex {
                                    if self.swipeSelectedIndexArray!.contains(lastIndex) {
                                        swipeSelectLastIndexPath = lastIndexPath
                                    }
                                }
                            }else if beganIndex > lastIndex {
                                // 往上
                                if lastIndex < selectLastIndex {
                                    if self.swipeSelectedIndexArray!.contains(lastIndex) {
                                        swipeSelectLastIndexPath = lastIndexPath
                                    }
                                }
                            }
                        }else {
                            swipeSelectLastIndexPath = lastIndexPath
                        }
                    }
                }else {
                    if let cell = getCell(for: lastIndex) {
                        swipeSelectedIndexArray = []
                        swipeSelectBeganIndexPath = lastIndexPath
                        swipeSelectState = cell.photoAsset!.isSelected ? .unselect : .select
                        updateCellSelectedState(for: lastIndex, isSelected: swipeSelectState == .select)
                        swipeSelectedIndexArray?.append(lastIndex)
                    }
                }
            }
            break
        case .ended, .cancelled, .failed:
            swipeSelectLastIndexPath = nil
            swipeSelectBeganIndexPath = nil
            swipeSelectState = nil
            swipeSelectedIndexArray = nil
            break
        default:
            break
        }
    }
    
    func updateCellSelectedState(for item: Int, isSelected: Bool) {
        if let cell = getCell(for: item), let pickerController = pickerController {
            if cell.photoAsset!.isSelected != isSelected {
                if isSelected {
                    if pickerController.canSelectAsset(for: cell.photoAsset!, showHUD: false) {
                        _ = pickerController.addedPhotoAsset(photoAsset: cell.photoAsset!)
                        cell.updateSelectedState(isSelected: isSelected, animated: false)
                    }
                }else {
                    _ = pickerController.removePhotoAsset(photoAsset: cell.photoAsset!)
                    cell.updateSelectedState(isSelected: isSelected, animated: false)
                }
            }
            bottomView.updateFinishButtonTitle()
        }
    }
}
