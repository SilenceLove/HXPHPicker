//
//  Core+Data.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/20.
//

import Foundation

extension Data {
    var isGif: Bool {
        get {
            var values = [UInt8](repeating: 0, count: 1)
            copyBytes(to: &values, count: 1)
            if values[0] == 0x47 {
                return true
            }
            return false
        }
    }
}
