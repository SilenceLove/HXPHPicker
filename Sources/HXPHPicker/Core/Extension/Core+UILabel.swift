//
//  Core+UILabel.swift
//  HXPHPicker
//
//  Created by Slience on 2021/10/22.
//

import UIKit

extension UILabel {
    var textHeight: CGFloat {
        text?.height(ofFont: font, maxWidth: width > 0 ? width : CGFloat(MAXFLOAT)) ?? 0
    }
}
