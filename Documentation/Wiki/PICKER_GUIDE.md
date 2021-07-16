# Picker 使用说明

本节我们将会详细介绍 `Picker` 中每个配置项的作用，以及一些公开方法。



## 目录

- [调用/回调说明](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E8%B0%83%E7%94%A8%E5%9B%9E%E8%B0%83%E8%AF%B4%E6%98%8E)
  - [完成/取消选择](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%AE%8C%E6%88%90%E5%8F%96%E6%B6%88%E9%80%89%E6%8B%A9)
  - [选择逻辑](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%80%89%E6%8B%A9%E9%80%BB%E8%BE%91)
  - [替换相机](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E7%9B%B8%E6%9C%BA)
  - [替换编辑器](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E7%BC%96%E8%BE%91%E5%99%A8)
  - [替换视频编辑器的配乐界面](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E8%A7%86%E9%A2%91%E7%BC%96%E8%BE%91%E5%99%A8%E7%9A%84%E9%85%8D%E4%B9%90%E7%95%8C%E9%9D%A2)
  - [配置视频编辑器的配乐列表数据](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E8%A7%86%E9%A2%91%E7%BC%96%E8%BE%91%E5%99%A8%E7%9A%84%E9%85%8D%E4%B9%90%E5%88%97%E8%A1%A8%E6%95%B0%E6%8D%AE)
  - [预览界面](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%A2%84%E8%A7%88%E7%95%8C%E9%9D%A2)
  - [单独预览时的自定义转场动画](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%8D%95%E7%8B%AC%E9%A2%84%E8%A7%88%E6%97%B6%E7%9A%84%E8%87%AA%E5%AE%9A%E4%B9%89%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB)
  - [控制器的生命周期](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%8E%A7%E5%88%B6%E5%99%A8%E7%9A%84%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F)
- [配置项说明](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E9%A1%B9%E8%AF%B4%E6%98%8E)
- [公开方法](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%85%AC%E5%BC%80%E6%96%B9%E6%B3%95)
  - [获取原始图片/视频](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E8%8E%B7%E5%8F%96%E5%8E%9F%E5%A7%8B%E5%9B%BE%E7%89%87%E8%A7%86%E9%A2%91)


## 调用/回调说明

首先我们初始化好选择器并且推出

```swift
let config = PickerConfiguration()
let pickerController = PhotoPickerController(picker: config, delegate: self) 
present(pickerController, animated: true, completion: nil)
```

### 完成/取消选择

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

/// dismiss后调用
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - localCameraAssetArray: 相机拍摄存在本地的 PhotoAsset 数据
///     可以在下次进入选择时赋值给localCameraAssetArray，列表则会显示
func pickerController(_ pickerController: PhotoPickerController,
                      didDismissComplete localCameraAssetArray: [PhotoAsset]) {
    // 如果有本地的相机拍摄的数据，可以在下次跳转选择器时继续使用
    self.localCameraAssetArray = localCameraAssetArray
    
    // 下次跳转选择器时
    { 
        let config = PickerConfiguration()
        let pickerController = PhotoPickerController(picker: config, delegate: self) 
        // 传入上次拍摄的数据
        pickerController.localCameraAssetArray = self.localCameraAssetArray
        present(pickerController, animated: true, completion: nil)
    }
}
```

**注意：** 在这两个代理方法中不需要手动`dismiss`控制器，如果需要手动`dismiss`请将选择器的`autoDismiss`属性修改为`false`

### 选择逻辑

```swift
/// 将要点击cell，允许的话点击之后会根据配置的动作进行操作
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应的 PhotoAsset 数据
///   - atIndex: indexPath.item
func pickerController(_ pickerController: PhotoPickerController,
                      shouldClickCell photoAsset: PhotoAsset,
                      atIndex: Int) -> Bool {
    if 不允许点击当前Cell {
        // 处理你的业务逻辑
        return false
    }
    return true
}

/// 将要选择cell 不能选择时需要自己手动弹出提示框
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应的 PhotoAsset 数据
///   - atIndex: 将要添加的索引
func pickerController(_ pickerController: PhotoPickerController,
                      shouldSelectedAsset photoAsset: PhotoAsset,
                      atIndex: Int) -> Bool {
    if 不允许选择当前Cell {
        // 处理你的业务逻辑
        return false
    }
    return true
}

/// 即将选择 cell 时调用
func pickerController(_ pickerController: PhotoPickerController,
                      willSelectAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 处理你的业务逻辑
}

