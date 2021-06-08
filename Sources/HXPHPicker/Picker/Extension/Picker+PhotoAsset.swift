//
//  Picker+PhotoAsset.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/8.
//

import UIKit

extension PhotoAsset {
    
    func checkAdjustmentStatus(completion: @escaping (Bool, PhotoAsset) -> Void) {
        #if HXPICKER_ENABLE_EDITOR
        if photoEdit != nil || videoEdit != nil {
            completion(false, self)
            return
        }
        #endif
        if let asset = self.phAsset {
            asset.checkAdjustmentStatus { (isAdjusted) in
                completion(isAdjusted, self)
            }
            return
        }
        completion(false, self)
    }
}
