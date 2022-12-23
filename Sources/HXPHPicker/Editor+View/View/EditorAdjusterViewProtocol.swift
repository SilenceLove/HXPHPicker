//
//  EditorAdjusterViewProtocol.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/30.
//

import UIKit
import AVFoundation

protocol EditorAdjusterViewDelegate: AnyObject {
    /// 编辑状态发生改变
    func editorAdjusterView(willBeginEditing adjusterView: EditorAdjusterView)
    /// 编辑状态改变结束
    func editorAdjusterView(didEndEditing adjusterView: EditorAdjusterView)
    /// 即将进入编辑状态
    func editorAdjusterView(editWillAppear adjusterView: EditorAdjusterView)
    /// 已经进入编辑状态
    func editorAdjusterView(editDidAppear adjusterView: EditorAdjusterView)
    /// 即将结束编辑状态
    func editorAdjusterView(editWillDisappear adjusterView: EditorAdjusterView)
    /// 已经结束编辑状态
    func editorAdjusterView(editDidDisappear adjusterView: EditorAdjusterView)
    /// 画笔/涂鸦/贴图发生改变
    func editorAdjusterView(contentViewBeganDrag adjusterView: PhotoEditorView)
    /// 画笔/涂鸦/贴图结束改变
    func editorAdjusterView(contentViewEndDraw adjusterView: PhotoEditorView)
    /// 点击的文字贴纸
    func editorAdjusterView(_ adjusterView: EditorAdjusterView, didSelectedStickerText item: EditorStickerItem)
    /// 移除了音乐贴纸
    func editorAdjusterView(didRemoveAudio adjusterView: EditorAdjusterView)
    
    
    func editorAdjusterView(_ editorAdjusterView: EditorAdjusterView, videoDidPlayAt time: CMTime)
    func editorAdjusterView(_ editorAdjusterView: EditorAdjusterView, videoDidPauseAt time: CMTime)
    func editorAdjusterView(videoReadyForDisplay editorAdjusterView: EditorAdjusterView)
}
