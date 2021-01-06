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
        if titleView.isSelected {
            return
        }
        let localPoint = panGR.location(in: collectionView)
        swipeSelectLastLocalPoint = panGR.location(in: view)
        switch panGR.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: localPoint), let cell = getCell(for: indexPath.item) {
                swipeSelectedIndexArray = []
                swipeSelectBeganIndexPath = collectionView.indexPathForItem(at: localPoint)
                swipeSelectState = cell.photoAsset!.isSelected ? .unselect : .select
                updateCellSelectedState(for: indexPath.item, isSelected: swipeSelectState == .select)
                swipeSelectedIndexArray?.append(indexPath.item)
                swipeSelectAutoScroll()
            }
            break
        case .changed:
            let lastIndexPath = collectionView.indexPathForItem(at: localPoint)
            if let lastIndex = lastIndexPath?.item, let lastIndexPath = lastIndexPath {
                if let beganIndex = swipeSelectBeganIndexPath?.item, let swipeSelectState = swipeSelectState {
                    if let swipeSelectLastIndex = swipeSelectLastIndexPath?.item {
                        var firstItem: Int?
                        var lastItem: Int?
                        var filterBeganIndex = false
                        if lastIndex < beganIndex {
                            if swipeSelectLastIndex > beganIndex {
                                firstItem = beganIndex
                                lastItem = swipeSelectLastIndex
                                filterBeganIndex = true
                            }else {
                                if swipeSelectLastIndex < lastIndex {
                                    firstItem = swipeSelectLastIndex
                                    lastItem = lastIndex
                                }
                            }
                        }else {
                            if swipeSelectLastIndex < beganIndex {
                                firstItem = swipeSelectLastIndex
                                lastItem = beganIndex
                                filterBeganIndex = true
                            }else {
                                if swipeSelectLastIndex > lastIndex {
                                    firstItem = lastIndex
                                    lastItem = swipeSelectLastIndex
                                    filterBeganIndex = true
                                }
                            }
                        }
                        if let firstItem = firstItem, let lastItem = lastItem {
                            for index in firstItem...lastItem {
                                if !swipeSelectedIndexArray!.contains(index) {
                                    continue
                                }
                                if filterBeganIndex && index == beganIndex {
                                    continue
                                }
                                updateCellSelectedState(for: index, isSelected: !(swipeSelectState == .select))
                                let firstIndex = swipeSelectedIndexArray!.firstIndex(of: index)!
                                swipeSelectedIndexArray?.remove(at: firstIndex)
                            }
                            if let lastPhotoAsset = pickerController?.selectedAssetArray.last, let cell = getCell(for: lastPhotoAsset), let cellIndexPath = collectionView.indexPath(for: cell) {
                                // 防止有错过的数据
                                if lastIndex < beganIndex && cellIndexPath.item < firstItem {
                                    for index in cellIndexPath.item...firstItem {
                                        updateCellSelectedState(for: index, isSelected: !(swipeSelectState == .select))
                                        if let array = swipeSelectedIndexArray, array.contains(index) {
                                            let firstIndex = swipeSelectedIndexArray!.firstIndex(of: index)!
                                            swipeSelectedIndexArray?.remove(at: firstIndex)
                                        }
                                    }
                                }else if lastIndex > beganIndex && cellIndexPath.item > lastItem {
                                    for index in lastItem...cellIndexPath.item {
                                        updateCellSelectedState(for: index, isSelected: !(swipeSelectState == .select))
                                        if let array = swipeSelectedIndexArray, array.contains(index) {
                                            let firstIndex = swipeSelectedIndexArray!.firstIndex(of: index)!
                                            swipeSelectedIndexArray?.remove(at: firstIndex)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if beganIndex > lastIndex {
                        var index = beganIndex
                        while index >= lastIndex {
                            panGRChangedUpdateState(index: index, state: swipeSelectState)
                            index -= 1
                        }
                    }else if beganIndex < lastIndex {
                        for index in beganIndex ... lastIndex {
                            panGRChangedUpdateState(index: index, state: swipeSelectState)
                        }
                    }else {
                        panGRChangedUpdateState(index: beganIndex, state: swipeSelectState)
                    }
                    updateCellSelectedTitle()
                    if swipeSelectState == .select {
                        if swipeSelectLastIndexPath?.item != lastIndex {
                            swipeSelectLastIndexPath = lastIndexPath
                        }
                    }else {
                        swipeSelectLastIndexPath = lastIndexPath
                    }
                }else {
                    if let cell = getCell(for: lastIndex) {
                        swipeSelectedIndexArray = []
                        swipeSelectBeganIndexPath = lastIndexPath
                        swipeSelectState = cell.photoAsset!.isSelected ? .unselect : .select
                        updateCellSelectedState(for: lastIndex, isSelected: swipeSelectState == .select)
                        swipeSelectedIndexArray?.append(lastIndex)
                        swipeSelectAutoScroll()
                    }
                }
            }else {
                
                if let beganIndex = swipeSelectBeganIndexPath?.item, let swipeSelectState = swipeSelectState, let swipeSelectLastIndex = swipeSelectLastIndexPath?.item {
                    if let lastPhotoAsset = pickerController?.selectedAssetArray.last, let cell = getCell(for: lastPhotoAsset), let cellIndexPath = collectionView.indexPath(for: cell) {
                        // 防止有错过的数据
                        if swipeSelectLastIndex < beganIndex && cellIndexPath.item < swipeSelectLastIndex {
                            for index in cellIndexPath.item...swipeSelectLastIndex {
                                updateCellSelectedState(for: index, isSelected: !(swipeSelectState == .select))
                                if let array = swipeSelectedIndexArray, array.contains(index) {
                                    let firstIndex = swipeSelectedIndexArray!.firstIndex(of: index)!
                                    swipeSelectedIndexArray?.remove(at: firstIndex)
                                }
                            }
                        }else if swipeSelectLastIndex > beganIndex && cellIndexPath.item > swipeSelectLastIndex {
                            for index in swipeSelectLastIndex...cellIndexPath.item {
                                updateCellSelectedState(for: index, isSelected: !(swipeSelectState == .select))
                                if let array = swipeSelectedIndexArray, array.contains(index) {
                                    let firstIndex = swipeSelectedIndexArray!.firstIndex(of: index)!
                                    swipeSelectedIndexArray?.remove(at: firstIndex)
                                }
                            }
                        }
                    }
                }
            }
            break
        case .ended, .cancelled, .failed:
            clearSwipeSelectData()
            break
        default:
            break
        }
    }
    func clearSwipeSelectData() {
        swipeSelectAutoScrollTimer?.cancel()
        swipeSelectAutoScrollTimer = nil
        
        swipeSelectLastIndexPath = nil
        swipeSelectBeganIndexPath = nil
        swipeSelectState = nil
        swipeSelectedIndexArray = nil
    }
    func panGRChangedUpdateState(index: Int, state: HXPHPickerViewControllerSwipeSelectState) {
        if let photoAsset = getCell(for: index)?.photoAsset {
            if swipeSelectState == .select {
                if let array = swipeSelectedIndexArray, !photoAsset.isSelected && !array.contains(index) {
                    swipeSelectedIndexArray?.append(index)
                }
            }else {
                if let array = swipeSelectedIndexArray, photoAsset.isSelected && !array.contains(index) {
                    swipeSelectedIndexArray?.append(index)
                }
            }
            updateCellSelectedState(for: index, isSelected: state == .select)
        }
    }
    func swipeSelectAutoScroll() {
        if !config.swipeSelectAllowAutoScroll {
            return
        }
        swipeSelectAutoScrollTimer = DispatchSource.makeTimerSource()
        swipeSelectAutoScrollTimer?.schedule(deadline: .now() + .milliseconds(250), repeating: .milliseconds(250), leeway: .microseconds(0))
        swipeSelectAutoScrollTimer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                self.startAutoScroll()
            }
        })
        swipeSelectAutoScrollTimer?.resume()
    }
    func startAutoScroll() {
        if let localPoint = swipeSelectLastLocalPoint {
            let topRect = CGRect(x: 0, y: 0, width: view.width, height: config.autoSwipeTopAreaHeight + collectionView.contentInset.top)
            let bottomRect = CGRect(x: 0, y: collectionView.height - collectionView.contentInset.bottom - config.autoSwipeBottomAreaHeight, width: view.width, height: config.autoSwipeBottomAreaHeight + collectionView.contentInset.bottom)
            let margin: CGFloat = 120 * config.swipeSelectScrollSpeed
            var offsety: CGFloat
            if topRect.contains(localPoint) {
                offsety = self.collectionView.contentOffset.y - margin
                if offsety < -collectionView.contentInset.top {
                    offsety = -collectionView.contentInset.top
                }
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                    self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: offsety)
                } completion: { (isFinished) in
                }
            }else if bottomRect.contains(localPoint) {
                offsety = self.collectionView.contentOffset.y + margin
                let maxOffsetY = collectionView.contentSize.height - collectionView.height + collectionView.contentInset.bottom
                if offsety > maxOffsetY {
                    offsety = maxOffsetY
                }
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                    self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: offsety)
                } completion: { (isFinished) in
                }
            }
            panGestureRecognizer(panGR: swipeSelectPanGR!)
        }
    }
    
    func updateCellSelectedState(for item: Int, isSelected: Bool) {
        var showHUD = false
        if let cell = getCell(for: item), let pickerController = pickerController {
            if cell.photoAsset!.isSelected != isSelected {
                if isSelected {
                    if pickerController.canSelectAsset(for: cell.photoAsset!, showHUD: false) {
                        _ = pickerController.addedPhotoAsset(photoAsset: cell.photoAsset!)
                        cell.updateSelectedState(isSelected: isSelected, animated: false)
                    }else {
                        showHUD = true
                    }
                }else {
                    _ = pickerController.removePhotoAsset(photoAsset: cell.photoAsset!)
                    cell.updateSelectedState(isSelected: isSelected, animated: false)
                }
            }
            bottomView.updateFinishButtonTitle()
        }
        if pickerController!.selectArrayIsFull() && showHUD {
            HXPHProgressHUD.showWarningHUD(addedTo: navigationController?.view, text: String.init(format: "已达到最大选择数".localized, arguments: [pickerController!.config.maximumSelectedPhotoCount]), animated: true, delay: 2)
            swipeSelectPanGR?.isEnabled = false
            swipeSelectPanGR?.isEnabled = true
            clearSwipeSelectData()
        }
    }
}
