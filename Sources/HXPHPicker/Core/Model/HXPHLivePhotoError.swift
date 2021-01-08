//
//  HXPHLivePhotoError.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/7.
//

import Foundation

public enum HXPHLivePhotoError {
    case imageError(Error?)
    case videoError(Error?)
    case allError(Error?, Error?)
}
