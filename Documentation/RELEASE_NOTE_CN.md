# 更新日志

## 1.4.3

适配`iPhone 14 Pro / Pro Max`

## 1.4.2

### 修复

- Picker
  - 预览`m3u8`格式视频时下载失败的问题，如果为`m3u8`格式的视频不会下载
  - 添加文件之后再次添加会闪退

- Camera
  - 某种情况下会崩溃的问题

## 1.4.1

### 优化

- 预览/编辑超大图片

### 修复

- Picker
  - 编辑后列表显示未改变

- Editor
  - 编辑动图图片变大的问题
  - 编辑之后的地址为绝对路径的问题
  
### 新增

- Picker
  - `config.preview.disableFinishButtonWhenNotSelected`多选模式下，未选择资源时是否禁用完成按钮

## 1.4.0

### 修复

- Editor
  - `EditorController`少了一个`editResult`的值传递

### 优化

- Picker
  - `PhotoBrowser`显示效果

### 新增

- Picker
  - 回调新增编辑图片/视频时可修改编辑配置
- Editor
  - 编辑图片时可以指定文件路径

## 1.3.9

### 修复

- 修复用Xcode13.3打包失败的bug
- 删除文字国际化

## 1.3.7

### 新增

- Picker
  - 获取相册/照片列表时支持过滤
- Camera
  - 添加滤镜效果，可自定义滤镜

### 优化

- Picker
  - 快速滚动时的加载逻辑

## 1.3.6

### 修复

- Camera
  - 修复录制10秒以上的视频时会丢失音频轨道

## 1.3.5

### 修复

- Picker
  - 在有编辑数据的时候照片列表cell没有显示图标
- Editor
  - 再次编辑图片时原始图片出错

## 1.3.4

### 新增

- Editor
  - 视频添加裁剪尺寸功能（与图片裁剪一致）
  
### 修复

- Picker
  - `PhotoBrowser`浏览网络视频时可能会出现时视频画面为正方形
- Editor
  - 特殊情况下多次旋转、镜像之后画面裁剪结果出错

## 1.3.3

### 新增

- Editor
  - 新增3种滤镜效果
- Camera
  - 新增配置`modalPresentationStyle`
  - `sessionPreset`默认修改为`hd1280x720`
  
### 修复

- Editor
  - 编辑拍摄的视频，画面旋转了90°
  
## 1.3.2

### 新增

- Editor
  - 视频编辑添加配乐时可以调整原声和配乐音量
  - 视频编辑支持添加滤镜效果
- Camera
  - 拍摄视频时支持点击方式`takePhotoMode`
  - 点击拍摄方式支持不限制最大时长
  
### 修复

- Editor
  - 底部工具栏设置单个类型时出现崩溃问题
- Camera
  - 旋转屏幕之后相机画面显示错误

## 1.3.1

### 新增
 
- Picker
  - 添加LivePhoto标示
  - 支持添加本地LivePhoto
- Editor
  - 画笔添加自定义颜色

### 修复

- 英文国际化问题
- 下载视频可能没有回调

## 1.3.0

- Picker
  - 同步iCloud上的视频时，获取质量修改为高质量
  - `PhotoAsset`获取URL时，添加压缩参数

## 1.2.9

### 修复

- Picker
  - 第一次加载相册权限为“选中的照片”时会导致崩溃
  - 预览界面在某种情况获取原图时会一直loading
- Editor
  - 编辑特殊视频时可能会导出失败
- Camera
  - 拍完照之后再返回相机缩放功能失效

## 1.2.8

### 修复

- Picker
  - 特殊情况下滑动停止后没有加载清晰的图片
  - 在有预选的情况下进入选择界面，开始的时候会画面可能会错乱一下

### 修改

- Picker
  - 允许手势滑动选择`allowSwipeToSelect`默认为`false`

### 优化

- 一些细节上的优化

## 1.2.7

### 修复

- `Swift Package Manager`导入报错的问题

## 1.2.6

### 修复

- Editor
  - 裁剪图片时旋转按钮未显示的问题

## 1.2.5

### 新增

- Picker
  - 相册权限为"选中的照片"时，照片列表添加更多按钮
  - 添加微信样式`Cell`
  
### 优化

- 完善暗黑模式
- Picker
  - 快速滑动过程中只加载模糊的小图，停止滑动时才加载清晰的图片
- Editor
  - 画笔颜色选中时的效果放大
  - 编辑图片在涂鸦模式下点击返回按钮转场动画时隐藏工具栏
  - 使用`Kingfisher`加载GIF贴纸时跳过内存缓存
  
### 修复

- Picker
  - 选择视频`dataUTI`为空时闪退
  
### 修改

- 暗黑模式下的主题色修改为与系统主题色一致
- 照片列表相机`Cell`取消默认实时预览
- 编辑器配置类名修改

## 1.2.4

### 新增

- Core
  - `ProgressHUD`添加进度显示
- Picker
  - 新增`isCacheCameraAlbum`是否缓存相机胶卷`PHFetchResult`，缓存之后再次加载可以快速显示照片列表 
  - 同步iCloud时添加进度显示
