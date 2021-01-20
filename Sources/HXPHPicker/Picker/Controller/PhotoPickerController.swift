//
//  PhotoPickerController.swift
//  照片选择器-Swift
//
//  Created by Silence on 2020/11/9.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos

@objc public protocol PhotoPickerControllerDelegate: NSObjectProtocol {
    
    /// 选择完成之后调用，单选模式下不会触发此回调
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - selectedAssetArray: 选择的资源对应的 PhotoAsset 数据
    ///   - isOriginal: 是否选中的原图
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didFinishSelection selectedAssetArray: [PhotoAsset], _ isOriginal: Bool)
    
    /// 单选完成之后调用
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    ///   - isOriginal: 是否选中的原图
    @objc optional func pickerController(_ pickerController: PhotoPickerController, singleFinishSelection photoAsset:PhotoAsset, _ isOriginal: Bool)
    
    /// 点击了原图按钮
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - isOriginal: 是否选中的原图
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didOriginalButton isOriginal: Bool)
    
    /// 将要点击cell，允许的话点击之后会跳转预览界面
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    ///   - atIndex: indexPath.item
    @objc optional func pickerController(_ pickerController: PhotoPickerController, shouldClickCell photoAsset: PhotoAsset, atIndex: Int) -> Bool
    
    /// 将要选择cell 不能选择时需要自己手动弹出提示框
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    ///   - atIndex: 将要添加的索引
    @objc optional func pickerController(_ pickerController: PhotoPickerController, shouldSelectedAsset photoAsset: PhotoAsset, atIndex: Int) -> Bool

    /// 即将选择 cell 时调用
    @objc optional func pickerController(_ pickerController: PhotoPickerController, willSelectAsset photoAsset: PhotoAsset, atIndex: Int)

    /// 选择了 cell 之后调用
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didSelectAsset photoAsset: PhotoAsset, atIndex: Int)

    /// 即将取消了选择 cell
    @objc optional func pickerController(_ pickerController: PhotoPickerController, willUnselectAsset photoAsset: PhotoAsset, atIndex: Int)

    /// 取消了选择 cell
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didUnselectAsset photoAsset: PhotoAsset, atIndex: Int)
    
    /// 是否能够推出相机界面，点击相机cell时调用
    /// 可以跳转其他相机界面然后调用 addedCameraPhotoAsset
    @objc optional func pickerController(shouldPresentCamera pickerController: PhotoPickerController) -> Bool
    
    /// 将要编辑 Asset，不允许的话可以自己跳转其他编辑界面
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    @objc optional func pickerController(_ pickerController: PhotoPickerController, shouldEditAsset photoAsset: PhotoAsset, atIndex: Int) -> Bool
    
    /// Asset 编辑完后调用
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应的 PhotoAsset 数据
    ///   - atIndex: 对应的下标
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didEditAsset photoAsset: PhotoAsset, atIndex: Int)
    
    /// 预览界面更新当前显示的资源，collectionView滑动了就会调用
    /// - Parameters:
    ///   - pikcerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应显示的 PhotoAsset 数据
    ///   - index: 对应显示的位置
    @objc optional func pickerController(_ pikcerController: PhotoPickerController, previewUpdateCurrentlyDisplayedAsset photoAsset: PhotoAsset, atIndex: Int)
    
    /// 预览界面将要删除 Asset
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应被删除的 PhotoAsset 数据
    @objc optional func pickerController(_ pickerController: PhotoPickerController, previewShouldDeleteAsset photoAsset: PhotoAsset, atIndex: Int) -> Bool
    
    /// 预览界面已经删除了 Asset
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - photoAsset: 对应被删除的 PhotoAsset 数据
    ///   - atIndex: 资源对应的位置索引
    @objc optional func pickerController(_ pickerController: PhotoPickerController, previewDidDeleteAsset photoAsset: PhotoAsset, atIndex: Int)
    
    /// 视图控制器即将显示
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - viewController: 对应的控制器 [AlbumViewController, PhotoPickerViewController, PhotoPreviewViewController]
    @objc optional func pickerController(_ pickerController: PhotoPickerController, viewControllersWillAppear viewController: UIViewController)
    
    /// 视图控制器已经显示
    @objc optional func pickerController(_ pickerController: PhotoPickerController, viewControllersDidAppear viewController: UIViewController)
    
    /// 视图控制器即将消失
    @objc optional func pickerController(_ pickerController: PhotoPickerController, viewControllersWillDisappear viewController: UIViewController)
    
    /// 视图控制器已经消失
    @objc optional func pickerController(_ pickerController: PhotoPickerController, viewControllersDidDisappear viewController: UIViewController)
    
    /// 点击取消时调用
    /// - Parameter pickerController: 对应的 PhotoPickerController
    @objc optional func pickerController(didCancel pickerController: PhotoPickerController)
    
    /// dismiss后调用
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - localCameraAssetArray: 相机拍摄存在本地的 PhotoAsset 数据
    ///     可以在下次进入选择时赋值给localCameraAssetArray，列表则会显示
    @objc optional func pickerController(_ pickerController: PhotoPickerController, didDismissComplete localCameraAssetArray: [PhotoAsset])
    
    
    // MARK: 单独预览时的自定义转场动画
    /// present预览时展示的image
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - index: 预览资源对应的位置
    @objc optional func pickerController(_ pickerController: PhotoPickerController, presentPreviewImageForIndexAt index: Int) -> UIImage?
    
    /// present 预览时起始的视图，用于获取位置大小。与 presentPreviewFrameForIndexAt 一样
    @objc optional func pickerController(_ pickerController: PhotoPickerController, presentPreviewViewForIndexAt index: Int) -> UIView?
    
    /// dismiss 结束时对应的视图，用于获取位置大小。与 dismissPreviewFrameForIndexAt 一样
    @objc optional func pickerController(_ pickerController: PhotoPickerController, dismissPreviewViewForIndexAt index: Int) -> UIView?
    
    /// present 预览时对应的起始位置大小
    @objc optional func pickerController(_ pickerController: PhotoPickerController, presentPreviewFrameForIndexAt index: Int) -> CGRect
    
    /// dismiss 结束时对应的位置大小
    @objc optional func pickerController(_ pickerController: PhotoPickerController, dismissPreviewFrameForIndexAt index: Int) -> CGRect
    
    /// 外部预览自定义 present 完成
    @objc optional func pickerController(_ pickerController: PhotoPickerController, previewPresentComplete atIndex: Int)
    
    /// 外部预览自定义 dismiss 完成
    @objc optional func pickerController(_ pickerController: PhotoPickerController, previewDismissComplete atIndex: Int)
}

