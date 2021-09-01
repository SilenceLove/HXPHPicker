//
//  CameraController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/30.
//

import UIKit
import CoreLocation

open class CameraController: UINavigationController {
    
    public enum CameraType {
        case photo
        case video
        case all
    }
    
    public weak var cameraDelegate: CameraControllerDelegate?
    
    /// 自动dismiss
    public var autoDismiss: Bool = true {
        didSet {
            let vc = viewControllers.first as? CameraViewController
            vc?.autoDismiss = autoDismiss
        }
    }
    public let config: CameraConfiguration
    /// 相机初始化
    /// - Parameters:
    ///   - config: 相机配置
    ///   - type: 相机类型
    ///   - delegate: 相机代理
    public init(
        config: CameraConfiguration,
        type: CameraType,
        delegate: CameraControllerDelegate? = nil
    ) {
        self.config = config
        cameraDelegate = delegate
        super.init(nibName: nil, bundle: nil)
        let cameraVC = CameraViewController(
            config: config,
            type: type,
            delegate: self
        )
        viewControllers = [cameraVC]
    }
    
    open override var prefersStatusBarHidden: Bool {
        config.prefersStatusBarHidden
    }
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraController: CameraViewControllerDelegate {
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithImage image: UIImage,
        location: CLLocation?
    ) {
        cameraDelegate?.cameraController(
            self,
            didFinishWithImage: image,
            location: location
        )
    }
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithVideo videoURL: URL,
        location: CLLocation?
    ) {
        cameraDelegate?.cameraController(
            self,
            didFinishWithVideo: videoURL,
            location: location
        )
    }
    public func cameraViewController(didCancel cameraViewController: CameraViewController) {
        cameraDelegate?.cameraController(didCancel: self)
    }
}
