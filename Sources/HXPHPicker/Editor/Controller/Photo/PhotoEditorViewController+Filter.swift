//
//  PhotoEditorViewController+Filter.swift
//  HXPHPicker
//
//  Created by Slience on 2021/9/16.
//

import UIKit
#if canImport(Harbeth)
import Harbeth
#endif

extension PhotoEditorViewController: PhotoEditorFilterViewDelegate {
    func filterView(shouldSelectFilter filterView: PhotoEditorFilterView) -> Bool {
        true
    }
    
    func filterView(
        _ filterView: PhotoEditorFilterView,
        didSelected filter: PhotoEditorFilter,
        atItem: Int
    ) {
        if filter.isOriginal {
            imageView.imageResizerView.hasFilter = false
            imageView.updateImage(image as Any)
            imageView.setMosaicOriginalImage(mosaicImage)
            return
        }
        imageView.imageResizerView.hasFilter = true
        let lastImage = self.imageView.image as? UIImage
        let filterInfo = self.config.filter.infos[atItem]
        if let handler = filterInfo.filterHandler {
            if let ciImage = self.thumbnailImage.ci_Image,
               let newImage = handler(ciImage, lastImage, filter.parameters, false)?.image {
                let mosaicImage = newImage.mosaicImage(level: self.config.mosaic.mosaicWidth)
                self.imageView.updateImage(newImage)
                self.imageView.setMosaicOriginalImage(mosaicImage)
            }
        }else {
            #if canImport(Harbeth)
            var filters = Array(metalFilters.values)
            if let _filter = filterInfo.metalFilterHandler?(filter.parameters.first, false) {
                filters.append(_filter)
                let image = thumbnailImage.filter(c7s: filters)
                if let image = image {
                    let mosaicImage = image.mosaicImage(level: config.mosaic.mosaicWidth)
                    imageView.updateImage(image)
                    imageView.setMosaicOriginalImage(mosaicImage)
                }
            }
            #endif
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
        filterView.reloadData()
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
        let index = filterView.currentSelectedIndex
        let filter = filterView.filters[index]
        switch filterParameterView.type {
        case .filter:
            let filterInfo = config.filter.infos[index - 1]
            if let handler = filterInfo.filterHandler {
                if let ciImage = thumbnailImage.ci_Image,
                   let newImage = handler(ciImage, imageView.image as? UIImage, filter.parameters, false)?.image {
                    imageView.updateImage(newImage)
                    if mosaicToolView.canUndo {
                        let mosaicImage = newImage.mosaicImage(level: config.mosaic.mosaicWidth)
                        imageView.setMosaicOriginalImage(mosaicImage)
                    }
                }
            }else {
                #if canImport(Harbeth)
                var filters = Array(metalFilters.values)
                if let c7Fiter = filterInfo.metalFilterHandler?(filter.parameters.first, false) {
                    filters.append(c7Fiter)
                    let image = thumbnailImage.filter(c7s: filters)
                    if let image = image {
                        imageView.updateImage(image)
                        if mosaicToolView.canUndo {
                            let mosaicImage = image.mosaicImage(level: config.mosaic.mosaicWidth)
                            imageView.setMosaicOriginalImage(mosaicImage)
                        }
                    }
                }
                #endif
            }
        case .edit(let type):
            #if canImport(Harbeth)
            var filterInfo: PhotoEditorFilterInfo?
            if index > 0 {
                filterInfo = config.filter.infos[index - 1]
            }
            var originalImage = thumbnailImage
            let metalFilter = metalFilters[type]
//            {
//                let exposure = C7Exposure()
//                let contrast = C7Contrast()
//                let saturation = C7Saturation()
//                var warmth = C7ColorRGBA()
//                warmth.color = .white
//                var vignette = C7Vignette()
//                vignette.color = .black
//            }
            switch type {
            case .brightness:
                var c7filter: C7Exposure
                if metalFilter == nil {
                    c7filter = C7Exposure()
                }else {
                    c7filter = metalFilter as! C7Exposure
                }
                c7filter.exposure = model.value
                metalFilters[type] = c7filter
                break
            case .contrast:
                var c7filter: C7Contrast
                if metalFilter == nil {
                    c7filter = C7Contrast()
                }else {
                    c7filter = metalFilter as! C7Contrast
                }
                c7filter.contrast = 1 + model.value * 0.5
                metalFilters[type] = c7filter
            case .saturation:
                var c7filter: C7Saturation
                if metalFilter == nil {
                    c7filter = C7Saturation()
                }else {
                    c7filter = metalFilter as! C7Saturation
                }
                c7filter.saturation = 1 + model.value
                metalFilters[type] = c7filter
            case .warmth:
                var c7filter: C7ColorRGBA
                if metalFilter == nil {
                    c7filter = C7ColorRGBA()
                    c7filter.color = .white
                }else {
                    c7filter = metalFilter as! C7ColorRGBA
                }
                c7filter.red = 1 + model.value * 0.5
                metalFilters[type] = c7filter
            case .vignette:
                var c7filter: C7Vignette
                if metalFilter == nil {
                    c7filter = C7Vignette()
                    c7filter.color = .black
                }else {
                    c7filter = metalFilter as! C7Vignette
                }
                c7filter.start = c7filter.end * (1 - model.value)
                metalFilters[type] = c7filter
            case .sharpen:
                var c7filter: C7Convolution3x3
                if metalFilter == nil {
                    c7filter = C7Convolution3x3(convolutionType: .sharpen(iterations: 1))
                }else {
                    c7filter = metalFilter as! C7Convolution3x3
                }
                c7filter.updateMatrix(.sharpen(iterations: 1 + model.value))
                metalFilters[type] = c7filter
            }
            if model.value == 0 {
                metalFilters[type] = nil
            }
            var filters = Array(metalFilters.values)
            if let c7Filter = filterInfo?.metalFilterHandler?(filter.parameters.first, false) {
                filters.append(c7Filter)
            }
            if let image = originalImage?.filter(c7s: filters), !filters.isEmpty {
                originalImage = image
            }
            if let originalImage = originalImage {
                imageView.updateImage(originalImage)
                if mosaicToolView.canUndo {
                    let mosaicImage = image.mosaicImage(level: config.mosaic.mosaicWidth)
                    imageView.setMosaicOriginalImage(mosaicImage)
                }
            }
            #else
            break
            #endif
        }
    }
}
