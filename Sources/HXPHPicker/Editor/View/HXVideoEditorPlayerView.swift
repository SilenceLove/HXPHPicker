//
//  HXVideoEditorPlayerView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit
import AVKit

protocol HXVideoEditorPlayerViewDelegate: NSObjectProtocol {
    func playerView(_ playerView: HXVideoEditorPlayerView, didPlayAt time: CMTime)
    func playerView(_ playerView: HXVideoEditorPlayerView, didPauseAt time: CMTime)
}

class HXVideoEditorPlayerView: HXPHVideoPlayerView {
    weak var delegate: HXVideoEditorPlayerViewDelegate?
    var playbackTimeObserver: Any?
    var playStartTime: CMTime?
    var playEndTime: CMTime?
    var isPlaying: Bool = false
    var shouldPlay = true
    
    convenience init(videoURL: URL) {
        self.init(avAsset: AVAsset.init(url: videoURL))
    }
    
    init(avAsset: AVAsset) {
        super.init()
        self.avAsset = avAsset
        let playerItem = AVPlayerItem.init(asset: avAsset)
        player.replaceCurrentItem(with: playerItem)
        playerLayer.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTimeNotification(notifi:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: [.new, .old], context: nil)
    }
    @objc func appDidEnterBackground() {
        pause()
    }
    @objc  func appDidEnterPlayGround() {
        play()
    }
    @objc func playerItemDidPlayToEndTimeNotification(notifi: Notification) {
        resetPlay()
    }
    func seek(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { (isFinished) in
            comletion?(isFinished)
        }
    }
    func pause() {
        if isPlaying {
            player.pause()
            isPlaying = false
            delegate?.playerView(self, didPauseAt: player.currentTime())
        }
    }
    func play() {
        if !isPlaying {
            player.play()
            isPlaying = true
            delegate?.playerView(self, didPlayAt: player.currentTime())
        }
    }
    func resetPlay() {
        isPlaying = false
        if let startTime = playStartTime {
            seek(to: startTime) { (isFinished) in
                if isFinished {
                    self.play()
                }
            }
        }else {
            seek(to: CMTime.init(value: 0, timescale: 1)) { (isFinished) in
                if isFinished {
                    self.play()
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerLayer && keyPath == "readyForDisplay" {
            if object as? AVPlayerLayer != playerLayer {
                return
            }
            play()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
        NotificationCenter.default.removeObserver(self)
    }
}
