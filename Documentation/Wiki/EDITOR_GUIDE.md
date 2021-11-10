# Editor 使用说明

本节我们将会详细介绍 `Editor` 中每个配置项的作用，以及一些公开方法。



## 调用/回调说明

`EditorController`有两组初始化方法，分别对应图片编辑器和视频编辑器。

### Photo Editor

首先初始化好配置类`PhotoEditorConfiguration`

```swift
/// 根据UIImage初始化
let controller = EditorController(image: image, config: config, delegate: self)
present(controller, animated: true)
```

```swift
/// 根据Data初始化
let controller = EditorController(imageData: imageData, config: config, delegate: self)
present(controller, animated: true) 
```

```swift
/// 编辑网络图片
let controller = EditorController(networkImageURL: url, config: config, delegate: self)
present(controller, animated: true)
```

### Video Editor

首先初始化好配置类`VideoEditorConfiguration`

```swift
/// 编辑本地视频 
let controller = EditorController(videoURL: videoURL, config: config, delegate: self)
present(controller, animated: true)
```

```swift
/// 编辑本地视频 
let controller = EditorController(avAsset: avAsset, config: config, delegate: self)
present(controller, animated: true)
```

```swift
/// 编辑网络视频 
let controller = EditorController(networkVideoURL: url, config: config, delegate: self)
present(controller, animated: true)
```

### Edit PhotoAsset

可以直接编辑`PhotoAsset`

```swift
let controller = EditorController(photoAsset: photoAsset, config: config, delegate: self)
present(controller, animated: true) 
```


### 回调

照片编辑的回调都是通过 ` PhotoEditorViewControllerDelegate` 代理返回的。

```swift
/// 编辑完成
/// - Parameters:
///   - photoEditorViewController: 对应的 PhotoEditorViewController
///   - result: 编辑后的数据
func photoEditorViewController(
    _ photoEditorViewController: PhotoEditorViewController,
    didFinish result: PhotoEditResult
)

/// 点击完成按钮，但是照片未编辑
/// - Parameters:
///   - photoEditorViewController: 对应的 PhotoEditorViewController
func photoEditorViewController(
    didFinishWithUnedited photoEditorViewController: PhotoEditorViewController
)

/// 取消编辑
/// - Parameter photoEditorViewController: 对应的 PhotoEditorViewController
func photoEditorViewController(
    didCancel photoEditorViewController: PhotoEditorViewController
)
```

视频编辑的回调都是通过 ` VideoEditorViewControllerDelegate` 代理返回的。

```swift
/// 编辑完成
/// - Parameters:
///   - videoEditorViewController: 对应的 VideoEditorViewController
///   - result: 编辑后的数据
func videoEditorViewController(
    _ videoEditorViewController: VideoEditorViewController,
    didFinish result: VideoEditResult
)

/// 点击完成按钮，但是视频未编辑
/// - Parameters:
///   - videoEditorViewController: 对应的 VideoEditorViewController
func videoEditorViewController(
    didFinishWithUnedited videoEditorViewController: VideoEditorViewController
)

/// 取消编辑
/// - Parameter videoEditorViewController: 对应的 VideoEditorViewController
func videoEditorViewController(
    didCancel videoEditorViewController: VideoEditorViewController
)
```
