//
//  EditorVideoTool.swift
//  HXPHPicker
//
//  Created by Slience on 2023/3/15.
//

import UIKit
import AVKit

class EditorVideoTool {
    
    struct Watermark {
        let layers: [CALayer]
        let images: [UIImage]
    }
    
    struct Sticker {
        
    }
    
    let avAsset: AVAsset
    let outputURL: URL
    let factor: EditorVideoFactor
    let watermark: Watermark
    let cropFactor: EditorAdjusterView.CropFactor
    let maskType: EditorView.MaskType
    
    init(
        avAsset: AVAsset,
        outputURL: URL,
        factor: EditorVideoFactor,
        watermark: Watermark,
        cropFactor: EditorAdjusterView.CropFactor,
        maskType: EditorView.MaskType
    ) {
        self.avAsset = avAsset
        self.outputURL = outputURL
        self.factor = factor
        self.watermark = watermark
        self.cropFactor = cropFactor
        self.maskType = maskType
    }
   
    func export(
        progressHandler: ((CGFloat) -> Void)? = nil,
        completionHandler: @escaping (Result<URL, EditorError>) -> Void
    ) {
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        exprotHandler()
    }
    
    func cancelExport() {
        progressTimer?.invalidate()
        progressTimer = nil
        exportSession?.cancelExport()
        exportSession = nil
    }
    
    private var exportSession: AVAssetExportSession?
    private var completionHandler: ((Result<URL, EditorError>) -> Void)?
    private var progressHandler: ((CGFloat) -> Void)?
    private var progressTimer: Timer?
    
