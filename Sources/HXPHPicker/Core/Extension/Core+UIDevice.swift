//
//  Core+UIDevice.swift
//  HXPHPickerExample
//
//  Created by Silence on 2020/11/13.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

extension UIDevice {
    class var isPortrait: Bool {
        if isPad {
            return true
        }
        if  statusBarOrientation == .landscapeLeft ||
                statusBarOrientation == .landscapeRight {
            return false
        }
        return true
    }
    class var statusBarOrientation: UIInterfaceOrientation {
        UIApplication.shared.statusBarOrientation
    }
    class var navigationBarHeight: CGFloat {
        if isPad {
            if #available(iOS 12, *) {
                return statusBarHeight + 50
            }
        }
        return statusBarHeight + 44
    }
    class var generalStatusBarHeight: CGFloat {
        isAllIPhoneX ? 44 : 20
    }
    class var statusBarHeight: CGFloat {
        let statusBarHeight: CGFloat
        let window = UIApplication.shared.windows.first
        if #available(iOS 13.0, *),
           let height = window?.windowScene?.statusBarManager?.statusBarFrame.size.height {
            statusBarHeight = height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        return statusBarHeight
    }
    class var topMargin: CGFloat {
        if isAllIPhoneX {
            return statusBarHeight
        }
        return safeAreaInsets.top
    }
    class var leftMargin: CGFloat {
        safeAreaInsets.left
    }
    class var rightMargin: CGFloat {
        safeAreaInsets.right
    }
    class var bottomMargin: CGFloat {
        safeAreaInsets.bottom
    }
    class var isPad: Bool {
        current.userInterfaceIdiom == .pad
    }
    class var isAllIPhoneX: Bool {
        let safeArea = safeAreaInsets
        let margin: CGFloat
        if isPortrait {
            margin = safeArea.bottom
        }else {
            margin = safeArea.left
        }
        return margin != 0
    }
    
    class var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication._keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    class var belowIphone7: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror
            .children.reduce("") { identifier, element in
                guard let value = element.value as? Int8,
                      value != 0 else {
                    return identifier
                }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        switch identifier {
        case "iPhone1,1":
            return true
        case "iPhone1,2":
            return true
        case "iPhone2,1":
            return true
        case "iPhone3,1":
            return true
        case "iPhone4,1":
            return true
        case "iPhone5,1":
            return true
        case "iPhone5,2":
            return true
        case "iPhone5,3":
            return true
        case "iPhone5,4":
            return true
        case "iPhone6,1":
            return true
        case "iPhone6,2":
            return true
        case "iPhone7,1":
            return true
        case "iPhone7,2":
            return true
        case "iPhone8,1":
            return true
        case "iPhone8,2":
            return true
        case "iPhone8,4":
            return true
        default:
            return false
        }
    }
}
