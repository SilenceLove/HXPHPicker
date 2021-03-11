# 更新日志

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