open class PhotoPickerController: UINavigationController {
    
    public weak var pickerControllerDelegate : PhotoPickerControllerDelegate?
    
    /// 相关配置
    public var config : PickerConfiguration!
    
    /// fetch Assets 时的选项配置
    public lazy var options : PHFetchOptions = {
        let options = PHFetchOptions.init()
        return options
    }()
    
    /// 当前被选择的资源对应的 PhotoAsset 对象数组
    /// 外部预览时的资源数据
    public var selectedAssetArray: [PhotoAsset] = [] {
        didSet {
            configSelectedArray()
        }
    }
    
    /// 本地资源数组
    /// 创建本地资源的PhotoAsset然后赋值即可添加到照片列表，如需选中也要添加到selectedAssetArray中
    public var localAssetArray: [PhotoAsset] = []
    
    /// 相机拍摄存在本地的资源数组
    /// 可以通过 pickerControllerDidDismiss 得到上一次相机拍摄的资源，然后赋值即可显示上一次相机拍摄的资源
    public var localCameraAssetArray: [PhotoAsset] = []
    
    /// 是否选中了原图
    public var isOriginal: Bool = false
    
    /// 刷新数据
    /// 可以在传入 selectedPhotoAssetArray 之后重新加载数据将重新设置的被选择的 PhotoAsset 选中
    /// - Parameter assetCollection: 切换显示其他资源集合
    public func reloadData(assetCollection: PhotoAssetCollection?) {
        pickerViewController()?.changedAssetCollection(collection: assetCollection)
        reloadAlbumData()
    }
    
    /// 刷新相册数据，只对单独控制器展示的有效
    public func reloadAlbumData() {
        albumViewController()?.tableView.reloadData()
    }
    
    /// 使用其他相机拍摄完之后调用此方法添加
    /// - Parameter photoAsset: 对应的 PhotoAsset 数据
    public func addedCameraPhotoAsset(_ photoAsset: PhotoAsset) {
        pickerViewController()?.addedCameraPhotoAsset(photoAsset)
        previewViewController()?.addedCameraPhotoAsset(photoAsset)
    }
    
    /// 删除当前预览的 Asset
    public func deleteCurrentPreviewPhotoAsset() {
        previewViewController()?.deleteCurrentPhotoAsset()
    }
    
    /// 预览界面添加本地资源
    /// - Parameter photoAsset: 对应的 PhotoAsset 数据
    public func previewAddedCameraPhotoAsset(_ photoAsset: PhotoAsset) {
        previewViewController()?.addedCameraPhotoAsset(photoAsset)
    }
    
    /// 获取预览界面当前显示的 image 视图
    /// - Returns: 对应的 UIImageView
    public func getCurrentPreviewImageView() -> UIImageView? {
        if let previewVC = previewViewController(), let cell = previewVC.getCell(for: previewVC.currentPreviewIndex) {
            return cell.scrollContentView.imageView
        }
        return nil
    }
    
