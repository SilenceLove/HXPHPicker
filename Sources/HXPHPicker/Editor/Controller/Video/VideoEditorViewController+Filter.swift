//
//  VideoEditorViewController+Filter.swift
//  HXPHPicker
//
//  Created by Slience on 2022/1/12.
//

import UIKit

extension VideoEditorViewController: PhotoEditorFilterViewDelegate {
    
    func filterView(shouldSelectFilter filterView: PhotoEditorFilterView) -> Bool {
        true
    }
    
    func filterView(
        _ filterView: PhotoEditorFilterView,
        didSelected filter: PhotoEditorFilter,
        atItem: Int
    ) {
        if filter.isOriginal {
            videoView.imageResizerView.videoFilter = nil
            videoView.playerView.setFilter(nil, parameters: [])
            return
        }
        let filterInfo = self.config.filter.infos[atItem]
        videoView.playerView.setFilter(filterInfo, parameters: filter.parameters)
        videoView.imageResizerView.videoFilter = .init(index: atItem, parameters: filter.parameters)
    }
    
    func showFilterView() {
        isFilter = true
        UIView.animate(withDuration: 0.25) {
            self.setFilterViewFrame()
        }
    }
    func hiddenFilterView() {
        isFilter = false
        UIView.animate(withDuration: 0.25) {
            self.setFilterViewFrame()
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
        filterView.reloadData()
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

extension VideoEditorViewController: PhotoEditorFilterParameterViewDelegate {
    func filterParameterView(
        _ filterParameterView: PhotoEditorFilterParameterView,
        didChanged model: PhotoEditorFilterParameterInfo
    ) {
        switch filterParameterView.type {
        case .filter:
            let index = filterView.currentSelectedIndex
            let filter = filterView.filters[index]
            let filterInfo = config.filter.infos[index - 1]
            videoView.playerView.setFilter(filterInfo, parameters: filter.parameters)
            videoView.imageResizerView.videoFilter = .init(index: index - 1, parameters: filter.parameters)
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
