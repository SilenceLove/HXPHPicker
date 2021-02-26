//
//  PhotoEditorController.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit

open class PhotoEditorController: UINavigationController {
    
    var config: EditorConfiguration = .init()
    
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    
}