    /// 相册列表控制器
    public func albumViewController() -> AlbumViewController? {
        return getViewController(for: AlbumViewController.self) as? AlbumViewController
    }
    /// 照片选择控制器
    public func pickerViewController() -> PhotoPickerViewController? {
        return getViewController(for: PhotoPickerViewController.self) as? PhotoPickerViewController
    }
    /// 照片预览控制器
    public func previewViewController() -> PhotoPreviewViewController? {
        return getViewController(for: PhotoPreviewViewController.self) as? PhotoPreviewViewController
    }
    
    /// 当前处于的外部预览
    public var isPreviewAsset: Bool = false
    
    /// 选择资源初始化
    /// - Parameter config: 相关配置
    public convenience init(picker config: PickerConfiguration) {
        self.init(config: config)
    }
    /// 选择资源初始化
    /// - Parameter config: 相关配置
    public init(config: PickerConfiguration) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        self.config = config
        if config.selectMode == .multiple &&
            !config.allowSelectedTogether &&
            config.maximumSelectedVideoCount == 1 &&
            config.selectType == .any {
            singleVideo = true
        }
        super.init(nibName: nil, bundle: nil)
        var photoVC : UIViewController
        if config.albumShowMode == .normal {
            photoVC = AlbumViewController.init()
        }else {
            photoVC = PhotoPickerViewController.init()
        }
        self.viewControllers = [photoVC]
    }
    
    /// 外部预览资源初始化
    /// - Parameters:
    ///   - config: 相关配置
    ///   - modalPresentationStyle: 设置 custom 样式，框架自带动画效果
    public init(preview config: PickerConfiguration, currentIndex: Int, modalPresentationStyle: UIModalPresentationStyle) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        _ = PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        self.config = config
        isPreviewAsset = true
        super.init(nibName: nil, bundle: nil)
        let vc = PhotoPreviewViewController.init()
        vc.isExternalPreview = true
        vc.currentPreviewIndex = currentIndex
        self.viewControllers = [vc]
        self.modalPresentationStyle = modalPresentationStyle
        if modalPresentationStyle == .custom {
            transitioningDelegate = self
            modalPresentationCapturesStatusBarAppearance = true
        }
    }
    
    
    // MARK: -
    /// 所有资源集合
    private(set) var assetCollectionsArray : [PhotoAssetCollection] = []
    var fetchAssetCollectionsCompletion : (([PhotoAssetCollection])->())?
    
    /// 相机胶卷资源集合
    private(set) var cameraAssetCollection : PhotoAssetCollection?
    var fetchCameraAssetCollectionCompletion : ((PhotoAssetCollection?)->())?
    private var canAddAsset: Bool = true
    private var isFirstAuthorization: Bool = false
    private var selectType : SelectType?
    private var selectedPhotoAssetArray: [PhotoAsset] = []
    private var selectedVideoAssetArray: [PhotoAsset] = []
    private lazy var deniedView: DeniedAuthorizationView = {
        let deniedView = DeniedAuthorizationView.init(config: config.notAuthorized)
        deniedView.frame = view.bounds
        return deniedView
    }()
    private var singleVideo: Bool = false
    private lazy var assetCollectionsQueue: OperationQueue = {
        let assetCollectionsQueue = OperationQueue.init()
        assetCollectionsQueue.maxConcurrentOperationCount = 1
        return assetCollectionsQueue
    }()
    private lazy var requestAssetBytesQueue: OperationQueue = {
        let requestAssetBytesQueue = OperationQueue.init()
        requestAssetBytesQueue.maxConcurrentOperationCount = 1
        return requestAssetBytesQueue
    }()
    private lazy var previewRequestAssetBytesQueue: OperationQueue = {
        let requestAssetBytesQueue = OperationQueue.init()
        requestAssetBytesQueue.maxConcurrentOperationCount = 1
        return requestAssetBytesQueue
    }()
    public override var modalPresentationStyle: UIModalPresentationStyle {
        didSet {
            if isPreviewAsset && modalPresentationStyle == .custom {
                transitioningDelegate = self
                modalPresentationCapturesStatusBarAppearance = true
            }
        }
    }
    private var interactiveTransition: PickerInteractiveTransition?
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configColor()
        navigationBar.isTranslucent = config.navigationBarIsTranslucent
        selectType = config.selectType
        if !isPreviewAsset {
            setOptions()
            requestAuthorization()
        }else {
            interactiveTransition = PickerInteractiveTransition.init(panGestureRecognizerFor: self, type: .dismiss)
        }
    }
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if isFirstAuthorization && viewControllerToPresent is UIImagePickerController {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
            isFirstAuthorization = false
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let status = AssetManager.authorizationStatus()
        if status.rawValue >= 1 && status.rawValue < 3 {
            deniedView.frame = view.bounds
        }
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return config.statusBarStyle
    }
    public override var prefersStatusBarHidden: Bool {
        if config.prefersStatusBarHidden {
            return config.prefersStatusBarHidden
        }else {
            return topViewController?.prefersStatusBarHidden ?? false
        }
    }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? UIStatusBarAnimation.fade
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                configColor()
            }
        }
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !isPreviewAsset && presentingViewController == nil {
            didDismiss()
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        print("\(self) deinit")
    }
}

