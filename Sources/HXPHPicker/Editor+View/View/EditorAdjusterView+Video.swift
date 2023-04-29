//
//  EditorAdjusterView+Video.swift
//  HXPHPicker
//
//  Created by Slience on 2023/2/25.
//

import UIKit
import AVFoundation

extension EditorAdjusterView {
    
    var isCropedVideo: Bool {
        let cropRatio = getCropOption()
        let cropFactor = CropFactor(
            drawLayer: contentView.drawView.count > 0 ? contentView.drawView.layer : nil,
            mosaicLayer: nil,
            isCropImage: canReset,
            isRound: isCropRund,
            maskImage: maskImage,
            angle: currentAngle,
            mirrorScale: currentMirrorScale,
            centerRatio: cropRatio.centerRatio,
            sizeRatio: cropRatio.sizeRatio
        )
        return cropFactor.allowCroped
    }
    
    struct LastVideoFator {
        let urlConfig: EditorURLConfig
        let factor: EditorVideoFactor
        let watermarkCount: Int
        let cropFactor: EditorAdjusterView.CropFactor
    }
    
    func cropVideo(
        factor: EditorVideoFactor,
        progress: ((CGFloat) -> Void)? = nil,
        completion: @escaping (Result<EditResult.Video, EditorError>) -> Void
    ) {
        if !DispatchQueue.isMain {
            DispatchQueue.main.async {
                self.cropVideo(
                    factor: factor,
                    progress: progress,
                    completion: completion
                )
            }
            return
        }
        let cropRatio = getCropOption()
        let cropFactor = CropFactor(
            drawLayer: nil,
            mosaicLayer: nil,
            isCropImage: canReset,
            isRound: isCropRund,
            maskImage: maskImage,
            angle: currentAngle,
            mirrorScale: currentMirrorScale,
            centerRatio: cropRatio.centerRatio,
            sizeRatio: cropRatio.sizeRatio
        )
        let urlConfig: EditorURLConfig
        if let _urlConfig = self.urlConfig {
            urlConfig = _urlConfig
        }else {
            let fileName: String
            if let lastVideoFator = lastVideoFator {
                fileName = lastVideoFator.urlConfig.url.lastPathComponent
            }else {
                fileName = .fileName(suffix: "mp4")
            }
            urlConfig = .init(fileName: fileName, type: .temp)
        }
        var isDrawVideoMark = contentView.drawView.isVideoMark
        var layers: [CALayer] = []
        if contentView.drawView.count > 0 {
            contentView.drawView.isVideoMark = true
            layers.append(contentView.drawView.layer)
        }else {
            if let lastVideoFator = lastVideoFator,
               lastVideoFator.watermarkCount > 0 {
                isDrawVideoMark = false
            }else {
                isDrawVideoMark = true
            }
        }
        if let lastVideoFator = lastVideoFator,
           lastVideoFator.urlConfig.url.path == urlConfig.url.path,
           lastVideoFator.factor.isEqual(factor),
           lastVideoFator.cropFactor.isEqual(cropFactor),
           isDrawVideoMark,
           FileManager.default.fileExists(atPath: urlConfig.url.path) {
            completion(.success(.init(urlConfig: urlConfig, data: getData())))
            return
        }else {
            if FileManager.default.fileExists(atPath: urlConfig.url.path) {
                do {
                    try FileManager.default.removeItem(at: urlConfig.url)
                } catch {
                    completion(.failure(EditorError.error(type: .removeFile, message: "删除已经存在的文件时发生错误：\(error.localizedDescription)")))
                    return
                }
            }
        }
        lastVideoFator = .init(
            urlConfig: urlConfig,
            factor: factor,
            watermarkCount: layers.count,
            cropFactor: cropFactor
        )
        exportVideo(
            outputURL: urlConfig.url,
            factor: factor,
            watermark: .init(layers: layers, images: []),
            cropFactor: cropFactor,
            progress: progress
        ) { [weak self] in
            guard let self = self else {
                return
            }
            switch $0 {
            case .success(_):
                completion(.success(.init(
                    urlConfig: urlConfig,
                    data: self.getData()
                )))
            case .failure(let error):
                completion(.failure(error))
            }
            self.videoTool = nil
        }
    }
    
    func exportVideo(
        outputURL: URL,
        factor: EditorVideoFactor,
        watermark: EditorVideoTool.Watermark,
        cropFactor: CropFactor,
        progress: ((CGFloat) -> Void)? = nil,
        completion: @escaping (Result<URL, EditorError>) -> Void
    ) {
        guard let avAsset = contentView.videoView.avAsset else {
            completion(.failure(EditorError.error(type: .exportFailed, message: "视频资源不存在")))
            return
        }
        videoTool?.cancelExport()
        let videoTool = EditorVideoTool.init(
            avAsset: avAsset,
            outputURL: outputURL,
            factor: factor,
            watermark: watermark,
            cropFactor: cropFactor,
            maskType: factor.maskType ?? maskType
        )
        videoTool.export(
            progressHandler: progress,
            completionHandler: completion
        )
        self.videoTool = videoTool
    }
    
    func cancelVideoCroped() {
        videoTool?.cancelExport()
        videoTool = nil
    }
}