    private func exprotHandler() {
        do {
            let exportPresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
            if !exportPresets.contains(factor.preset.name) {
                throw EditorError.error(type: .exportFailed, message: "设备不支持导出：" + factor.preset.name)
            }
            guard let videoTrack = avAsset.tracks(withMediaType: .video).first else {
                throw NSError(domain: "Video track is nil", code: 500, userInfo: nil)
            }
            var timeRang = factor.timeRang
            let videoTotalSeconds = videoTrack.timeRange.duration.seconds
            if timeRang.start.seconds + timeRang.duration.seconds > videoTotalSeconds {
                timeRang = CMTimeRange(
                    start: timeRang.start,
                    duration: CMTime(
                        seconds: videoTotalSeconds - timeRang.start.seconds,
                        preferredTimescale: timeRang.start.timescale
                    )
                )
            }
            try insertVideoTrack(for: videoTrack)
            
            var addVideoComposition = false
            let animationBeginTime: CFTimeInterval
            if timeRang == .zero {
                animationBeginTime = AVCoreAnimationBeginTimeAtZero
            }else {
                animationBeginTime = timeRang.start.seconds == 0 ?
                    AVCoreAnimationBeginTimeAtZero :
                    timeRang.start.seconds
            }
            if videoComposition.renderSize.width > 0 {
                addVideoComposition = true
            }
            try insertAudioTrack(
                duration: videoTrack.timeRange.duration,
                timeRang: timeRang,
                audioTracks: avAsset.tracks(withMediaType: .audio)
            )
            guard let exportSession = AVAssetExportSession(
                asset: mixComposition,
                presetName: factor.preset.name
            ) else {
                throw EditorError.error(type: .exportFailed, message: "不支持导出该类型视频")
            }
            let supportedTypeArray = exportSession.supportedFileTypes
            exportSession.outputURL = outputURL
            if supportedTypeArray.contains(AVFileType.mp4) {
                exportSession.outputFileType = .mp4
            }else if supportedTypeArray.isEmpty {
                throw EditorError.error(type: .exportFailed, message: "不支持导出该类型视频")
            }else {
                exportSession.outputFileType = supportedTypeArray.first
            }
            exportSession.shouldOptimizeForNetworkUse = true
            if addVideoComposition {
                exportSession.videoComposition = videoComposition
            }
            if !audioMix.inputParameters.isEmpty {
                exportSession.audioMix = audioMix
            }
            if timeRang != .zero {
                exportSession.timeRange = timeRang
            }
            if factor.quality > 0 {
                let seconds = timeRang != .zero ? timeRang.duration.seconds : videoTotalSeconds
                var maxSize: Int?
                if let urlAsset = avAsset as? AVURLAsset {
                    let scale = Double(max(seconds / videoTotalSeconds, 0.4))
                    maxSize = Int(Double(urlAsset.url.fileSize) * scale)
                }
                exportSession.fileLengthLimit = fileLengthLimit(
                    seconds: seconds,
                    maxSize: maxSize
                )
            }
            exportSession.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    switch exportSession.status {
                    case .completed:
                        self.progressHandler?(1)
                        self.progressTimer?.invalidate()
                        self.progressTimer = nil
                        self.completionHandler?(.success(self.outputURL))
                    case .failed, .cancelled:
                        self.progressTimer?.invalidate()
                        self.progressTimer = nil
                        let errorString: String
                        if let error = exportSession.error {
                            errorString = "导出失败：" + error.localizedDescription
                        }else {
                            errorString = "导出失败，未知原因"
                        }
                        self.completionHandler?(.failure(EditorError.error(
                            type: exportSession.status == .cancelled ? .cancelled : .exportFailed,
                            message: errorString
                        )))
                    default: break
                    }
                }
            })
            
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
                self?.progressHandler?(CGFloat(exportSession.progress))
            })
            self.exportSession = exportSession
        } catch {
            completionHandler?(.failure(EditorError.error(type: .exportFailed, message: "导出失败：" + error.localizedDescription)))
        }
    }
    
    lazy var mixComposition: AVMutableComposition = {
        let mixComposition = AVMutableComposition()
        return mixComposition
    }()
    
    func insertVideoTrack(for videoTrack: AVAssetTrack) throws {
        let videoTimeRange = CMTimeRangeMake(
            start: .zero,
            duration: videoTrack.timeRange.duration
        )
        let compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
        try compositionVideoTrack?.insertTimeRange(
            videoTimeRange,
            of: videoTrack,
            at: .zero
        )
        adjustVideoOrientation()
        let renderSize = videoComposition.renderSize
        cropSize()
        videoComposition.customVideoCompositorClass = EditorVideoCompositor.self
        let watermarkLayerTrackID = addWatermark(renderSize: renderSize)
        
        var newInstructions: [AVVideoCompositionInstructionProtocol] = []
        for instruction in videoComposition.instructions where instruction is AVVideoCompositionInstruction {
            let videoInstruction = instruction as! AVVideoCompositionInstruction
            let layerInstructions = videoInstruction.layerInstructions
            var sourceTrackIDs: [NSValue] = []
            for layerInstruction in layerInstructions {
                sourceTrackIDs.append(layerInstruction.trackID as NSValue)
            }
            let newInstruction = VideoCompositionInstruction(
                sourceTrackIDs: sourceTrackIDs,
                watermarkTrackID: watermarkLayerTrackID,
                timeRange: instruction.timeRange,
                videoOrientation: avAsset.videoOrientation,
                watermark: watermark,
                cropFactor: cropFactor,
                maskType: maskType
            )
            newInstructions.append(newInstruction)
        }
        if newInstructions.isEmpty {
            var sourceTrackIDs: [NSValue] = []
            sourceTrackIDs.append(videoTrack.trackID as NSValue)
            let newInstruction = VideoCompositionInstruction(
                sourceTrackIDs: sourceTrackIDs,
                watermarkTrackID: watermarkLayerTrackID,
                timeRange: videoTrack.timeRange,
                videoOrientation: avAsset.videoOrientation,
                watermark: watermark,
                cropFactor: cropFactor,
                maskType: maskType
            )
            newInstructions.append(newInstruction)
        }
        
        videoComposition.instructions = newInstructions
        videoComposition.renderScale = 1
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: videoTrack.timeRange.duration.timescale)
    }
    
    func cropSize() {
        if !cropFactor.isClip {
            return
        }
        let width = videoComposition.renderSize.width * cropFactor.sizeRatio.x
        let height = videoComposition.renderSize.height * cropFactor.sizeRatio.y
        videoComposition.renderSize = .init(width: width, height: height)
    }
    
    func addWatermark(
        renderSize: CGSize
    ) -> CMPersistentTrackID? {
        if watermark.images.isEmpty && watermark.layers.isEmpty {
            return nil
        }
        let overlaySize = videoComposition.renderSize
        let bounds = CGRect(origin: .zero, size: renderSize)
        let overlaylayer = CALayer()
        let bgLayer = CALayer()
        for layer in watermark.layers {
            if let image = layer.convertedToImage() {
                layer.contents = nil
                let drawLayer = CALayer()
                drawLayer.contents = image.cgImage
                drawLayer.frame = bounds
                drawLayer.contentsScale = UIScreen.main.scale
                bgLayer.addSublayer(drawLayer)
            }
        }
        for image in watermark.images {
            let drawLayer = CALayer()
            drawLayer.contents = image.cgImage
            drawLayer.frame = bounds
            drawLayer.contentsScale = UIScreen.main.scale
            bgLayer.addSublayer(drawLayer)
        }
        if cropFactor.isClip {
            let mirrorLayer = CALayer()
            mirrorLayer.frame = bounds
            overlaylayer.addSublayer(mirrorLayer)
            let rotateLayer = CALayer()
            rotateLayer.frame = bounds
            mirrorLayer.addSublayer(rotateLayer)
            
            let contentLayer = CALayer()
            let width = renderSize.width * cropFactor.sizeRatio.x
            let height = renderSize.height * cropFactor.sizeRatio.y
            let centerX = renderSize.width * cropFactor.centerRatio.x
            let centerY = renderSize.height * cropFactor.centerRatio.x
            let x = centerX - width / 2
            let y = centerY - height / 2
            bgLayer.frame = .init(
                x: -x, y: -y,
                width: bounds.width, height: bounds.height
            )
            contentLayer.addSublayer(bgLayer)
            contentLayer.frame = .init(
                x: -(width - overlaySize.width) * 0.5,
                y: -(height - overlaySize.height) * 0.5,
                width: width, height: height
            )
            rotateLayer.addSublayer(contentLayer)
            
            mirrorLayer.transform = CATransform3DMakeScale(cropFactor.mirrorScale.x, cropFactor.mirrorScale.y, 1)
            rotateLayer.transform = CATransform3DMakeRotation(cropFactor.angle.radians, 0, 0, 1)
        }else {
            bgLayer.frame = bounds
            overlaylayer.addSublayer(bgLayer)
        }
        overlaylayer.isGeometryFlipped = true
        overlaylayer.frame = .init(origin: .zero, size: overlaySize)
        
        let trackID = avAsset.unusedTrackID()
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            additionalLayer: overlaylayer,
            asTrackID: trackID
        )
        return trackID
    }
    
    func insertAudioTrack(
        duration: CMTime,
        timeRang: CMTimeRange,
        audioTracks: [AVAssetTrack]
    ) throws {
        let videoTimeRange = CMTimeRangeMake(
            start: .zero,
            duration: duration
        )
        var audioInputParams: [AVMutableAudioMixInputParameters] = []
        
        for audioTrack in audioTracks {
            guard let track = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                continue
            }
            track.preferredTransform = audioTrack.preferredTransform
            try track.insertTimeRange(videoTimeRange, of: audioTrack, at: .zero)
            let audioInputParam = AVMutableAudioMixInputParameters(track: track)
            audioInputParam.setVolumeRamp(fromStartVolume: factor.volume, toEndVolume: factor.volume, timeRange: .init(start: .zero, duration: duration))
            audioInputParam.trackID = track.trackID
            audioInputParams.append(audioInputParam)
        }
        
        for audio in factor.audios {
            guard let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                continue
            }
            let audioAsset = AVURLAsset(url: audio.url)
            let tracks = audioAsset.tracks(withMediaType: .audio)
            let audioDuration = audioAsset.duration.seconds
            for track in tracks {
                audioTrack.preferredTransform = track.preferredTransform
                let videoDuration: Double
                let startTime: Double
                if timeRang == .zero {
                    startTime = 0
                    videoDuration = duration.seconds
                }else {
                    startTime = timeRang.start.seconds
                    videoDuration = timeRang.duration.seconds
                }
                if audioDuration < videoDuration {
                    let audioTimeRange = CMTimeRangeMake(
                        start: .zero,
                        duration: track.timeRange.duration
                    )
                    let divisor = Int(videoDuration / audioDuration)
                    var atTime = CMTimeMakeWithSeconds(
                        startTime,
                        preferredTimescale: audioAsset.duration.timescale
                    )
                    for index in 0..<divisor {
                        try audioTrack.insertTimeRange(
                            audioTimeRange,
                            of: track,
                            at: atTime
                        )
                        atTime = CMTimeMakeWithSeconds(
                            startTime + Double(index + 1) * audioDuration,
                            preferredTimescale: audioAsset.duration.timescale
                        )
                    }
                    let remainder = videoDuration.truncatingRemainder(
                        dividingBy: audioDuration
                    )
                    if remainder > 0 {
                        let seconds = videoDuration - audioDuration * Double(divisor)
                        try audioTrack.insertTimeRange(
                            CMTimeRange(
                                start: .zero,
                                duration: CMTimeMakeWithSeconds(
                                    seconds,
                                    preferredTimescale: audioAsset.duration.timescale
                                )
                            ),
                            of: track,
                            at: atTime
                        )
                    }
                }else {
                    let audioTimeRange: CMTimeRange
                    let atTime: CMTime
                    if timeRang != .zero {
                        audioTimeRange = CMTimeRangeMake(
                            start: .zero,
                            duration: timeRang.duration
                        )
                        atTime = timeRang.start
                    }else {
                        audioTimeRange = CMTimeRangeMake(
                            start: .zero,
                            duration: videoTimeRange.duration
                        )
                        atTime = .zero
                    }
                    try audioTrack.insertTimeRange(
                        audioTimeRange,
                        of: track,
                        at: atTime
                    )
                }
            }
            let audioInputParam = AVMutableAudioMixInputParameters.init(track: audioTrack)
            audioInputParam.setVolumeRamp(fromStartVolume: audio.volume, toEndVolume: audio.volume, timeRange: .init(start: .zero, duration: duration))
            audioInputParam.trackID = audioTrack.trackID
            audioInputParams.append(audioInputParam)
        }
        audioMix.inputParameters = audioInputParams
    }
    
    func fileLengthLimit(
        seconds: Double,
        maxSize: Int? = nil
    ) -> Int64 {
        if factor.quality > 0 {
            let quality = Double(min(factor.quality, 10))
            if let maxSize = maxSize {
                return Int64(Double(maxSize) * (quality / 10))
            }
            var ratioParam: Double = 0
            if factor.preset == .ratio_640x480 {
                ratioParam = 0.02
            }else if factor.preset == .ratio_960x540 {
                ratioParam = 0.04
            }else if factor.preset == .ratio_1280x720 {
                ratioParam = 0.08
            }
            return Int64(seconds * ratioParam * quality * 1000 * 1000)
        }
        return 0
    }
    
    lazy var videoComposition: AVMutableVideoComposition = {
        let videoComposition = AVMutableVideoComposition(propertiesOf: mixComposition)
        return videoComposition
    }()
    
    func adjustVideoOrientation() {
        let assetOrientation = avAsset.videoOrientation
        guard assetOrientation != .landscapeRight else {
            return
        }
        guard let videoTrack = mixComposition.tracks(withMediaType: .video).first else {
            return
        }
        let naturalSize = videoTrack.naturalSize
        if assetOrientation == .portrait {
            videoComposition.renderSize = CGSize(width: naturalSize.height, height: naturalSize.width)
        } else if assetOrientation == .landscapeLeft {
            videoComposition.renderSize = CGSize(width: naturalSize.width, height: naturalSize.height)
        } else if assetOrientation == .portraitUpsideDown {
            videoComposition.renderSize = CGSize(width: naturalSize.height, height: naturalSize.width)
        }
    }
    
    lazy var audioMix: AVMutableAudioMix = {
        let audioMix = AVMutableAudioMix()
        return audioMix
    }()
}