/// 选择了 cell 之后调用
func pickerController(_ pickerController: PhotoPickerController,
                      didSelectAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 处理你的业务逻辑
}

/// 即将取消选择 cell
func pickerController(_ pickerController: PhotoPickerController,
                      willUnselectAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 处理你的业务逻辑
}

/// 取消选择 cell
func pickerController(_ pickerController: PhotoPickerController,
                      didUnselectAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 处理你的业务逻辑
}
```

### 替换相机

```swift
/// 是否能够推出相机界面，点击相机cell时调用
/// 可以跳转其他相机界面然后调用 addedCameraPhotoAsset
func pickerController(shouldPresentCamera pickerController: PhotoPickerController) -> Bool {
    // 推出你的相机界面
    pickerController.present(camerController, animated: true, completion: nil)
    // 当你的相机拍摄完成之后调用 pickerController.addedCameraPhotoAsset()
    {
        // 本地图片 
        let photoAsset = PhotoAsset(localImageAsset: LocalImageAsset) 
        // 本地视频 
        let videoAsset = PhotoAsset(localVideoAsset: LocalVideoAsset)
        // 传入 PhotoAsset 对象
        pickerController.addedCameraPhotoAsset(photoAsset / videoAsset)
    }
    // 拦截内部跳转逻辑
    return false
}
```

### 替换编辑器

```swift

/// 将要编辑 Asset，不允许的话可以自己跳转其他编辑界面
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应的 PhotoAsset 数据
func pickerController(_ pickerController: PhotoPickerController,
                      shouldEditAsset photoAsset: PhotoAsset,
                      atIndex: Int) -> Bool {
    switch photoAsset.mediaType {
    case .photo:
        // 使用你自己的照片编辑器
        pickerController.present(editorController, animated: true, completion: nil)
    case .video:
        // 使用你自己的视频编辑器
        pickerController.present(editorController, animated: true, completion: nil)
    }
    // 当你自己的编辑器编辑完成之后调用 pickerController.addedCameraPhotoAsset()
    {
        // 编辑后的图片 
        let photoAsset = PhotoAsset(localImageAsset: LocalImageAsset) 
        // 编辑后的视频 
        let videoAsset = PhotoAsset(localVideoAsset: LocalVideoAsset)
        // 传入 PhotoAsset 对象
        pickerController.addedCameraPhotoAsset(photoAsset / videoAsset)
    }
    // 不使用自带的编辑器
    return false
}

/// Asset 编辑完后调用
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应的 PhotoAsset 数据
///   - atIndex: 对应的下标
func pickerController(_ pickerController: PhotoPickerController,
                      didEditAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 自带的编辑器编辑完成后
}
```

### 替换视频编辑器的配乐界面

```swift
/// 视频编辑器，将要点击工具栏音乐按钮
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - videoEditorViewController: 对应的 VideoEditorViewController
func pickerController(_ pickerController: PhotoPickerController,
                      videoEditorShouldClickMusicTool videoEditorViewController: VideoEditorViewController) -> Bool {
    // 跳转之前先将 viewDidDisappearCancelDownload 设置为 false，防止网络视频还未下载完就停止下载了
    videoEditorViewController.viewDidDisappearCancelDownload = false
    // 停止其他操作(暂停播放视频、停止播放配乐)
    videoEditorViewController.stopAllOperations()
    // 跳转你自己的配乐界面
    videoEditorViewController.present(controller, animated: true, completion: nil)
    // 选择配乐完成后的逻辑
    {
        // 重新播放视频
        videoEditorViewController.playVideo()
        // 如果需要调整视频原声的音量
        videoEditorViewController.videoVolume = 1
        // 传入配乐地址，传nil则为不添加配乐
        videoEditorViewController.backgroundMusicPath = musicPath
        // 关于配乐播放，需要你自己播放
        // 可以使用框架自带的播放音频方法
        PhotoManager.shared.playMusic(filePath: musicPath) {
            // 每次播放完成，内部会循环播放
        }
        // 如果你自己播放配乐的话，需要自行控制配乐暂停播放的时机
    }
    // 不使用自带的配乐界面
    return false
}
```

### 配置视频编辑器的配乐列表数据

```swift
/// 视频编辑器加载配乐信息，当musicConfig.infos为空时触发
/// 返回 true 内部会显示加载状态，调用 completionHandler 后恢复
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - videoEditorViewController: 对应的 VideoEditorViewController
///   - completionHandler: 传入配乐信息
func pickerController(_ pickerController: PhotoPickerController,
                      videoEditor videoEditorViewController: VideoEditorViewController,
                      loadMusic completionHandler: @escaping ([VideoEditorMusicInfo]) -> Void) -> Bool {
    // 传递配乐信息数组
    completionHandler(musicInfos)
    if showLoading {
        // 需要显示加载状态
        return true
    }
    return false
}
```

### 预览界面

```swift
/// 预览界面更新当前显示的资源，collectionView滑动了就会调用
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应显示的 PhotoAsset 数据
///   - index: 对应显示的位置
func pickerController(_ pickerController: PhotoPickerController,
                      previewUpdateCurrentlyDisplayedAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 在外部预览时可以在导航栏上添加一个标签显示数量已经当前是第几张
    if pickerController.isPreviewAsset {
        // 更新标签
        previewTitleLabel?.text = String(atIndex + 1) + "/" + String(selectedAssets.count)
    }
}

