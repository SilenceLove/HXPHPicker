# Picker 使用说明

本节我们将会详细介绍 `Picker` 中每个配置项的作用，以及一些公开方法。



## 目录

- [调用/回调说明](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E8%B0%83%E7%94%A8%E5%9B%9E%E8%B0%83%E8%AF%B4%E6%98%8E)
  - [完成/取消选择](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%AE%8C%E6%88%90%E5%8F%96%E6%B6%88%E9%80%89%E6%8B%A9)
  - [选择逻辑](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%80%89%E6%8B%A9%E9%80%BB%E8%BE%91)
  - [替换相机](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E7%9B%B8%E6%9C%BA)
  - [替换编辑器](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E7%BC%96%E8%BE%91%E5%99%A8)
  -  [配置照片编辑器贴纸标题数据](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E7%85%A7%E7%89%87%E7%BC%96%E8%BE%91%E5%99%A8%E8%B4%B4%E7%BA%B8%E6%A0%87%E9%A2%98%E6%95%B0%E6%8D%AE)
  -  [配置照片编辑器贴纸数据](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E7%85%A7%E7%89%87%E7%BC%96%E8%BE%91%E5%99%A8%E8%B4%B4%E7%BA%B8%E6%95%B0%E6%8D%AE)
  - [替换视频编辑器的配乐界面](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%9B%BF%E6%8D%A2%E8%A7%86%E9%A2%91%E7%BC%96%E8%BE%91%E5%99%A8%E7%9A%84%E9%85%8D%E4%B9%90%E7%95%8C%E9%9D%A2)
  - [配置视频编辑器的配乐列表数据](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E8%A7%86%E9%A2%91%E7%BC%96%E8%BE%91%E5%99%A8%E7%9A%84%E9%85%8D%E4%B9%90%E5%88%97%E8%A1%A8%E6%95%B0%E6%8D%AE)
  - [视频编辑器搜索配乐数据](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E8%A7%86%E9%A2%91%E7%BC%96%E8%BE%91%E5%99%A8%E6%90%9C%E7%B4%A2%E9%85%8D%E4%B9%90%E6%95%B0%E6%8D%AE)
  - [预览界面](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%A2%84%E8%A7%88%E7%95%8C%E9%9D%A2)
  - [单独预览时的自定义转场动画](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%8D%95%E7%8B%AC%E9%A2%84%E8%A7%88%E6%97%B6%E7%9A%84%E8%87%AA%E5%AE%9A%E4%B9%89%E8%BD%AC%E5%9C%BA%E5%8A%A8%E7%94%BB)
  - [照片列表视图](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E7%85%A7%E7%89%87%E5%88%97%E8%A1%A8%E8%A7%86%E5%9B%BE)
  - [控制器的生命周期](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%8E%A7%E5%88%B6%E5%99%A8%E7%9A%84%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F)