- Editor
  - 编辑视频导出时添加进度显示

### 修复

- Editor
  - `iOS 15`编辑视频，选择配乐之后滑动配乐列表导致崩溃
  - 编辑网络视频时，在还未下载完成之前退出控制器导致崩溃

## 1.2.3

### 新增

- 调整最低部署版本为 `iOS 12.0+`
- Kingfisher 升级为 `v7.0.0`
- Picker
  - `iCloud`标示
- Editor
  - `PhotoEditor`动态改变画笔宽度

### 优化

- Picker
  - 获取`iCloud`状态逻辑
  - `PhotoBrowser`适配`iOS 15`

### 修复

- Editor
  - `VideoEditor`视频裁剪框拖动到最后一段时视频裁剪出错

## 1.2.2

### 修复

- Picker
  - `camerType`类型修改
- Editor
  - 编辑超长图片失败
  - 删除贴图时快速触摸会导致贴图删除失败
- Camera
  - 无法获取位置信息

## 1.2.1

### 新增

添加`Camera`模块
有不兼容方法，使用时有报错的情况请调用最新方法

### 优化

- Picker
  - 相机未授权的情况下提示逻辑优化
  - 预览界面加载逻辑优化
- Editor
  - 音乐列表界面滑动优化
  
### 修复
  
- Editor
  - 编辑某些照片时，方向错误

## 1.2.0

### 新增

- Editor
  - 视频贴纸支持GIF
  - 配乐支持添加歌词字幕

### 优化

- Picker
  - 视频压缩逻辑优化
  - 贴纸快速多次拖拽时的效果优化
- Editor
  - 视频导出压缩逻辑优化
  - 搜索音乐时的效果优化
  
### 修复

- Editor
  - 编辑图片时旋转屏幕之后编辑数据出错

## 1.1.9

### 新增

- Picker
  - 快速跳转方法`func present(picker config: PickerConfiguration,delegate: PhotoPickerControllerDelegate? = nil,finishHandler: PhotoPickerController.FinishHandler? = nil,cancelHandler: PhotoPickerController.CancelHandler? = nil) -> PhotoPickerController`
- Editor
  - 视频添加贴纸和文字

### 优化

- Core
  - 一些细节优化
- Picker
  - 列表`cell`移除所有编辑数据时隐藏编辑标示
- Editor
  - `delegate`为`nil`时，加载贴图、音乐逻辑优化
  
### 不兼容修改

```
/// 新的加载贴图标题资源
func pickerController(_ pickerController: PhotoPickerController,
                      loadTitleChartlet editorViewController: UIViewController,
                      response: @escaping EditorTitleChartletResponse)

/// 新的加载贴图资源
func pickerController(_ pickerController: PhotoPickerController,
                        loadChartletList editorViewController: UIViewController,
                        titleChartlet: EditorChartlet,
                        titleIndex: Int,
                        response: @escaping EditorChartletListResponse)
```

## 1.1.8

### 新增

- Picker
  - 添加`PhotoBrowser`图片浏览
  
### 优化

- Picker
  - 获取原图大小时，处理未显示gif标示但本质还是gif时的逻辑
  - 预览网络视频来回滑动加载框出现重复加载问题 
  - 预览原图时压缩条件修改，图片大于3M的才会进行压缩
  - 一些细节优化

## 1.1.7

### 新增

- Picker
  - `Haptic touch`预览
- Editor
  - 长按预览贴纸

### 修复

- Core
  - 国际化补全
- Picker
  - 特殊情况下退出预览时可能会崩溃
  - 极端情况下预览gif时不会播放
  
### 优化

- Editor
  - `PhotoEditorConfiguration.Chartlet`公开初始化方法
  - `PhotoEditorConfiguration.Mosaic`公开初始化方法
  - 裁剪框显示优化

## 1.1.6

### 新增

- Picker
  - 网络视频加载方式`public var loadNetworkVideoMode: PhotoAsset.LoadNetworkVideoMode = .download`
  - 预览界面长按回调`func pickerController(_ pickerController: PhotoPickerController,
  previewLongPressClick photoAsset: PhotoAsset,
  atIndex: Int)`
- Editor
  - 搜索背景音乐
  
### 修复

- Picker
  - 获取本地资源原始地址失败

### 修改

- Editor
  - `VideoEditorMusicInfo`的`audioPath`修改为`audioURL`，`lrcPath`修改为`lrc`歌词lrc内容
  - 背景音乐可添加网络音频地址

## 1.1.5

### 新增

- Picker
  - `PhotoAsset`数据持久化`public func encode() -> Data?`、`public class func decoder(data: Data) -> PhotoAsset?`
- Editor
  - 贴图、文本

### 优化

- Picker
  - 断网或者iCloud获取失败的情况下选择Asset
  - 跳转编辑界面逻辑
  
### 修改

- Picker
  - 获取图片/视频地址方法修改

## 1.1.4

### 修复

