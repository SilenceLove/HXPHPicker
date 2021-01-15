# HXPHPicker
<p align="left">
<a href="https://github.com/SilenceLove/HXPHPicker"><img src="https://badgen.net/badge/icon/iOS%209.0%2B?color=cyan&icon=apple&label"></a>
<a href="https://github.com/SilenceLove/HXPHPicker"><img src="http://img.shields.io/cocoapods/v/HXPHPicker.svg?logo=cocoapods&logoColor=ffffff"></a>
<a href="https://developer.apple.com/Swift"><img src="http://img.shields.io/badge/language-Swift-orange.svg?logo=common-workflow-language"></a>
<a href="http://mit-license.org"><img src="http://img.shields.io/badge/license-MIT-333333.svg?logo=letterboxd&logoColor=ffffff"></a>
</p>

## <a id="功能"></a> 功能

- [x] UI 外观支持浅色/深色/自动/自定义
- [x] 支持多选/混合内容选择
- [x] 支持的媒体类型：
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] 支持本地资源
- [x] 在线下载iCloud上的资源
- [x] 两种相册展现方式（单独列表、弹窗）
- [x] 支持手势返回
- [x] 支持滑动选择

## <a id="要求"></a> 要求

- iOS 9.0+
- Xcode 12.0+
- Swift 5.3+

## 安装

### [Swift Package Manager](https://swift.org/package-manager/)

⚠️ 需要 Xcode 12.0 及以上版本来支持资源文件/本地化文件的添加。

```swift
dependencies: [
    .package(url: "https://github.com/SilenceLove/HXPHPicker.git", .upToNextMajor(from: "1.0.2"))
]
```

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

将下面内容添加到 `Podfile`，并执行依赖更新。

```swift
pod 'HXPHPicker'
```

### [Carthage](https://github.com/Carthage/Carthage)

将下面内容添加到 `Cartfile`，并执行依赖更新。

```swift
github "SilenceLove/HXPHPicker"
```

## 使用方法

### 准备工作

按需在你的 Info.plist 中添加以下键值:

| Key | 备注 |
| ----- | ---- |
| NSPhotoLibraryUsageDescription | 允许访问相册 |
| NSPhotoLibraryAddUsageDescription | 允许保存图片至相册 |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | 设置为 `YES` iOS 14+ 以禁用自动弹出添加更多照片的弹框(已适配 Limited 功能，可由用户主动触发，提升用户体验)|
| NSCameraUsageDescription | 允许使用相机 |
| NSMicrophoneUsageDescription | 允许使用麦克风 |

### 快速上手
```swift
import HXPHPicker

class ViewController: UIViewController {

    func presentPickerController() {
        // 设置与微信主题一致的配置
        let config = PhotoTools.getWXPickerConfig()
        let pickerController = PhotoPickerController.init(picker: config)
        pickerController.pickerControllerDelegate = self
        // 当前被选择的资源对应的 PhotoAsset 对象数组
        pickerController.selectedAssetArray = selectedAssets 
        // 是否选中原图
        pickerController.isOriginal = isOriginal
        present(pickerController, animated: true, completion: nil)
    }
}

extension ViewController: PhotoPickerControllerDelegate {
    
    /// 选择完成之后调用，单选模式下不会触发此回调
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - selectedAssetArray: 选择的资源对应的 PhotoAsset 数据
    ///   - isOriginal: 是否选中的原图
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection selectedAssetArray: [PhotoAsset], _ isOriginal: Bool) {
        self.selectedAssets = selectedAssetArray
        self.isOriginal = isOriginal
    }
    
    
    /// 单选完成之后调用
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    ///   - isOriginal: 是否选中的原图
    func pickerController(_ pickerController: PhotoPickerController, singleFinishSelection photoAsset:PhotoAsset, _ isOriginal: Bool) {
        self.selectedAssets = [photoAsset]
        self.isOriginal = isOriginal
    }
    
    /// 点击取消时调用
    /// - Parameter pickerController: 对应的 PhotoPickerController
    func pickerController(didCancel pickerController: PhotoPickerController) {
        
    }
    
    /// dismiss后调用
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - localCameraAssetArray: 相机拍摄存在本地的 PhotoAsset 数据
    ///     可以在下次进入选择时赋值给localCameraAssetArray，列表则会显示
    func pickerController(_ pickerController: PhotoPickerController, didDismissComplete localCameraAssetArray: [PhotoAsset]) {
        
    }
}
```

## 更新日志

| 版本 | 发布时间 | Xcode | Swift | iOS |
| ---- | ----  | ---- | ---- | ---- |
| [v1.0.2](https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/RELEASE_NOTE.md#102) | 2021-01-11 | 12.2 | 5.3 | 9.0+ |
| [v1.0.1](https://github.com/SilenceLove/HXPHPicker/blob/main/Documentation/RELEASE_NOTE.md#101) | 2021-01-08 | 12.2 | 5.3 | 9.0+ |

## 版权协议

HXPHPicker 基于 MIT 协议进行分发和使用，更多信息参见[协议文件](./LICENSE)。