/// 预览界面单击操作
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应显示的 PhotoAsset 数据
///   - atIndex: 对应显示的位置
func pickerController(_ pickerController: PhotoPickerController,
                      previewSingleClick photoAsset: PhotoAsset,
                      atIndex: Int) { 
    // 当为外部预览时，单击可以进行返回操作
    if pickerController.isPreviewAsset && photoAsset.mediaType == .photo {
        pickerController.dismiss(animated: true, completion: nil) 
    }
}

/// 预览界面将要删除 Asset
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应被删除的 PhotoAsset 数据
func pickerController(_ pickerController: PhotoPickerController,
                      previewShouldDeleteAsset photoAsset: PhotoAsset,
                      atIndex: Int) -> Bool {
    // 此回调主要针对外部预览，然后调用的 pickerController.deleteCurrentPreviewPhotoAsset()
}

/// 预览界面已经删除了 Asset
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应被删除的 PhotoAsset 数据
///   - atIndex: 资源对应的位置索引
func pickerController(_ pickerController: PhotoPickerController,
                      previewDidDeleteAsset photoAsset: PhotoAsset,
                      atIndex: Int) {
    
}

/// 预览界面网络图片下载成功
func pickerController(_ pickerController: PhotoPickerController,
                      previewNetworkImageDownloadSuccess photoAsset: PhotoAsset,
                      atIndex: Int) {
    
}

/// 预览界面网络图片下载失败
func pickerController(_ pickerController: PhotoPickerController,
                      previewNetworkImageDownloadFailed photoAsset: PhotoAsset,
                      atIndex: Int) {
    
}
```

### 单独预览时的自定义转场动画

```swift
/// present预览时展示的image
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - index: 预览资源对应的位置
func pickerController(_ pickerController: PhotoPickerController,
                      presentPreviewImageForIndexAt index: Int) -> UIImage? {
    // 在present过程中显示的图片
}

/// present 预览时起始的视图，用于获取位置大小。与 presentPreviewFrameForIndexAt 一样
func pickerController(_ pickerController: PhotoPickerController,
                      presentPreviewViewForIndexAt index: Int) -> UIView? {
    // present 起始时的位置对应的视图
}

/// dismiss 结束时对应的视图，用于获取位置大小。与 dismissPreviewFrameForIndexAt 一样
func pickerController(_ pickerController: PhotoPickerController,
                      dismissPreviewViewForIndexAt index: Int) -> UIView? {
    // dismiss 结束时的位置对应的视图
}

/// present 预览时对应的起始位置大小
func pickerController(_ pickerController: PhotoPickerController,
                      presentPreviewFrameForIndexAt index: Int) -> CGRect {
    // present 起始时的位置
}

/// dismiss 结束时对应的位置大小
func pickerController(_ pickerController: PhotoPickerController,
                      dismissPreviewFrameForIndexAt index: Int) -> CGRect {
    // dismiss 结束时的位置
}

/// 外部预览自定义 present 完成
func pickerController(_ pickerController: PhotoPickerController,
                      previewPresentComplete atIndex: Int) {
    // present completion
}

/// 外部预览自定义 dismiss 完成
func pickerController(_ pickerController: PhotoPickerController,
                      previewDismissComplete atIndex: Int) {
    // dismiss completion
}
```

### 控制器的生命周期

```swift
/// 视图控制器即将显示
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - viewController: 对应的控制器 [AlbumViewController, PhotoPickerViewController, PhotoPreviewViewController]
func pickerController(_ pickerController: PhotoPickerController,
                      viewControllersWillAppear viewController: UIViewController) {
    if viewController is AlbumViewController {
        // 相册列表控制器
    }else if viewController is PhotoPickerViewController {
        // 照片列表控制器
    }else if viewController is PhotoPreviewViewController {
        // 预览界面控制器
    }
}

