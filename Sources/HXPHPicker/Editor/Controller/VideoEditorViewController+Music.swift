//
//  VideoEditorViewController+Music.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/6.
//

import UIKit

// MARK: VideoEditorMusicViewDelegate
extension VideoEditorViewController: VideoEditorMusicViewDelegate {
    func musicView(_ musicView: VideoEditorMusicView, didSelectMusic audioPath: String?) {
        backgroundMusicPath = audioPath
    }
    func musicView(deselectMusic musicView: VideoEditorMusicView) {
        backgroundMusicPath = nil
    }
    func musicView(didSearchButton musicView: VideoEditorMusicView) {
        searchMusicView.searchView.becomeFirstResponder()
        isSearchMusic = true
        UIView.animate(withDuration: 0.25) {
            self.setSearchMusicViewFrame()
        }
    }
    func musicView(_ musicView: VideoEditorMusicView, didOriginalSoundButtonClick isSelected: Bool) {
        if isSelected {
            playerView.player.volume = 1
        }else {
            playerView.player.volume = 0
        }
    }
}

// MARK: VideoEditorSearchMusicViewDelegate
extension VideoEditorViewController: VideoEditorSearchMusicViewDelegate {
    func searchMusicView(didCancelClick searchMusicView: VideoEditorSearchMusicView) {
        hideSearchMusicView()
    }
    func searchMusicView(didFinishClick searchMusicView: VideoEditorSearchMusicView) {
        hideSearchMusicView(deselect: false)
    }
    func searchMusicView(_ searchMusicView: VideoEditorSearchMusicView, didSelectItem audioPath: String?) {
        musicView.reset()
        musicView.backgroundButton.isSelected = true
        backgroundMusicPath = audioPath
    }
    func searchMusicView(_ searchMusicView: VideoEditorSearchMusicView, didSearch text: String?, completion: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
        delegate?.videoEditorViewController(self, didSearch: text, completionHandler: completion)
    }
    func searchMusicView(_ searchMusicView: VideoEditorSearchMusicView, loadMore text: String?, completion: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
        delegate?.videoEditorViewController(self, loadMore: text, completionHandler: completion)
    }
    func searchMusicView(deselectItem searchMusicView: VideoEditorSearchMusicView) {
        backgroundMusicPath = nil
        musicView.backgroundButton.isSelected = false
    }
    func hideSearchMusicView(deselect: Bool = true) {
        searchMusicView.endEditing(true)
        isSearchMusic = false
        UIView.animate(withDuration: 0.25) {
            self.setSearchMusicViewFrame()
        } completion: { _ in
            if deselect {
                self.searchMusicView.deselect()
            }
            self.searchMusicView.clearData()
        }
    }
}

