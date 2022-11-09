//
//  EditorView+Public.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import AVFoundation

public extension EditorView {
    
    func setImage(_ image: UIImage?) {
        adjusterView.setImage(image)
        updateContentSize()
    }
    
    func setImageData(_ imageData: Data?) {
        adjusterView.setImageData(imageData)
        updateContentSize()
    }
    
    func setAVAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        adjusterView.setAVAsset(avAsset, coverImage: coverImage)
        updateContentSize()
    }
}

public extension EditorView {
    
    func updateImage(_ image: UIImage?) {
        
    }
    
    func updateImageData(_ imageData: Data?) {
        
    }
}