// MARK: fetchAsset
extension PhotoPickerController {
    
    /// 获取相机胶卷资源集合
    func fetchCameraAssetCollection() {
        if !config.allowLoadPhotoLibrary {
            if cameraAssetCollection == nil {
                cameraAssetCollection = PhotoAssetCollection.init(albumName: config.albumList.emptyAlbumName.localized, coverImage: config.albumList.emptyCoverImageName.image)
            }
            fetchCameraAssetCollectionCompletion?(cameraAssetCollection)
            return
        }
        if config.creationDate {
            options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: config.creationDate)]
        }
        PhotoManager.shared.fetchCameraAssetCollection(for: selectType ?? .any, options: options) { (assetCollection) in
            if assetCollection.count == 0 {
                self.cameraAssetCollection = PhotoAssetCollection.init(albumName: self.config.albumList.emptyAlbumName.localized, coverImage: self.config.albumList.emptyCoverImageName.image)
            }else {
                // 获取封面
                self.cameraAssetCollection = assetCollection
                self.cameraAssetCollection?.fetchCoverAsset()
            }
            if self.config.albumShowMode == .popup {
                self.fetchAssetCollections()
            }
            self.fetchCameraAssetCollectionCompletion?(self.cameraAssetCollection)
        }
    }
    
    /// 获取相册集合
    func fetchAssetCollections() {
        assetCollectionsQueue.cancelAllOperations()
        let operation = BlockOperation.init {
            if self.config.creationDate {
                self.options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: self.config.creationDate)]
            }
            self.assetCollectionsArray = []
            
            var localCount = self.localAssetArray.count + self.localCameraAssetArray.count
            var coverImage = self.localCameraAssetArray.first?.originalImage
            if coverImage == nil {
                coverImage = self.localAssetArray.first?.originalImage
            }
            var firstSetImage = true
            for phAsset in self.selectedAssetArray {
                if phAsset.phAsset == nil {
                    let inLocal = self.localAssetArray.contains(where: { (localAsset) -> Bool in
                        return localAsset.isEqual(phAsset)
                    })
                    let inLocalCamera = self.localCameraAssetArray.contains(where: { (localAsset) -> Bool in
                        return localAsset.isEqual(phAsset)
                    })
                    if !inLocal && !inLocalCamera {
                        if firstSetImage {
                            coverImage = phAsset.originalImage
                            firstSetImage = false
                        }
                        localCount += 1
                    }
                }
            }
            if !self.config.allowLoadPhotoLibrary {
                DispatchQueue.main.async {
                    self.cameraAssetCollection?.realCoverImage = coverImage
                    self.cameraAssetCollection?.count += localCount
                    self.assetCollectionsArray.append(self.cameraAssetCollection!)
                    self.fetchAssetCollectionsCompletion?(self.assetCollectionsArray)
                }
                return
            }
            PhotoManager.shared.fetchAssetCollections(for: self.options, showEmptyCollection: false) { (assetCollection, isCameraRoll) in
                if assetCollection != nil {
                    // 获取封面
                    assetCollection?.fetchCoverAsset()
                    assetCollection?.count += localCount
                    if isCameraRoll {
                        self.assetCollectionsArray.insert(assetCollection!, at: 0);
                    }else {
                        self.assetCollectionsArray.append(assetCollection!)
                    }
                }else {
                    if self.cameraAssetCollection != nil {
                        self.cameraAssetCollection?.count += localCount
                        if coverImage != nil {
                            self.cameraAssetCollection?.realCoverImage = coverImage
                        }
                        if !self.assetCollectionsArray.isEmpty {
                            self.assetCollectionsArray[0] = self.cameraAssetCollection!
                        }else {
                            self.assetCollectionsArray.append(self.cameraAssetCollection!)
                        }
                    }
                    DispatchQueue.main.async {
                        if let operation =
                            self.assetCollectionsQueue.operations.first {
                            if operation.isCancelled {
                                return
                            }
                        }
                        self.fetchAssetCollectionsCompletion?(self.assetCollectionsArray)
                    }
                }
            }
        }
        assetCollectionsQueue.addOperation(operation)
    }
    /// 获取相册里的资源
    /// - Parameters:
    ///   - assetCollection: 相册
    ///   - completion: 完成回调
    func fetchPhotoAssets(assetCollection: PhotoAssetCollection?, completion: @escaping ([PhotoAsset], PhotoAsset?) -> Void) {
        DispatchQueue.global().async {
            var selectedAssets = [PHAsset]()
            var selectedPhotoAssets:[PhotoAsset] = []
            var localAssets: [PhotoAsset] = []
            var localIndex = -1
            for (index, photoAsset) in self.selectedAssetArray.enumerated() {
                photoAsset.selectIndex = index
                photoAsset.isSelected = true
                if let phAsset = photoAsset.phAsset {
                    selectedAssets.append(phAsset)
                    selectedPhotoAssets.append(photoAsset)
                }else {
                    let inLocal = self.localAssetArray.contains { (localAsset) -> Bool in
                        if localAsset.isEqual(photoAsset) {
                            self.localAssetArray[self.localAssetArray.firstIndex(of: localAsset)!] = photoAsset
                            return true
                        }
                        return false
                    }
                    let inLocalCamera = self.localCameraAssetArray.contains(where: { (localAsset) -> Bool in
                        if localAsset.isEqual(photoAsset) {
                            self.localCameraAssetArray[self.localCameraAssetArray.firstIndex(of: localAsset)!] = photoAsset
                            return true
                        }
                        return false
                    })
                    if !inLocal && !inLocalCamera {
                        if photoAsset.localIndex > localIndex  {
                            localIndex = photoAsset.localIndex
                            self.localAssetArray.insert(photoAsset, at: 0)
                        }else {
                            if localIndex == -1 {
                                localIndex = photoAsset.localIndex
                                self.localAssetArray.insert(photoAsset, at: 0)
                            }else {
                                self.localAssetArray.insert(photoAsset, at: 1)
                            }
                        }
                    }
                }
            }
            localAssets.append(contentsOf: self.localCameraAssetArray.reversed())
            localAssets.append(contentsOf: self.localAssetArray)
            var photoAssets = [PhotoAsset]()
            photoAssets.reserveCapacity(assetCollection?.count ?? 0)
            var lastAsset: PhotoAsset?
            assetCollection?.enumerateAssets(usingBlock: { (photoAsset) in
                if photoAsset.mediaType == .photo {
                    if self.selectType == .video {
                        return
                    }
                    if self.config.showImageAnimated == true {
                        if photoAsset.phAsset!.isImageAnimated {
                            photoAsset.mediaSubType = .imageAnimated
                        }
                    }
                    if self.config.showLivePhoto == true {
                        if photoAsset.phAsset!.isLivePhoto {
                            photoAsset.mediaSubType = .livePhoto
                        }
                    }
                }else if photoAsset.mediaType == .video {
                    if self.selectType == .photo {
                        return
                    }
                }
                var asset = photoAsset
                if selectedAssets.contains(asset.phAsset!) {
                    let index = selectedAssets.firstIndex(of: asset.phAsset!)!
                    let phAsset: PhotoAsset = selectedPhotoAssets[index]
                    asset = phAsset
                    lastAsset = phAsset
                }
                if self.config.reverseOrder == true {
                    photoAssets.insert(asset, at: 0)
                }else {
                    photoAssets.append(asset)
                }
            })
            if self.config.reverseOrder == true {
                photoAssets.insert(contentsOf: localAssets, at: 0)
            }else {
                photoAssets.append(contentsOf: localAssets.reversed())
            }
            DispatchQueue.main.async {
                completion(photoAssets, lastAsset)
            }
        }
    }
}

