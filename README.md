<h4 align="right"><strong><a href="https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/README_CN.md">中文</a></strong> | English</h4>
      
<p align="center">
    <a><img src="https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/Support/sample_graph_en.png"  width = "396" height = "292.65" ></a>
</p> 
<h1 align="center"><strong><a href="https://github.com/SilenceLove/HXPhotoPicker">Please move to HXPhotoPicker for the latest version</a></strong></h1>
    
<p align="center">
    <a href="https://github.com/SilenceLove/HXPHPicker"><img src="https://badgen.net/badge/icon/iOS%2012.0%2B?color=cyan&icon=apple&label"></a>
    <a href="https://github.com/SilenceLove/HXPHPicker"><img src="http://img.shields.io/cocoapods/v/HXPHPicker.svg?logo=cocoapods&logoColor=ffffff"></a>
    <a href="https://developer.apple.com/Swift"><img src="http://img.shields.io/badge/language-Swift-orange.svg?logo=common-workflow-language"></a>
    <a href="http://mit-license.org"><img src="http://img.shields.io/badge/license-MIT-333333.svg?logo=letterboxd&logoColor=ffffff"></a>
    <div align="center"><a href="https://www.buymeacoffee.com/fengye" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a></div>
    <div align="center">photo/video selector-supports LivePhoto, GIF selection, iCloud resource online download, photo/video editing</div>
</p> 

## <a id="Features"></a> Features

- [x] UI Appearance supports light/dark/auto/custom
- [x] Support multiple selection/mixed content selection
- [x] Supported media types：
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] Supported local media types：
    - [x] Photo
    - [x] Video
    - [x] GIF
    - [x] Live Photo
- [x] Supported network media types：
    - [x] Photo
    - [x] Video
- [x] Support downloading assets on iCloud
- [x] Support gesture back
- [x] Support sliding selection
- [x] Edit pictures (support animated pictures, network pictures)
    - [x] Graffiti
    - [x] Sticker
    - [x] Text
    - [x] Crop
    - [x] Mosaic
    - [x] Filter
- [x] Edit video (support network video)
    - [x] Graffiti
    - [x] Stickers (support GIF)
    - [x] Text
    - [x] Soundtrack (support lyrics and subtitles)
    - [x] Crop duration
    - [x] Crop Size
    - [x] Filter
- [x] Album display mode
    - [x] Separate list
    - [x] Pop-ups
- [x] Multi-platform support
    - [x] iOS
    - [x] iPadOS
- [x] Internationalization support
    - [x] 🇨🇳 Chinese, Simplified (zh-Hans)
    - [x] 🇬🇧 English (en)
    - [x] 🇨🇳 Chinese, traditional (zh-Hant)
    - [x] 🇯🇵 Japanese (ja)
    - [x] 🇰🇷 Korean (ko)
    - [x] 🇹🇭 Thai (th)
    - [x] 🇮🇳 Indonesian (id)
    - [x] 🇻🇳 Vietnamese (vi)
    - [x] 🇷🇺 russian (ru)
    - [x] 🇩🇪 german (de)
    - [x] 🇫🇷 french (fr)
    - [x] 🇸🇦 arabic (ar)
    - [x] ✍️ Custom language (custom)
    - [ ] 🤝 More support... (Pull requests welcome)
    
## <a id="Requirements"></a> Requirements

- iOS 12.0+
- Xcode 12.5+
- Swift 5.4+

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

⚠️ Needs Xcode 12.0+ to support resources and localization files

```swift
dependencies: [
    .package(url: "https://github.com/SilenceLove/HXPHPicker.git", .upToNextMajor(from: "2.0.0"))
]
```

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add this to Podfile, and then update dependency:

```swift

iOS 12.0+
pod 'HXPHPicker'

/// No Kingfisher
pod `HXPHPicker/Lite`

/// Only Picker
pod `HXPHPicker/Picker`
pod `HXPHPicker/Picker/Lite`

/// Only Editor
pod `HXPHPicker/Editor`
pod `HXPHPicker/Editor/Lite`

/// Only Camera
pod `HXPHPicker/Camera`
/// Does not include location functionality
pod `HXPHPicker/Camera/Lite`

iOS 10.0+
pod 'HXPHPicker-Lite'
pod 'HXPHPicker-Lite/Picker'
pod 'HXPHPicker-Lite/Editor'
pod 'HXPHPicker-Lite/Camera'
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the following content to `Cartfile` and perform dependency update.

```swift
github "SilenceLove/HXPHPicker"
```

## Usage

> [Wiki](https://github.com/SilenceLove/HXPHPicker/wiki)

### Prepare

Add these keys to your Info.plist when needed:

| Key | Module | Info |
| ----- | ----  | ---- |
| NSPhotoLibraryUsageDescription | Picker | Allow access to album |
| NSPhotoLibraryAddUsageDescription | Picker | Allow to save pictures to album |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | Picker | Set YES to prevent automatic limited access alert in iOS 14+ (Picker has been adapted with Limited features that can be triggered by the user to enhance the user experience) |
| NSCameraUsageDescription | Camera | Allow camera |
| NSMicrophoneUsageDescription | Camera | Allow microphone |

### Quick Start
```swift
import HXPHPicker

class ViewController: UIViewController {

    func presentPickerController() {
        // Set the configuration consistent with the WeChat theme
        let config = PickerConfiguration.default
        
        // Method 1：
        let pickerController = PhotoPickerController(picker: config)
        pickerController.pickerDelegate = self
        // The array of PhotoAsset objects corresponding to the currently selected asset
        pickerController.selectedAssetArray = selectedAssets 
        // Whether to select the original image
        pickerController.isOriginal = isOriginal
        present(pickerController, animated: true, completion: nil)
        
        // Method 2：
        Photo.picker(
            config
        ) { result, pickerController in
            // Select completion callback
            // result Select result
            //  .photoAssets Currently selected data
            //  .isOriginal Whether the original image is selected
            // photoPickerController Corresponding photo selection controller
        } cancel: { pickerController in
            // Cancelled callback
            // photoPickerController Corresponding photo selection controller
        }
    }
}

extension ViewController: PhotoPickerControllerDelegate {
    
    /// Called after the selection is complete
    /// - Parameters:
    ///   - pickerController: corresponding PhotoPickerController
    ///   - result: Selected result
    ///     result.photoAssets  Selected asset array
    ///     result.isOriginal   Whether to select the original image
    func pickerController(_ pickerController: PhotoPickerController, 
                            didFinishSelection result: PickerResult) {
        result.getImage { (image, photoAsset, index) in
            if let image = image {
                print("success", image)
            }else {
                print("failed")
            }
        } completionHandler: { (images) in
            print(images)
        }
    }
    
    /// Called when cancel is clicked
    /// - Parameter pickerController: Corresponding PhotoPickerController
    func pickerController(didCancel pickerController: PhotoPickerController) {
        
    }
}
```

### Get Content

#### Get UIImage

```swift
/// If it is a video, get the cover of the video
/// compressionQuality: Compress parameters, if not passed, no compression
photoAsset.getImage(compressionQuality: compressionQuality) { image in
    print(image)
}
```

#### Get URL

```swift
/// compression: Compress parameters, if not passed, no compression
photoAsset.getURL(compression: compression) { result in
    switch result {
    case .success(let urlResult): 
        
        switch urlResult.mediaType {
        case .photo:
        
        case .video:
        
        }
        
        switch urlResult.urlType {
        case .local:
        
        case .network:
        
        }
        
        print(urlResult.url)
        
        // Image and video urls contained in LivePhoto
        print(urlResult.livePhoto) 
        
    case .failure(let error):
        print(error)
    }
}
```

## Release Notes

| Version | Release Date | Xcode | Swift | iOS |
| ---- | ----  | ---- | ---- | ---- |
| [v2.0.0](https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/RELEASE_NOTE.md#200) | 2023-06-14 | 14.3.0 | 5.7.0 | 12.0+ |
| [v1.4.6](https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/RELEASE_NOTE.md#146) | 2022-11-20 | 14.0.0 | 5.7.0 | 12.0+ |

## License

HXPHPicker is released under the MIT license. See LICENSE for details.

## Support
* [**★ Star**](#) this repo.
* Support with 
<p/>
<a href="https://www.buymeacoffee.com/fengye" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a><p/>
<img src="https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/Support/bmc_qr.png" width = "135" height = "135" /><p/>
<img src="https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/Support/ap.jpeg" width = "100" height = "135.75" /> 
or
 <img src="https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/Support/wp.jpeg" width = "100" height = "135.75" />

## Stargazers over time

[![Stargazers over time](https://starchart.cc/SilenceLove/HXPHPicker.svg)](https://starchart.cc/SilenceLove/HXPHPicker)

[🔝](#readme) 