/// 视图控制器已经显示
func pickerController(_ pickerController: PhotoPickerController,
                      viewControllersDidAppear viewController: UIViewController) {
                      
}

/// 视图控制器即将消失
func pickerController(_ pickerController: PhotoPickerController,
                      viewControllersWillDisappear viewController: UIViewController) {
                      
}

/// 视图控制器已经消失
func pickerController(_ pickerController: PhotoPickerController,
                      viewControllersDidDisappear viewController: UIViewController) {
                      
}
```


## 配置项说明

### PickerConfiguration

#### SelectOptions
`selectOptions` 是可选择资源的类型，默认为 `[.photo, .video]`

```swift
struct PickerAssetOptions: OptionSet {
    /// Photo 静态照片
    static let photo = PickerAssetOptions(rawValue: 1 << 0)
    /// Video 视频
    static let video = PickerAssetOptions(rawValue: 1 << 1)
    /// Gif 动图
    static let gifPhoto = PickerAssetOptions(rawValue: 1 << 2)
    /// LivePhoto 实况照片
    static let livePhoto = PickerAssetOptions(rawValue: 1 << 3)
}
```

其中 `GIF` 和 `Live Photo` 都归属于 `Photo` 类别下，属于 `Photo` 的子项。

当设置资源类型为 `Photo` 时，`GIF` 和 `Live Photo` 类型的资源会作为普通图片展示出来。

当设置资源类型为 `Photo + GIF` 时，`GIF` 类型的资源会播放。

当设置资源类型为 `Photo + Live Photo` 时，`Live Photo` 类型的资源长按可以播放视频并拥有特定标识。

#### SelectMode

`selectMode`是资源选择模式，默认为`.multiple`

```swift
enum PickerSelectMode: Int {
    /// 单选模式
    case single = 0
    /// 多选模式
    case multiple = 1
}
```

#### AlbumShowMode

`albumShowMode`是相册展现方式，默认为`.normal`

```swift
enum AlbumShowMode: Int {
    /// 正常展示
    case normal = 0
    /// 弹出展示
    case popup = 1
}
```

#### SelectionTapAction

`photoSelectionTapAction`是在资源列表点击照片资源后的动作，默认为 `.preview`

`videoSelectionTapAction`是在资源列表点击照片资源后的动作，默认为 `.preview`

```swift
enum SelectionTapAction: Equatable {
    /// 进入预览界面
    case preview
    /// 快速选择
    case quickSelect
    /// 打开编辑器
    case openEditor
}
```

当设置为 `preview` 时，点击会打开预览控制器。

当设置为 `quickPick` 时，点击会直接选中该资源。

当设置为 `openEditor` 时，点击会直接打开编辑器。

#### AllowSelectedTogether

`allowSelectedTogether`是否允许照片和视频可以一起选择，默认`true`

#### CreationDate

`creationDate`获取资源列表时是否按创建时间排序，默认`false`

#### ReverseOrder

`reverseOrder`获取资源列表后是否按倒序展示，默认`false`

#### SelectedCount

`maximumSelectedCount`最多可以选择的资源数，如果为0则不限制，默认`9`

`maximumSelectedPhotoCount`最多可以选择的资源数，如果为0则不限制，默认`0`

`maximumSelectedVideoCount`最多可以选择的资源数，如果为0则不限制，默认`0`

#### EditorOptions

`editorOptions`是可编辑资源的类型，默认为 `[.photo, .video]`

```swift
struct PickerAssetOptions: OptionSet {
    /// Photo 静态照片
    static let photo = PickerAssetOptions(rawValue: 1 << 0)
    /// Video 视频
    static let video = PickerAssetOptions(rawValue: 1 << 1)
    /// Gif 动图
    static let gifPhoto = PickerAssetOptions(rawValue: 1 << 2)
    /// LivePhoto 实况照片
    static let livePhoto = PickerAssetOptions(rawValue: 1 << 3)
}
```

其中 `GIF` 和 `Live Photo` 都归属于 `Photo` 类别下，属于 `Photo` 的子项。

**注意：** 当设置为`[]`不能编辑时，预览界面左下角也会出现编辑按钮，只是不可点击。如果想要隐藏编辑按钮需要设置`.previewView.bottomView.editButtonHidden = true`

#### AlbumList

`albumList`是相册列表界面的配置项，类型为`AlbumListConfiguration`

#### PhotoList

`photoList`是照片列表界面的配置项，类型为`PhotoListConfiguration`

#### PreviewView

`previewView`是预览界面的配置项，类型为`PreviewViewConfiguration`

#### NotAuthorized

`notAuthorized`是未授权界面的配置项，类型为`NotAuthorizedConfiguration`

#### Editor

`photoEditor`是`Editor`模块的照片编辑器配置项

`videoEditor`是`Editor`模块的视频编辑器配置项



## 公开方法

### 获取原始图片/视频

在 `Picker` 的回调方法中，我们会将 `PickerResult` 对象返回，在该对象中我们提供了获取原始图片/视频的方法：

```swift
/// 获取已选资源的地址（原图）
/// 包括网络图片
/// - Parameters:
///   - options: 获取的类型
///   - handler: 获取到url的回调 (地址，是否网络资源，对应的位置下标，类型)
///   - completionHandler: 全部获取完成
func getURLs(options: Options = .any,
             urlReceivedHandler handler: @escaping (URL?, Bool, Int, PhotoAsset.MediaType) -> Void,
             completionHandler: @escaping ([URL]) -> Void)
