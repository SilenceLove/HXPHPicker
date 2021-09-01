//
//  CameraControllerProtocol.swift
//  HXPHPicker
//
//  Created by Slience on 2021/8/31.
//

import Foundation
import CoreLocation

public protocol CameraControllerDelegate: AnyObject {
    
    /// 拍照完成
    /// - Parameters:
    ///   - cameraController: 对应的 CameraController
    ///   - image: 照片
    ///   - locatoin: 定位信息
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithImage image: UIImage,
        location: CLLocation?
    )
    
    /// 录制完成
    /// - Parameters:
    ///   - cameraController: 对应的 CameraController
    ///   - videoURL: 视频地址
    ///   - locatoin: 定位信息
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithVideo videoURL: URL,
        location: CLLocation?
    )
    
    /// 取消拍摄
    /// - Parameter cameraController: 对应的 CameraController
    func cameraController(didCancel cameraController: CameraController)
}

public extension CameraControllerDelegate {
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithImage image: UIImage,
        location: CLLocation?
    ) {
        if !cameraController.autoDismiss {
            cameraController.dismiss(animated: true)
        }
    }
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithVideo videoURL: URL,
        location: CLLocation?
    ) {
        if !cameraController.autoDismiss {
            cameraController.dismiss(animated: true)
        }
    }
    func cameraController(didCancel cameraController: CameraController) {
        if !cameraController.autoDismiss {
            cameraController.dismiss(animated: true)
        }
    }
}

public protocol CameraViewControllerDelegate: AnyObject {
    
    /// 拍照完成
    /// - Parameters:
    ///   - cameraViewController: 对应的 CameraViewController
    ///   - image: 照片
    ///   - locatoin: 定位信息
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithImage image: UIImage,
        location: CLLocation?
    )
    
    /// 录制完成
    /// - Parameters:
    ///   - cameraViewController: 对应的 CameraViewController
    ///   - videoURL: 视频地址
    ///   - locatoin: 定位信息
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithVideo videoURL: URL,
        location: CLLocation?
    )
    
    /// 取消拍摄
    /// - Parameter cameraViewController: 对应的 CameraViewController
    func cameraViewController(didCancel cameraViewController: CameraViewController)
}

public extension CameraViewControllerDelegate {
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithImage image: UIImage,
        location: CLLocation?
    ) {
        if !cameraViewController.autoDismiss {
            cameraViewController.dismiss(animated: true)
        }
    }
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithVideo videoURL: URL,
        location: CLLocation?
    ) {
        if !cameraViewController.autoDismiss {
            cameraViewController.dismiss(animated: true)
        }
    }
    func cameraViewController(didCancel cameraViewController: CameraViewController) {
        if !cameraViewController.autoDismiss {
            cameraViewController.dismiss(animated: true)
        }
    }
}

protocol CameraResultViewControllerDelegate: AnyObject {
    func cameraResultViewController(didDone cameraResultViewController: CameraResultViewController)
}