// MARK: ViewControllers function
extension PhotoPickerController {
    
    func configBackgroundColor() {
        view.backgroundColor = PhotoManager.isDark ? config.navigationViewBackgroudDarkColor : config.navigationViewBackgroundColor
    }
    func finishCallback() {
        pickerControllerDelegate?.pickerController?(self, didFinishSelection: selectedAssetArray, isOriginal)
        dismiss(animated: true, completion: nil)
    }
    func singleFinishCallback(for photoAsset: PhotoAsset) {
        pickerControllerDelegate?.pickerController?(self, singleFinishSelection: photoAsset, isOriginal)
        dismiss(animated: true, completion: nil)
    }
    func cancelCallback() {
        pickerControllerDelegate?.pickerController?(didCancel: self)
        dismiss(animated: true, completion: nil)
    }
    func originalButtonCallback() {
        pickerControllerDelegate?.pickerController?(self, didOriginalButton: isOriginal)
    }
    func shouldPresentCamera() -> Bool {
        if let shouldPresent = pickerControllerDelegate?.pickerController?(shouldPresentCamera: self) {
            return shouldPresent
        }
        return true
    }
    func previewUpdateCurrentlyDisplayedAsset(photoAsset: PhotoAsset, index: Int) {
        pickerControllerDelegate?.pickerController?(self, previewUpdateCurrentlyDisplayedAsset: photoAsset, atIndex: index)
    }
    func shouldClickCell(photoAsset: PhotoAsset, index: Int) -> Bool {
        if let shouldClick = pickerControllerDelegate?.pickerController?(self, shouldClickCell: photoAsset, atIndex: index) {
            return shouldClick
        }
        return true
    }
    func shouldEditAsset(photoAsset: PhotoAsset, atIndex: Int) -> Bool {
        if let shouldEditAsset = pickerControllerDelegate?.pickerController?(self, shouldEditAsset: photoAsset, atIndex: atIndex) {
            return shouldEditAsset
        }
        return true
    }
    func didEditAsset(photoAsset: PhotoAsset, atIndex: Int) {
        pickerControllerDelegate?.pickerController?(self, didEditAsset: photoAsset, atIndex: atIndex)
    }
    func previewShouldDeleteAsset(photoAsset: PhotoAsset, index: Int) -> Bool {
        if let previewShouldDeleteAsset = pickerControllerDelegate?.pickerController?(self, previewShouldDeleteAsset: photoAsset, atIndex: index) {
            return previewShouldDeleteAsset
        }
        return true
    }
    func previewDidDeleteAsset(photoAsset: PhotoAsset, index: Int) {
        pickerControllerDelegate?.pickerController?(self, previewDidDeleteAsset: photoAsset, atIndex: index)
    }
    func viewControllersWillAppear(_ viewController: UIViewController) {
        pickerControllerDelegate?.pickerController?(self, viewControllersWillAppear: viewController)
    }
    func viewControllersDidAppear(_ viewController: UIViewController) {
        pickerControllerDelegate?.pickerController?(self, viewControllersDidAppear: viewController)
    }
    func viewControllersWillDisappear(_ viewController: UIViewController) {
        pickerControllerDelegate?.pickerController?(self, viewControllersWillDisappear: viewController)
    }
    func viewControllersDidDisappear(_ viewController: UIViewController) {
        pickerControllerDelegate?.pickerController?(self, viewControllersDidDisappear: viewController)
    }
    
