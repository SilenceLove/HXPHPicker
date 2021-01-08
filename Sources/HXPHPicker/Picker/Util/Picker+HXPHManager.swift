//
//  Picker+HXPHManager.swift
//  HXPHPickerExample
//
//  Created by Slience on 2020/12/29.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

extension HXPHManager {
    
    var cameraAlbumLocalIdentifierType : HXPHPickerSelectType? {
        let identifierType = UserDefaults.standard.integer(forKey: HXPHManager.CameraAlbumLocal.identifierType.rawValue)
        return HXPHPickerSelectType(rawValue: identifierType)
    }
    
    var cameraAlbumLocalLanguage : String? {
        let language = UserDefaults.standard.string(forKey: HXPHManager.CameraAlbumLocal.language.rawValue)
        return language
    }
    
    var cameraAlbumLocalIdentifier : String? {
        let identifier = UserDefaults.standard.string(forKey: HXPHManager.CameraAlbumLocal.identifier.rawValue)
        return identifier
    }
    
    /// 获取所有资源集合
    /// - Parameters:
    ///   - showEmptyCollection: 显示空集合
    ///   - completion: 完成回调
    public func fetchAssetCollections(for options: PHFetchOptions, showEmptyCollection: Bool, completion :@escaping ([HXPHAssetCollection])->()) {
        DispatchQueue.global().async {
            var assetCollectionsArray = [HXPHAssetCollection]()
            HXPHAssetManager.enumerateAllAlbums(filterInvalid: true, options: nil) { (collection) in
                let assetCollection = HXPHAssetCollection.init(collection: collection, options: options)
                if showEmptyCollection == false && assetCollection.count == 0 {
                    return
                }
                if collection.isCameraRoll {
                    assetCollectionsArray.insert(assetCollection, at: 0);
                }else {
                    assetCollectionsArray.append(assetCollection)
                }
            }
            DispatchQueue.main.async {
                completion(assetCollectionsArray);
            }
        }
    }
    
    /// 枚举每个相册资源，
    /// - Parameters:
    ///   - showEmptyCollection: 显示空集合
    ///   - usingBlock: HXPHAssetCollection 为nil则代表结束，Bool 是否为相机胶卷
    public func fetchAssetCollections(for options: PHFetchOptions, showEmptyCollection: Bool, usingBlock :@escaping (HXPHAssetCollection?, Bool)->()) {
        HXPHAssetManager.enumerateAllAlbums(filterInvalid: true, options: nil) { (collection) in
            let assetCollection = HXPHAssetCollection.init(collection: collection, options: options)
            if showEmptyCollection == false && assetCollection.count == 0 {
                return
            }
            usingBlock(assetCollection, collection.isCameraRoll);
        }
        usingBlock(nil, false);
    }
    
    /// 获取相机胶卷资源集合
    public func fetchCameraAssetCollection(for type: HXPHPickerSelectType, options: PHFetchOptions, completion :@escaping (HXPHAssetCollection)->()) {
        DispatchQueue.global().async {
            var useLocalIdentifier = false
            let language = Locale.preferredLanguages.first
            if self.cameraAlbumLocalIdentifier != nil {
                if  (self.cameraAlbumLocalIdentifierType == .any ||
                    type == self.cameraAlbumLocalIdentifierType) &&
                    self.cameraAlbumLocalLanguage == language {
                    useLocalIdentifier = true
                }
            }
            let collection : PHAssetCollection?
            if useLocalIdentifier == true {
                let identifiers : [String] = [self.cameraAlbumLocalIdentifier!]
                collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: identifiers, options: nil).firstObject
            }else {
                collection = HXPHAssetManager.fetchCameraRollAlbum(options: nil)
                UserDefaults.standard.set(collection?.localIdentifier, forKey: HXPHManager.CameraAlbumLocal.identifier.rawValue)
                UserDefaults.standard.set(type.rawValue, forKey: HXPHManager.CameraAlbumLocal.identifierType.rawValue)
                UserDefaults.standard.set(language, forKey: HXPHManager.CameraAlbumLocal.language.rawValue)
            }
            let assetCollection = HXPHAssetCollection.init(collection: collection, options: options)
            assetCollection.isCameraRoll = true
            DispatchQueue.main.async {
                completion(assetCollection)
            }
        }
    }
}