- Picker
  - `appearanceStyle`设置为`dark`时，状态栏颜色未改变
- Editor
  - 选择滤镜时，选中状态出现重用
  
### 修改

- Picker
  - `titleViewConfig`修改为`titleView`
  - 手势返回动画效果 
- Editor
  - `photoEditorConfig.cropConfig`修改为`cropping`
  - `photoEditorConfig.filterConfig`修改为`filter`
  - `photoEditorConfig.mosaicConfig`修改为`mosaic`
  - `videoEditorConfig.musicConfig`修改为`music`
  - `videoEditorViewController.assetType`修改为`sourceType`
  - `EditorController.AssetType`修改为`EditorController.SourceType`

## 1.1.3

### 新增

- Picker
  - 预览视频添加滑动条
- Editor
  - 马赛克涂抹

### 修复

- Picker
  - 预览本地gif图片时会出现加载失败弹窗
  - 预览界面点击完成按钮在特殊情况下无反应
- Editor
  - 编辑长图时涂鸦可能无效
  - 某些滤镜重新编辑时未生效

## 1.1.2

### 新增

- Editor
  - 照片滤镜
  - 视频配乐

## 1.1.1

### 新增

- Picker
  - `PickerResult`新增获取压缩后的图片和压缩后的视频地址方法
- Editor
  - 新增涂鸦功能（支持gif）

### 修改

- Editor
  - `PhotoEditResult`的`editedImage`修改为缩略图

## 1.1.0

### 修复

- Picker
  - UIImage初始化本地图片时`mediaSubType`错误
  - 第一次预览本地视频时可能布局错误
  - 手势返回优化
  - 获取原图大小时判断是否被系统相册编辑过
- 去除警告⚠️

## 1.0.9

### 新增

- Picker
  - `PhotoAsset`新增`public init(localImageAsset: LocalImageAsset)`、`public init(localVideoAsset: LocalVideoAsset)`初始化方法，支持本地gif图片、视频
  - `PhotoAsset`新增`public init(networkImageAsset: NetworkImageAsset)`、`public init(networkVideoAsset: NetworkVideoAsset)`初始化方法，支持网络图片、视频
- Editor
  - `PhotoEditResult`新增`editedImageURL`字段
  - 支持编辑gif（需要`Kingfisher`）
  - 支持编辑网络图片（需要`Kingfisher`）
  - 支持编辑网络视频
  
### 修改

- 最低系统版本升为`iOS 10`
- picker
  - `PhotoAsset`添加本地资源初始化方法修改

### 修复

- Picker
  - 使用微信朋友圈主题在编辑图片完成后直接退出选择器控制器
  - 预览时进行编辑后底部视图可能会多添加一次资源
  - `PickerResult.getURLs()`获取视频地址出错问题
- Editor
  - 编辑视频时小几率会崩溃问题

## 1.0.8

### 新增

- Picker
  - 获取URL时可指定文件路径
- Editor
  - 照片编辑器增加固定裁剪状态配置

### 优化

- Picker
  - 获取图片URL时，GIF类型的图片转换方法修改
- Editor
  - 判断是否可以重置方法逻辑优化
  - 优化裁剪图片方法

### 修复

- Picker
  - 修复单选模式预览界面点击确定按钮无反应
  - LivePhoto、GIF资源在编辑后展示错误
  - 获取已选LivePhoto资源的URL时，因编辑过导致类型错误
- Editor
  - 再次编辑照片时布局错误乱

## 1.0.7

### 新增

- 照片编辑功能

### 修复

- 底部工具栏无法点击
- 横屏时长图显示错误

## 1.0.6

### 修复

- Picker
  - 修复自定义PickerCell快速选择模式下选中数字错乱问题

## 1.0.5

### 修复

- Picker
  - 修复未授权界面关闭按钮布局错乱
  - 修复预览界面编辑按钮`isEnabled`状态错误
  - 修复预览界面某些情况下手势返回无效
  - 修复滑动取消选择时可能会导致原图按钮未重置问题
- Editor
  - 修复视频裁剪时长错误
- 国际化文件补全
  
### 优化

- Picker
  - 视频播放按钮居中显，不跟随视频一起放大/缩小
- 优化iPad上的显示效果

## 1.0.4

### 新增

- Picker
  - 新增`quickSelectMode`枚举字段，可快速选择资源
  - 新增`videoEditor`视频编辑相关配置
  - 新增`maximumVideoEditDuration`视频时长超过限制则不可编辑
- Editor
  - 新增`EditorController/VideoEditorController`视频编辑功能

### 不兼容变更
#### Picker

```swift
/// 原回调方法
func pickerController(_ pickerController: PhotoPickerController, didFinishSelection selectedAssetArray: [PhotoAsset], _ isOriginal: Bool) {
    
}
/// 新的回调方法
func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
    
}
```

## 1.0.3

### 修改

- 去除文件前缀

## 1.0.2

### 修复

- 低系统版本下无法获取相册信息

## 1.0.1

### 优化

- 文件结构调整
- 优化自定义转场动画效果