    /// 获取已选资源的总大小
    /// - Parameters:
    ///   - isPreview: 是否是预览界面获取
    ///   - completion: 完成回调
    func requestSelectedAssetFileSize(isPreview: Bool, completion: @escaping (Int, String) -> Void) {
        cancelRequestAssetFileSize(isPreview: isPreview)
        let operation = BlockOperation.init {
            var totalFileSize = 0
            for photoAsset in self.selectedAssetArray {
                totalFileSize += photoAsset.fileSize
            }
            if isPreview {
                if let operation =
                    self.previewRequestAssetBytesQueue.operations.first {
                    if operation.isCancelled {
                        return
                    }
                }
            }else {
                if let operation =
                    self.requestAssetBytesQueue.operations.first {
                    if operation.isCancelled {
                        return
                    }
                }
            }
            DispatchQueue.main.async {
                completion(totalFileSize, PhotoTools.transformBytesToString(bytes: totalFileSize))
            }
        }
        if isPreview {
            previewRequestAssetBytesQueue.addOperation(operation)
        }else {
            requestAssetBytesQueue.addOperation(operation)
        }
    }
    
    /// 取消获取资源文件大小
    /// - Parameter isPreview: 是否预览界面
    func cancelRequestAssetFileSize(isPreview: Bool) {
        if isPreview {
            previewRequestAssetBytesQueue.cancelAllOperations()
        }else {
            requestAssetBytesQueue.cancelAllOperations()
        }
    }
    
