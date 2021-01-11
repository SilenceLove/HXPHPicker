//
//  HXPHVideoPlayerView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import AVKit

open class HXPHVideoPlayerView: UIView {
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    open lazy var player: AVPlayer = {
        let player = AVPlayer.init()
        return player
    }()
    open var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    open var avAsset: AVAsset?
    
    public init() {
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
