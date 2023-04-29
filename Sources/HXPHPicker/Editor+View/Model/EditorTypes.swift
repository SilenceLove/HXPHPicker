//
//  EditorTypes.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/13.
//

import UIKit
import AVFoundation

public extension EditorView {
    
    enum State {
        /// 正常状态
        case normal
        /// 编辑状态
        case edit
    }
    
    enum MaskType: Equatable {
        /// 毛玻璃效果
        case blurEffect(style: UIBlurEffect.Style)
        /// 自定义颜色
        case customColor(color: UIColor)
    }
}

public enum EditorContentViewType {
    case unknown
    case image
    case video
}

public enum EditorMosaicType: Int, Codable {
    /// 马赛克
    case mosaic
    /// 涂抹
    case smear
}

public struct EditorVideoFactor {
    /// 时间区域
    public let timeRang: CMTimeRange
    /// 原始视频音量
    public let volume: Float
    /// 需要添加的音频数据
    public let audios: [Audio]
    /// 裁剪圆切或者自定义蒙版时，被遮住的部分的处理类型
    /// 可自定义颜色，毛玻璃效果统一为 .light
    public let maskType: EditorView.MaskType?
    /// 导出视频的分辨率
    public let preset: ExportPreset
    /// 导出视频的质量 [0-10]
    public let quality: Int
    public init(
        timeRang: CMTimeRange = .zero,
        volume: Float = 1,
        audios: [Audio] = [],
        maskType: EditorView.MaskType? = nil,
        preset: ExportPreset,
        quality: Int
    ) {
        self.timeRang = timeRang
        self.volume = volume
        self.audios = audios
        self.maskType = maskType
        self.preset = preset
        self.quality = quality
    }
    
    public struct Audio {
        let url: URL
        let volume: Float
    }
    
    func isEqual(_ facotr: EditorVideoFactor) -> Bool {
        if timeRang.start.seconds != facotr.timeRang.start.seconds {
            return false
        }
        if timeRang.duration.seconds != facotr.timeRang.duration.seconds {
            return false
        }
        if volume != facotr.volume {
            return false
        }
        if audios.count != facotr.audios.count {
            return false
        }
        for (index, audio) in audios.enumerated() {
            let tmpAudio = facotr.audios[index]
            if audio.url.path != tmpAudio.url.path {
                return false
            }
            if audio.volume != tmpAudio.volume {
                return false
            }
        }
        if preset != facotr.preset {
            return false
        }
        if quality != facotr.quality {
            return false
        }
        return true
    }
}

public enum EditorError: LocalizedError {
    
    public enum `Type` {
        case exportFailed
        case removeFile
        case writeFileFailed
        case blankFrame
        case dataAcquisitionFailed
        case cropImageFailed
        case inputIsEmpty
        case compressionFailed
        case typeError
        case nothingProcess
        case cancelled
    }
    
    case error(type: `Type`, message: String)
}

public extension EditorError {
    
    var isCancel: Bool {
        switch self {
        case let .error(type, _):
            return type == .cancelled
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .error(_, message):
            return message
        }
    }
}

extension EditorMaskView {
    
    enum `Type` {
        case frame
        case mask
        case customMask
    }
}

extension EditorControlView {
    struct Factor {
        var fixedRatio: Bool = false
        var aspectRatio: CGSize = .zero
    }
}
extension EditorView {
    enum Operate {
        case startEdit((() -> Void)?)
        case finishEdit((() -> Void)?)
        case cancelEdit((() -> Void)?)
        case rotate(CGFloat, (() -> Void)?)
        case rotateLeft((() -> Void)?)
        case rotateRight((() -> Void)?)
        case mirrorHorizontally((() -> Void)?)
        case mirrorVertically((() -> Void)?)
        case reset((() -> Void)?)
        case setRoundMask(Bool)
        case setData(EditResult.AdjustmentData)
    }
}

extension EditorAdjusterView {
    
    enum ImageOrientation {
        case up
        case left
        case right
        case down
    }
    
    struct AdjustedFactor {
        var angle: CGFloat = 0
        var zoomScale: CGFloat = 1
        var contentOffset: CGPoint = .zero
        var contentInset: UIEdgeInsets = .zero
        var maskRect: CGRect = .zero
        var transform: CGAffineTransform = .identity
        var rotateTransform: CGAffineTransform = .identity
        var mirrorTransform: CGAffineTransform = .identity
        var maskImage: UIImage? = nil
        
        var contentOffsetScale: CGPoint = .zero
        var min_zoom_scale: CGFloat = 1
        var isRoundMask: Bool = false
    }
    
}