    /// 更新相册资源
    /// - Parameters:
    ///   - coverImage: 封面图片
    ///   - count: 需要累加的数量
    func updateAlbums(coverImage: UIImage?, count: Int) {
        for assetCollection in assetCollectionsArray {
            if assetCollection.realCoverImage != nil {
                assetCollection.realCoverImage = coverImage
            }
            assetCollection.count += count
        }
        reloadAlbumData()
    }
    func addedLocalCameraAsset(photoAsset: PhotoAsset) {
        photoAsset.localIndex = localCameraAssetArray.count
        localCameraAssetArray.append(photoAsset)
    }
    func addedPhotoAsset(photoAsset: PhotoAsset) -> Bool {
        if singleVideo && photoAsset.mediaType == .video {
            return false
        }
        if config.selectMode == .single {
            // 单选模式不可添加
            return false
        }
        if selectedAssetArray.contains(photoAsset) {
            photoAsset.isSelected = true
            return true
        }
        let canSelect = canSelectAsset(for: photoAsset, showHUD: true)
        if canSelect {
            pickerControllerDelegate?.pickerController?(self, willSelectAsset: photoAsset, atIndex: selectedAssetArray.count)
            canAddAsset = false
            photoAsset.isSelected = true
            photoAsset.selectIndex = selectedAssetArray.count
            if photoAsset.mediaType == .photo {
                selectedPhotoAssetArray.append(photoAsset)
            }else if photoAsset.mediaType == .video {
                selectedVideoAssetArray.append(photoAsset)
            }
            selectedAssetArray.append(photoAsset)
            pickerControllerDelegate?.pickerController?(self, didSelectAsset: photoAsset, atIndex: selectedAssetArray.count - 1)
        }
        return canSelect
    }
    func removePhotoAsset(photoAsset: PhotoAsset) -> Bool {
        if selectedAssetArray.isEmpty || !selectedAssetArray.contains(photoAsset) {
            return false
        }
        canAddAsset = false
        pickerControllerDelegate?.pickerController?(self, willUnselectAsset: photoAsset, atIndex: selectedAssetArray.count)
        photoAsset.isSelected = false
        if photoAsset.mediaType == .photo {
            selectedPhotoAssetArray.remove(at: selectedPhotoAssetArray.firstIndex(of: photoAsset)!)
        }else if photoAsset.mediaType == .video {
            selectedVideoAssetArray.remove(at: selectedVideoAssetArray.firstIndex(of: photoAsset)!)
        }
        selectedAssetArray.remove(at: selectedAssetArray.firstIndex(of: photoAsset)!)
        for (index, asset) in selectedAssetArray.enumerated() {
            asset.selectIndex = index
        }
        pickerControllerDelegate?.pickerController?(self, didUnselectAsset: photoAsset, atIndex: selectedAssetArray.count)
        return true
    }
    func canSelectAsset(for photoAsset: PhotoAsset, showHUD: Bool) -> Bool {
        var canSelect = true
        var text: String?
        if photoAsset.mediaType == .photo {
            if config.maximumSelectedPhotoFileSize > 0 {
                if photoAsset.fileSize > config.maximumSelectedPhotoFileSize {
                    text = "照片大小超过最大限制".localized + PhotoTools.transformBytesToString(bytes: config.maximumSelectedPhotoFileSize)
                    canSelect = false
                }
            }
            if !config.allowSelectedTogether {
                if selectedVideoAssetArray.count > 0 {
                    text = "照片和视频不能同时选择".localized
                    canSelect = false
                }
            }
            if config.maximumSelectedPhotoCount > 0 {
                if selectedPhotoAssetArray.count >= config.maximumSelectedPhotoCount {
                    text = String.init(format: "最多只能选择%d张照片".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }else {
                if selectedAssetArray.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0 {
                    text = String.init(format: "已达到最大选择数".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }
        }else if photoAsset.mediaType == .video {
            if config.maximumSelectedVideoFileSize > 0 {
                if photoAsset.fileSize > config.maximumSelectedVideoFileSize {
                    text = "视频大小超过最大限制".localized + PhotoTools.transformBytesToString(bytes: config.maximumSelectedVideoFileSize)
                    canSelect = false
                }
            }
            if config.maximumSelectedVideoDuration > 0 {
                if round(photoAsset.videoDuration) > Double(config.maximumSelectedVideoDuration) {
                    text = String.init(format: "视频最大时长为%d秒，无法选择".localized, arguments: [config.maximumSelectedVideoDuration])
                    canSelect = false
                }
            }
            if config.minimumSelectedVideoDuration > 0 {
                if round(photoAsset.videoDuration) < Double(config.minimumSelectedVideoDuration) {
                    text = String.init(format: "视频最小时长为%d秒，无法选择".localized, arguments: [config.minimumSelectedVideoDuration])
                    canSelect = false
                }
            }
            if !config.allowSelectedTogether {
                if selectedPhotoAssetArray.count > 0 {
                    text = "视频和照片不能同时选择".localized
                    canSelect = false
                }
            }
            if config.maximumSelectedVideoCount > 0 {
                if selectedVideoAssetArray.count >= config.maximumSelectedVideoCount {
                    text = String.init(format: "最多只能选择%d个视频".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }else {
                if selectedAssetArray.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0 {
                    text = String.init(format: "已达到最大选择数".localized, arguments: [config.maximumSelectedPhotoCount])
                    canSelect = false
                }
            }
        }
        if let shouldSelect = pickerControllerDelegate?.pickerController?(self, shouldSelectedAsset: photoAsset, atIndex: selectedAssetArray.count) {
            if canSelect {
                canSelect = shouldSelect
            }
        }
        if !canSelect && text != nil && showHUD {
            ProgressHUD.showWarningHUD(addedTo: view, text: text!, animated: true, delay: 1.5)
        }
        return canSelect
    }
    func selectArrayIsFull() -> Bool {
        if selectedAssetArray.count >= config.maximumSelectedCount && config.maximumSelectedCount > 0 {
            return true
        }
        return false
    }
}

// MARK: Private function
extension PhotoPickerController {
    private func setOptions() {
        if selectType == .photo {
            options.predicate = NSPredicate.init(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.image.rawValue])
        }else if selectType == .video {
            options.predicate = NSPredicate.init(format: "mediaType == %ld", argumentArray: [PHAssetMediaType.video.rawValue])
        }else {
            options.predicate = nil
        }
    }
    private func configColor() {
        if config.appearanceStyle == .normal {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        }
        if modalPresentationStyle != .custom {
            configBackgroundColor()
        }
        let isDark = PhotoManager.isDark
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : isDark ? config.navigationTitleDarkColor : config.navigationTitleColor]
        navigationBar.tintColor = isDark ? config.navigationDarkTintColor : config.navigationTintColor
        navigationBar.barStyle = isDark ? config.navigationBarDarkStyle : config.navigationBarStyle
    }
    private func requestAuthorization() {
        if !config.allowLoadPhotoLibrary {
            fetchCameraAssetCollection()
            return
        }
        let status = AssetManager.authorizationStatus()
        if status.rawValue >= 3 {
            // 有权限
            fetchData(status: status)
        }else if status.rawValue >= 1 {
            // 无权限
            view.addSubview(deniedView)
        }else {
            // 用户还没做出选择，请求权限
            isFirstAuthorization = true
            AssetManager.requestAuthorization { (status) in
                self.fetchData(status: status)
                self.albumViewController()?.updatePrompt()
                self.pickerViewController()?.reloadAlbumData()
                self.pickerViewController()?.updateBottomPromptView()
            }
        }
    }
    private func fetchData(status: PHAuthorizationStatus) {
        if status.rawValue >= 3 {
            PHPhotoLibrary.shared().register(self)
            // 有权限
            _ = ProgressHUD.showLoadingHUD(addedTo: view, afterDelay: 0.15, animated: true)
            fetchCameraAssetCollection()
        }else if status.rawValue >= 1 {
            // 无权限
            view.addSubview(deniedView)
        }
    }
    private func configSelectedArray() {
        if isPreviewAsset {
            previewViewController()?.previewAssets = selectedAssetArray
            return
        }
        if config.selectMode == .single {
            return
        }
        if !canAddAsset {
            canAddAsset = true
            return
        }
        for photoAsset in selectedAssetArray {
            if photoAsset.mediaType == .photo {
                selectedPhotoAssetArray.append(photoAsset)
            }else if photoAsset.mediaType == .video {
                if singleVideo {
                    selectedAssetArray.remove(at: selectedAssetArray.firstIndex(of: photoAsset)!)
                }else {
                    selectedVideoAssetArray.append(photoAsset)
                }
            }
        }
    }
    private func getViewController(for viewControllerClass: UIViewController.Type) -> UIViewController? {
        for viewController in viewControllers {
            if viewController.isMember(of: viewControllerClass) {
                return viewController
            }
        }
        return nil
    }
    private func didDismiss() {
        var cameraAssetArray: [PhotoAsset] = []
        for photoAsset in localCameraAssetArray {
            cameraAssetArray.append(photoAsset.copyCamera())
        }
        pickerControllerDelegate?.pickerController?(self, didDismissComplete: cameraAssetArray)
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotoPickerController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        if !AssetManager.authorizationStatusIsLimited() || !config.allowLoadPhotoLibrary {
            return
        }
        var needReload = false
        if assetCollectionsArray.isEmpty {
            if cameraAssetCollection != nil {
                needReload = resultHasChanges(for: changeInstance, assetCollection: cameraAssetCollection!)
            }else {
                needReload = true
            }
        }else {
            let collectionArray = assetCollectionsArray
            for assetCollection in collectionArray {
                let hasChanges = resultHasChanges(for: changeInstance, assetCollection: assetCollection)
                if !needReload {
                    needReload = hasChanges;
                }
            }
        }
        if needReload {
            DispatchQueue.main.async {
                if self.cameraAssetCollection?.result == nil {
                    self.fetchCameraAssetCollection()
                }else {
                    self.reloadData(assetCollection: nil)
                }
                self.fetchAssetCollections()
            }
        }
    }
    private func resultHasChanges(for changeInstance:PHChange, assetCollection: PhotoAssetCollection) -> Bool {
        if assetCollection.result == nil {
            if assetCollection == self.cameraAssetCollection {
                return true
            }
            return false
        }
        let changeResult : PHFetchResultChangeDetails? = changeInstance.changeDetails(for: assetCollection.result!)
        if changeResult != nil {
            if !changeResult!.hasIncrementalChanges {
                let result = changeResult!.fetchResultAfterChanges
                assetCollection.changeResult(for: result)
                if assetCollection == self.cameraAssetCollection && result.count == 0 {
                    assetCollection.change(albumName: self.config.albumList.emptyAlbumName.localized, coverImage: self.config.albumList.emptyCoverImageName.image)
                    assetCollection.count = 0
                    assetCollection.coverAsset = nil
                }else {
                    assetCollection.fetchCoverAsset()
                }
                return true
            }
        }
        return false
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension PhotoPickerController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PickerTransition.init(type: .present)
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PickerTransition.init(type: .dismiss)
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let canInteration = interactiveTransition?.canInteration, canInteration {
            return interactiveTransition
        }
        return nil
    }
}
