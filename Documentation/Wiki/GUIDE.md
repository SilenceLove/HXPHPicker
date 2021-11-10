## 功能概览

### Picker

- [x] UI 外观支持浅色/深色/自动/自定义
- [x] 支持多选/混合内容选择
- [x] 支持的媒体类型：
    - [x] Photo
    - [x] GIF
    - [x] Live Photo
    - [x] Video
- [x] 支持的本地资源类型：
    - [x] Photo
    - [x] Video
    - [x] GIF
    - [ ] Live Photo
- [x] 支持的网络资源类型：
    - [x] Photo
    - [x] Video
- [x] 支持下载iCloud上的资源
- [x] 支持手势返回
- [x] 支持滑动选择
- [x] 相册展现方式
    - [x] 单独列表
    - [x] 弹窗
- [x] 多平台支持
    - [x] iOS
    - [x] iPadOS

### Editor

- [x] 编辑图片（支持动图、网络资源）
    - [x] 涂鸦
    - [x] 贴纸
    - [x] 文字
    - [x] 裁剪
    - [x] 马赛克
    - [x] 滤镜
- [x] 编辑视频（支持网络资源）
    - [x] 贴纸
    - [x] 文字
    - [x] 配乐
    - [x] 裁剪
- [x] 多平台支持
    - [x] iOS
    - [x] iPadOS
    
### Camera

- [x] 拍摄类型
    - [x] 照片
    - [x] 视频


## 使用方式

### Picker

方法一：
```swift
let config = PickerConfiguration()
Photo.picker(
    config
) { result, pickerController in
    // 选择完成的回调
    // result 选择结果
    //  .photoAssets 当前选择的数据
    //  .isOriginal 是否选中了原图
    // photoPickerController 对应的照片选择控制器
} cancel: { pickerController in
    // 取消的回调
    // photoPickerController 对应的照片选择控制器 
}
```

方法二：
首先我们初始化好选择器并且推出

```swift
let config = PickerConfiguration()
let pickerController = PhotoPickerController.init(picker: config)
pickerController.pickerDelegate = self
present(pickerController, animated: true, completion: nil)
```

接下来要实现`PhotoPickerControllerDelegate`中的两个代理方法

```swift

/// 完成选择
/// - Parameters:
///   - pickerController: 照片选择器
///   - result: 选择的结果
///     result.photoAssets  选择的资源数组
///     result.isOriginal   是否选中原图
func pickerController(_ pickerController: PhotoPickerController, 
                        didFinishSelection result: PickerResult) {
    // 获取已选的图片
    result.getImage { (image, photoAsset, index) in
        // 每个资源获取完成后都会触发
        if let image = image { 
            print("success", image)
        }else {
            print("failed")
        }
    } completionHandler: { (images) in
        // 所有图片都获取完成，进行下一步操作
    }
}

/// 取消选择
/// - Parameter pickerController: 对应的 PhotoPickerController
func pickerController(didCancel pickerController: PhotoPickerController) {
    
}
```

**注意：** 在这两个代理方法中不需要手动`dismiss`控制器，如果需要手动`dismiss`请将选择器的`autoDismiss`属性修改为`false`


### Editor

`EditorController`有两组初始化方法，分别对应图片编辑器和视频编辑器。

### Photo Editor

```swift
let config = PhotoEditorConfiguration()
let controller = EditorController(image: image, config: config)
controller.photoEditorDelegate = self
present(controller, animated: true, completion: nil)
```

图片编辑的回调是通过`PhotoEditorViewControllerDelegate`代理返回的

```Swift

/// 编辑完成
/// - Parameters:
///   - photoEditorViewController: 编辑器
///   - result: 编辑后的数据
func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController,
                               didFinish result: PhotoEditResult) {
    // 处理你的业务逻辑              
}

/// 点击完成按钮，但是照片未编辑
/// - Parameters:
///   - photoEditorViewController: 编辑器
func photoEditorViewController(didFinishWithUnedited photoEditorViewController: PhotoEditorViewController) {
    // 处理你的业务逻辑
}

/// 取消编辑
/// - Parameter photoEditorViewController: 编辑器
func photoEditorViewController(didCancel photoEditorViewController: PhotoEditorViewController) {
    
}
```

### Video Editor

```swift
let config = VideoEditorConfiguration()
let controller = EditorController(videoURL: videoURL, config: config)
controller.videoEditorDelegate = self
present(controller, animated: true, completion: nil)
```

视频编辑的回调是通过`VideoEditorViewControllerDelegate`代理返回的

```swift
/// 编辑完成
/// - Parameters:
///   - videoEditorViewController: 编辑器
///   - result: 编辑后的数据
func videoEditorViewController(_ videoEditorViewController: VideoEditorViewController, didFinish result: VideoEditResult) {
    // 处理你的业务逻辑
}

/// 点击完成按钮，但是视频未编辑
/// - Parameters:
///   - videoEditorViewController: 编辑器
func videoEditorViewController(didFinishWithUnedited videoEditorViewController: VideoEditorViewController) {
    // 处理你的业务逻辑
}

/// 取消编辑
/// - Parameter videoEditorViewController: 编辑器
func videoEditorViewController(didCancel videoEditorViewController: VideoEditorViewController) {

}
```


### Camera

```swift
let config = CameraConfiguration()
CameraController.capture(
    config: config, // 相机配置
    type: .all, // 相机类型
) { result, location in
    // result: 拍摄的结果
    // location: 如果允许定位的情况则会有当前定位信息
    switch result {
    case .image(let image):
        // image: 拍摄的图片
    case .video(let videoURL):
        // videoURL: 录制的视频地址
    }
}
```


## 使用要求

- iOS 12.0+
- Xcode 12.0+
- Swift 5.4+


## 准备工作

按需在你的 Info.plist 中添加以下键值:

| Key | 备注 |
| ----- | ---- |
| NSPhotoLibraryUsageDescription | 允许访问相册 |
| NSPhotoLibraryAddUsageDescription | 允许保存图片至相册 |
| PHPhotoLibraryPreventAutomaticLimitedAccessAlert | 设置为 `YES` iOS 14+ 以禁用自动弹出添加更多照片的弹框(已适配 Limited 功能，可由用户主动触发，提升用户体验)|
| NSCameraUsageDescription | 允许使用相机 |
| NSMicrophoneUsageDescription | 允许使用麦克风 |


## 下一步

[安装说明](https://github.com/SilenceLove/HXPHPicker/wiki/%E5%AE%89%E8%A3%85%E8%AF%B4%E6%98%8E)
