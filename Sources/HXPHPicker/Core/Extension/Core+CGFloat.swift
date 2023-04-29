//
//  Core+CGFloat.swift
//  HXPHPicker
//
//  Created by Slience on 2023/1/31.
//

import Foundation

extension CGFloat {
    var compressionQuality: CGFloat {
        if self > 30000000 {
            return 30000000 / self
        }else if self > 15000000 {
            return 10000000 / self
        }else if self > 10000000 {
            return 6000000 / self
        }else {
            return 3000000 / self
        }
    }
}