```

#### Sample Code

```swift
func pickerController(_ pickerController: PhotoPickerController, 
                        didFinishSelection result: PickerResult) {
    result.getURLs { (url, isNetwork, index, type) in
        if let url = url {
            switch type {
            case .photo:
                if isNetwork {
                    // url 为网络图片地址
                }else {
                    // url 为本地图片地址
                }
            case .video:
                if isNetwork {
                    // url 为网络视频地址
                }else {
                    // url 为本地视频地址
                }
            }
        }
    } completionHandler: { (urls) in
        // Your code
    }
}
```

在`PhotoAsset`对象中，我们也提供了获取原始图片/视频的方法:

```swift
/// 获取原始图片地址
/// 网络图片获取方法 getNetworkImageURL
/// - Parameters:
///   - fileURL: 指定图片的本地地址
///   - resultHandler: 获取结果
func requestImageURL(toFile fileURL:URL? = nil,
                     resultHandler: @escaping (URL?) -> Void)

/// 获取原始视频地址，系统相册里的视频需要自行压缩
/// 网络视频如果在本地有缓存则会返回本地地址，如果没有缓存则为ni
/// - Parameters:
///   - fileURL: 指定视频地址
///   - exportPreset: 导出质量，不传则获取的是原始视频地址
///   - resultHandler: 获取结果
func requestVideoURL(toFile fileURL:URL? = nil,
                     exportPreset: String? = nil,
                     resultHandler: @escaping (URL?) -> Void)

/// 获取网络图片的地址，编辑过就是本地地址，未编辑就是网络地址
/// - Parameter resultHandler: 图片地址、是否为网络地址
func getNetworkImageURL(resultHandler: @escaping (URL?, Bool) -> Void)

/// 获取网络图片
/// - Parameters:
///   - filterEditor: 过滤编辑的数据
///   - resultHandler: 获取结果
func getNetworkImage(urlType: DonwloadURLType = .original,
                     filterEditor: Bool = false,
                     progressBlock: DownloadProgressBlock? = nil,
                     resultHandler: @escaping (UIImage?) -> Void)

/// 获取网络视频的地址，编辑过就是本地地址，未编辑就是网络地址
/// - Parameter resultHandler: 视频地址、是否为网络地址
func getNetworkVideoURL(resultHandler: @escaping (URL?, Bool) -> Void)
```

#### Sample Code

```swift
func pickerController(_ pickerController: PhotoPickerController,
                        didFinishSelection result: PickerResult) {
    guard let asset = result.photoAssets.first else { return }
    switch asset.mediaType {
    case .photo:
        if asset.isNetworkAsset {
            asset.getNetworkImageURL { url, isNetwork in
                if let imageURL = url {
                    // success
                    if isNetwork {
                        // networkURL
                    }else {
                        // localURL
                    }
                }else {
                    // failure
                }
            }
        }else {
            asset.requestImageURL(toFile: nil) { url in
                if let imageURL = url {
                    // success
                }else {
                    // failure
                }
            }
        }
    case .video:
        if asset.isNetworkAsset {
            asset.getNetworkVideoURL { url, isNetwork in
                if let videoURL = url {
                    // success
                    if isNetwork {
                        // networkURL
                    }else {
                        // localURL
                    }
                }else {
                    // failure
                }
            }
        }else {
            asset.requestVideoURL(toFile: nil, exportPreset: nil) { url in
                if let videoURL = url {
                    // success
                }else {
                    // failure
                }
            }
        }
    }
}
```
