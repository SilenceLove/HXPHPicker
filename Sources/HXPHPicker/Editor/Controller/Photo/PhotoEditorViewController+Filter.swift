//
//  PhotoEditorViewController+Filter.swift
//  HXPHPicker
//
//  Created by Slience on 2021/9/16.
//

import UIKit

extension PhotoEditorViewController: PhotoEditorFilterViewDelegate {
    func filterView(shouldSelectFilter filterView: PhotoEditorFilterView) -> Bool {
        true
    }
    
    func filterView(
        _ filterView: PhotoEditorFilterView,
        didSelected filter: PhotoEditorFilter,
        atItem: Int
    ) {
        var originalImage = image
        let isOriginal = true
        if !filter.isOriginal {
            originalImage = thumbnailImage
        }
        if filter.isOriginal {
            if let image = originalImage {
                imageView.imageResizerView.hasFilter = isOriginal
                imageView.updateImage(image as Any)
                imageView.setMosaicOriginalImage(mosaicImage)
            }
            return
        }
        imageView.imageResizerView.hasFilter = true
        let lastImage = self.imageView.image as? UIImage
        let filterInfo = self.config.filter.infos[atItem]
        if let handler = filterInfo.filterHandler {
            if let ciImage = originalImage?.ci_Image,
               let newImage = handler(ciImage, lastImage, filter.parameters, false)?.image {
                let mosaicImage = newImage.mosaicImage(level: self.config.mosaic.mosaicWidth)
                self.imageView.updateImage(newImage)
                self.imageView.setMosaicOriginalImage(mosaicImage)
            }
        }else {
            
        }
    }
    
    func filterView(
        _ filterView: PhotoEditorFilterView,
        didSelectedParameter filter: PhotoEditorFilter,
        at index: Int
    ) {
        filterParameterView.type = .filter
        filterParameterView.title = filter.filterName
        filterParameterView.models = filter.parameters
        showFilterParameterView()
    }
    
    func filterView(
        _ filterView: PhotoEditorFilterView,
        didSelectedEdit editModel: PhotoEditorFilterEditModel
    ) {
        filterParameterView.type = .edit(type: editModel.type)
        filterParameterView.title = editModel.type.title
        filterParameterView.models = editModel.parameters
        showFilterParameterView()
    }
    
    func showFilterParameterView() {
        isShowFilterParameter = true
        UIView.animate(withDuration: 0.25) {
            self.setFilterParameterViewFrame()
        }
    }
    func hideFilterParameterView() {
        isShowFilterParameter = false
        UIView.animate(withDuration: 0.25) {
            self.setFilterParameterViewFrame()
        }
    }
}

extension PhotoEditorViewController: PhotoEditorFilterParameterViewDelegate {
    func filterParameterView(
        _ filterParameterView: PhotoEditorFilterParameterView,
        didChanged model: PhotoEditorFilterParameterInfo
    ) {
        filterView.reloadData()
        let index = filterView.currentSelectedIndex
        let filter = filterView.filters[index]
        switch filterParameterView.type {
        case .filter:
            let filterInfo = config.filter.infos[index - 1]
            if let handler = filterInfo.filterHandler {
                let originalImage = thumbnailImage
                if let ciImage = originalImage?.ci_Image,
                   let newImage = handler(ciImage, imageView.image as? UIImage, filter.parameters, false)?.image {
                    imageView.updateImage(newImage)
                    if mosaicToolView.canUndo {
                        let mosaicImage = newImage.mosaicImage(level: config.mosaic.mosaicWidth)
                        imageView.setMosaicOriginalImage(mosaicImage)
                    }
                }
            }else {
                
            }
        case .edit(let type):
            switch type {
            case .brightness:
                break
            case .contrast:
                break
            case .saturation:
                break
            case .warmth:
                break
            case .vignette:
                break
            case .sharpen:
                break
            }
        }
    }
}
