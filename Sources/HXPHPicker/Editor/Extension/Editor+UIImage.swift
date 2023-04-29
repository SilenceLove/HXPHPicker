//
//  Editor+UIImage.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/25.
//

import UIKit

extension UIImage {
    var ci_Image: CIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        return CIImage(cgImage: cgImage)
    }
}
