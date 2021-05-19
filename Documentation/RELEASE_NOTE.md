# 更新日志

## 1.0.8

### 新增

- Editor
  - 照片编辑器增加固定裁剪状态配置

### 优化

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
