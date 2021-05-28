//
//  Picker+URL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/27.
//

import Foundation

extension URL {
    var isGif: Bool {
        lastPathComponent.hasSuffix("gif") || lastPathComponent.hasSuffix("GIF")
    }
}