- [配置项说明](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E9%85%8D%E7%BD%AE%E9%A1%B9%E8%AF%B4%E6%98%8E)
  - [LanguageType](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#languagetype)
  - [AppearanceStyle](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#appearancestyle)
  - [PrefersStatusBarHidden](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#prefersstatusbarhidden)
  - [ShouldAutorotate](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#shouldautorotate)
  - [SupportedInterfaceOrientations](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#supportedinterfaceorientations)
  - [IndicatorType](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#indicatortype)
  - [SelectOptions](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#selectoptions)
  - [SelectMode](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#selectMode)
  - [AlbumShowMode](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#albumShowMode)
  - [AllowSyncICloudWhenSelectPhoto](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#allowSyncICloudWhenSelectPhoto)
  - [SelectionTapAction](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#selectionTapAction)
  - [AllowSelectedTogether](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#allowSelectedTogether)
  - [CreationDate](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#creationDate)
  - [SelectedCount](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#selectedCount)
  - [EditorOptions](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#editorOptions)
  - [AlbumList](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#albumList)
  - [PhotoList](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#photoList)
  - [PreviewView](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#previewView)
  - [NotAuthorized](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#notAuthorized)
  - [Editor](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#editor)
- [公开方法](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%85%AC%E5%BC%80%E6%96%B9%E6%B3%95)
  - [获取原始图片/视频](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E8%8E%B7%E5%8F%96%E5%8E%9F%E5%A7%8B%E5%9B%BE%E7%89%87%E8%A7%86%E9%A2%91)
  - [数据持久化](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E6%95%B0%E6%8D%AE%E6%8C%81%E4%B9%85%E5%8C%96)
  - [单独预览资源](https://github.com/SilenceLove/HXPHPicker/wiki/Picker%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#%E5%8D%95%E7%8B%AC%E9%A2%84%E8%A7%88%E8%B5%84%E6%BA%90)


## 调用/回调说明

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

方法二：首先我们初始化好选择器并且推出

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

### 配置照片编辑器贴纸标题数据

```swift
/// 照片/视频 编辑器加载贴图标题资源
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - editorViewController: 对应的 PhotoEditorViewController / VideoEditorViewController
///   - loadTitleChartlet: 传入标题数组
func pickerController(_ pickerController: PhotoPickerController,
                      loadTitleChartlet editorViewController: UIViewController,
                      response: @escaping EditorTitleChartletResponse) { 
    #if canImport(Kingfisher)
    // 获取默认的贴纸标题数据
    let titles = PhotoTools.defaultTitleChartlet()
    // 获取到标题数据之后回传给内部
    response(titles)
    #endif                      
}
```

### 配置照片编辑器贴纸数据

```swift
/// 照片/视频 编辑器加载贴图资源
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - editorViewController: 对应的 PhotoEditorViewController / VideoEditorViewController
///   - titleChartlet: 对应配置的 title
///   - titleIndex: 对应配置的 title 的位置索引
///   - response: 传入 title索引 和 贴图数据
func pickerController(_ pickerController: PhotoPickerController,
                      loadChartletList editorViewController: UIViewController,
                      titleChartlet: EditorChartlet,
                      titleIndex: Int,
                      response: EditorChartletListResponse) {
    #if canImport(Kingfisher)
    // 获取默认的贴纸数据
    let chartletList = PhotoTools.defaultNetworkChartlet()
    // 获取到贴纸数据之后回传给内部
    response(titleIndex, chartletList)
    #endif
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
/// 视频编辑器加载配乐信息，当music.infos为空时触发
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

### 视频编辑器搜索配乐数据

```swift
/// 视频编辑器搜索配乐信息
/// - Parameters:
///   - videoEditorViewController: 对应的 VideoEditorViewController
///   - text: 搜索的文字内容
///   - completion: 传入配乐信息，是否需要加载更多
func pickerController(_ pickerController: PhotoPickerController,
                      videoEditor videoEditorViewController: VideoEditorViewController,
                      didSearch text: String?,
                      completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
    // 模仿延迟加加载数据
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        completionHandler(self.getMusicInfos(), true)
    }
}
/// 视频编辑器加载更多配乐信息
/// - Parameters:
///   - videoEditorViewController: 对应的 VideoEditorViewController
///   - text: 搜索的文字内容
///   - completion: 传入配乐信息，是否还有更多数据
func pickerController(_ pickerController: PhotoPickerController,
                      videoEditor videoEditorViewController: VideoEditorViewController,
                      loadMore text: String?,
                      completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        completionHandler(self.getMusicInfos(), false)
    }
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

/// 预览界面长按操作
/// - Parameters:
///   - pickerController: 对应的 PhotoPickerController
///   - photoAsset: 对应显示的 PhotoAsset 数据
///   - atIndex: 对应显示的位置
func pickerController(_ pickerController: PhotoPickerController,
                      previewLongPressClick photoAsset: PhotoAsset,
                      atIndex: Int) {
    // 当为外部预览时，长按弹出菜单
    if pickerController.isPreviewAsset {
        
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
                      previewDidDeleteAssets photoAssets: [PhotoAsset],
                      at indexs: [Int]) {
    
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

### 照片列表视图

我们单独提供一个照片列表视图的类`PhotoPickerView`，可以将照片列表视图添加到在你想添加的位置

```swift
// 照片选择视频的数据管理类 
let manager = PickerManager()

let pickerView = PhotoPickerView(
    manager: manager,
    scrollDirection: .horizontal,   // 视图滚动方向
    delegate: self  // 代理对象
)
addSubview(pickerView)
```

`PhotoPickerView`公开方法

```swift
/// 获取相机胶卷相册集合里的Asset
public func fetchAsset()

/// 重新加载相机胶卷相册
public func reloadCameraAsset()

/// 重新加载Asset
/// 可以通过获取相册集合 manager.fetchAssetCollections()
/// - Parameter assetCollection: 相册
public func reloadAsset(assetCollection: PhotoAssetCollection?)

/// 取消选择
/// - Parameter index: 对应的索引
public func deselect(at index: Int)

/// 取消选择
/// - Parameter photoAsset: 对应的 PhotoAsset
public func deselect(at photoAsset: PhotoAsset)

/// 全部取消选择
public func deselectAll()

/// 移除选择的内容
/// 只是移除的manager里的已选数据
/// cell选中状态需要调用 deselectAll()
public func removeSelectedAssets()

/// 清空
public func clear()
```

`PickerManager`公开属性/方法

```swift
/// 相关配置
public var config: PickerConfiguration

/// fetch Assets 时的选项配置
public var options: PHFetchOptions

/// 限制加载数量，默认0，不限制
public var fetchLimit: Int

/// 当前被选择的资源对应的 PhotoAsset 对象数组
public var selectedAssetArray: [PhotoAsset]
```

```swift
/// 获取相册集合
/// - Parameters:
///   - options: 获取 PHFetchResult 中的 PHAsset 时的选项
///   - showEmptyCollection: 是否显示空集合
/// - Returns: 相册集合
func fetchAssetCollections(
    for options: PHFetchOptions,
    showEmptyCollection: Bool = false
) -> [PhotoAssetCollection]

/// 获取已选资源的总大小
/// - Parameters:
///   - completion: 完成回调
func requestSelectedAssetFileSize(
    completion: @escaping (Int, String) -> Void
)

/// 取消获取资源文件大小
func cancelRequestAssetFileSize()
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

#### LanguageType

`languageType`是选择器显示的语言类型，默认为`.system`

```swift
public enum LanguageType: Int {
    case system = 0             //!< 跟随系统语言
    case simplifiedChinese = 1  //!< 中文简体
    case traditionalChinese = 2 //!< 中文繁体
    case japanese = 3           //!< 日文
    case korean = 4             //!< 韩文
    case english = 5            //!< 英文
    case thai = 6               //!< 泰语
    case indonesia = 7          //!< 印尼语
}
```

#### AppearanceStyle

`appearanceStyle`是选择器外观显示的风格，默认为`.varied`

```swift
public enum AppearanceStyle: Int {
    /// 跟随系统变化
    case varied = 0
    /// 正常风格，不会跟随系统变化
    case normal = 1
    /// 暗黑风格
    case dark = 2
}
```

#### PrefersStatusBarHidden

`prefersStatusBarHidden`是否隐藏状态栏，默认`false`

#### ShouldAutorotate

`shouldAutorotate`是否允许选择自动旋转，默认`true

#### SupportedInterfaceOrientations

`supportedInterfaceOrientations`选择器支持的方向，默认`.all`

```swift
public struct UIInterfaceOrientationMask : OptionSet {

    public init(rawValue: UInt)

    
    public static var portrait: UIInterfaceOrientationMask { get }

    public static var landscapeLeft: UIInterfaceOrientationMask { get }

    public static var landscapeRight: UIInterfaceOrientationMask { get }

    public static var portraitUpsideDown: UIInterfaceOrientationMask { get }

    public static var landscape: UIInterfaceOrientationMask { get }

    public static var all: UIInterfaceOrientationMask { get }

    public static var allButUpsideDown: UIInterfaceOrientationMask { get }
}
```

#### IndicatorType

`indicatorType`显示加载指示器的类型，默认`.circle`

```swift
/// 加载指示器类型
public enum IndicatorType {
    /// 渐变圆环
    case circle
    /// 系统菊花
    case system
}
```

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

#### AllowSyncICloudWhenSelectPhoto

`allowSyncICloudWhenSelectPhoto`选择照片时，先判断是否在iCloud上。如果在iCloud上会先同步iCloud上的资源
如果在断网或者系统iCloud出错的情况下:
为`true`时，选择失败
为`false`时，获取原始图片会失败

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
///   - handler: 获取到url的回调
///   - completionHandler: 全部获取完成
public func getURLs(options: Options = .any,
                    urlReceivedHandler handler: @escaping (Result<AssetURLResult, AssetError>, PhotoAsset, Int) -> Void,
                    completionHandler: @escaping ([URL]) -> Void)
```

#### Sample Code

```swift
func pickerController(_ pickerController: PhotoPickerController, 
                        didFinishSelection result: PickerResult) {
    result.getURLs { result, photoAsset, index in
        switch result {
        case .success(let response):
            if response.mediaType == .photo {
                // 图片地址
                if response.urlType == .network {
                    // 网络地址
                }else {
                    // 本地地址
                }
            }else {
                // 视频地址
                if response.urlType == .network {
                    // 网络地址
                }else {
                    // 本地地址
                }
            }
        case .failure(let error):
            // 获取失败
            print(error)
        }
    } completionHandler: { urls in
        // Your code
    }
}
```

在`PhotoAsset`对象中，我们也提供了获取原始图片/视频的方法:

```swift
/// 获取url
///   - completion: result 
func getAssetURL(completion: @escaping AssetURLCompletion)

/// 获取图片url
///   - completion: result
func getImageURL(completion: @escaping AssetURLCompletion)

/// 获取视频url
/// - Parameters:
///   - exportPreset: 导出质量
///   - completion: result
func getVideoURL(exportPreset: String? = nil,
                 completion: @escaping AssetURLCompletion)
```

#### Sample Code

```swift
func pickerController(_ pickerController: PhotoPickerController,
                        didFinishSelection result: PickerResult) {
    guard let photoAsset = result.photoAssets.first else { return }
    photoAsset.getAssetURL { result in
        switch result {
        case .success(let response):
            if response.mediaType == .photo {
                // 图片地址
                if response.urlType == .network {
                    // 网络地址
                }else {
                    // 本地地址
                }
            }else {
                // 视频地址
                if response.urlType == .network {
                    // 网络地址
                }else {
                    // 本地地址
                }
            }
        case .failure(let error):
            // 获取失败
            print(error)
        }
    }
}
```

### 数据持久化

在`PhotoAsset`对象中，提供了编解码的方法:

```swift
/// 编码
/// - Returns: 编码之后的数据
public func encode() -> Data?

/// 解码
/// - Parameter data: 之前编码得到的数据
/// - Returns: 对应的 PhotoAsset 对象
public class func decoder(data: Data) -> PhotoAsset? 
```

#### Sample Code

```swift
func pickerController(_ pickerController: PhotoPickerController,
                        didFinishSelection result: PickerResult) {
    guard let photoAsset = result.photoAssets.first else { return }
    // 获取编码之后的数据
    if let data = photoAsset.encode() {
        // 存入本地
        try? data.write(to: URL(fileURLWithPath: "自己定义的路径"))
    }
    // 获取之前编码存在本地的数据
    {
        if let data = FileManager.default.contents(atPath: "自己定义的路径"),
           let photoAsset = PhotoAsset.decoder(data: data) {
            // photoAsset 上一次存在本地的 PhotoAsset 对象
        }
    }
}
```

### 单独预览资源

#### PhotoPickerController
```swift
let previewConfig = PhotoTools.getWXPickerConfig() 
let previewController = PhotoPickerController(preview: previewConfig, 
                                              currentIndex: 0, 
                                              delegate: self)
// 预览的资源数组
previewController.selectedAssetArray = selectedAssets
present(previewController, animated: true, completion: nil)
```

#### PhotoBrowser
```swift
let config = PhotoBrowser.Configuration()
config.showDelete = true
config.modalPresentationStyle = style
let cell = collectionView.cellForItem(at: indexPath) as? ResultViewCell
PhotoBrowser.show(
    // 预览的资源数组
    selectedAssets,
    // 当前预览的位置
    pageIndex: indexPath.item,
    // 预览相关配置
    config: config,
    // 转场动画初始的 UIImage
    transitionalImage: cell?.imageView.image
) {
    index in
    // 转场过渡时起始/结束时 对应的 UIView
    self.collectionView.cellForItem(
        at: IndexPath(
            item: index,
            section: 0
        )
    ) as? ResultViewCell
} deleteAssetHandler: {
    index, photoAsset, photoBrowser in
    // 点击了删除按钮
    PhotoTools.showAlert(
        viewController: photoBrowser,
        title: "是否删除当前资源",
        leftActionTitle: "确定",
        leftHandler: {
            (alertAction) in
            photoBrowser.deleteCurrentPreviewPhotoAsset()
            self.previewDidDeleteAsset(
                index: index
            )
        }, rightActionTitle: "取消") { (alertAction) in }
} longPressHandler: {
    index, photoAsset, photoBrowser in
    // 长按事件
    self.previewLongPressClick(
        photoAsset: photoAsset,
        photoBrowser: photoBrowser
    )
}
```

#### 预览视频时添加进度条

```swfit
// 单击界面时，不自动播放视频
previewConfig.previewView.singleClickCellAutoPlayVideo = false
// 更换为带进度条的cell
previewConfig.previewView.customVideoCellClass = PreviewVideoControlViewCell.self
```


## 下一步

- [Editor使用说明](https://github.com/SilenceLove/HXPHPicker/wiki/Editor%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)
