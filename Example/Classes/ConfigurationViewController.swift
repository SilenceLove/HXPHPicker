//
//  ConfigurationViewController.swift
//  HXPHPickerExample
//
//  Created by Slience on 2020/12/23.
//  Copyright © 2020 Slience. All rights reserved.
//

import UIKit
import HXPHPicker

protocol ConfigurationViewControllerDelegate: NSObjectProtocol {
    func ConfigurationViewControllerDidSave(_ config: PickerConfiguration)
}

class ConfigurationViewController: UIViewController, UIScrollViewDelegate {
    weak var delegate: ConfigurationViewControllerDelegate?
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var languageControl: UISegmentedControl!
    @IBOutlet weak var selectTypeControl: UISegmentedControl!
    @IBOutlet weak var selectModeControl: UISegmentedControl!
    @IBOutlet weak var albumShowModeControl: UISegmentedControl!
    @IBOutlet weak var appearanceStyleControl: UISegmentedControl!
    @IBOutlet weak var allowTogetherSelectedSwitch: UISwitch!
    @IBOutlet weak var allowLoadPhotoLibrarySwitch: UISwitch!
    @IBOutlet weak var createdDateSwitch: UISwitch!
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var photoListAddCameraSwitch: UISwitch!
    @IBOutlet weak var showGifControl: UISwitch!
    @IBOutlet weak var showLivePhotoSwitch: UISwitch!
    @IBOutlet weak var photoMaxField: UITextField!
    @IBOutlet weak var videoMaxField: UITextField!
    @IBOutlet weak var totalMaxField: UITextField!
    @IBOutlet weak var videoMinDurationField: UITextField!
    @IBOutlet weak var videoMaxDurationField: UITextField!
    @IBOutlet weak var photoMaxFileSizeField: UITextField!
    @IBOutlet weak var videoMaxFileSizeField: UITextField!
    @IBOutlet weak var saveAlbumSwitch: UISwitch!
    @IBOutlet weak var customAlbumNameField: UITextField!
    
    var config: PickerConfiguration
    
    init(config: PickerConfiguration) {
        self.config = config
        super.init(nibName:"ConfigurationViewController",bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        languageControl.selectedSegmentIndex = config.languageType.rawValue
        if config.selectOptions.isPhoto && config.selectOptions.isVideo {
            selectTypeControl.selectedSegmentIndex = 2
        }else if config.selectOptions.isPhoto {
            selectTypeControl.selectedSegmentIndex = 0
        }else {
            selectTypeControl.selectedSegmentIndex = 1
        }
        
        selectModeControl.selectedSegmentIndex = config.selectMode.rawValue
        albumShowModeControl.selectedSegmentIndex = config.albumShowMode.rawValue
        appearanceStyleControl.selectedSegmentIndex = config.appearanceStyle.rawValue
        allowTogetherSelectedSwitch.isOn = config.allowSelectedTogether
        allowLoadPhotoLibrarySwitch.isOn = config.allowLoadPhotoLibrary
        createdDateSwitch.isOn = config.creationDate
        sortControl.selectedSegmentIndex = config.reverseOrder ? 1 : 0
        photoListAddCameraSwitch.isOn = config.photoList.allowAddCamera
        showGifControl.isOn = config.selectOptions.contains(.gifPhoto)
        showLivePhotoSwitch.isOn = config.selectOptions.contains(.livePhoto)
        photoMaxField.text = String(config.maximumSelectedPhotoCount)
        videoMaxField.text = String(config.maximumSelectedVideoCount)
        totalMaxField.text = String(config.maximumSelectedCount)
        videoMinDurationField.text = String(config.minimumSelectedVideoDuration)
        videoMaxDurationField.text = String(config.maximumSelectedVideoDuration)
        photoMaxFileSizeField.text = String(config.maximumSelectedPhotoFileSize)
        videoMaxFileSizeField.text = String(config.maximumSelectedVideoFileSize)
        saveAlbumSwitch.isOn = config.photoList.saveSystemAlbum
        customAlbumNameField.text = config.photoList.customAlbumName
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: .done, target: self, action: #selector(didCancelButtonClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .done, target: self, action: #selector(didSaveButtonClick))
        if let nav = navigationController {
            if nav.modalPresentationStyle == .fullScreen {
                topMarginConstraint.constant = UIDevice.navigationBarHeight + 5
            }else {
                topMarginConstraint.constant = nav.navigationBar.height + 5
            }
        }
    }
    @objc func didCancelButtonClick() {
        dismiss(animated: true, completion: nil)
    }
    @objc func didSaveButtonClick() {
        config.languageType = LanguageType.init(rawValue: languageControl.selectedSegmentIndex)!
        switch selectTypeControl.selectedSegmentIndex {
        case 0:
            config.selectOptions = .photo
        case 1:
            config.selectOptions = .video
            showGifControl.isOn = false
            showLivePhotoSwitch.isOn = false
        case 2:
            config.selectOptions = [.video, .photo]
        default:
            break
        }
        config.selectMode = PickerSelectMode.init(rawValue: selectModeControl.selectedSegmentIndex)!
        config.albumShowMode = AlbumShowMode.init(rawValue: albumShowModeControl.selectedSegmentIndex)!
        config.appearanceStyle = AppearanceStyle.init(rawValue: appearanceStyleControl.selectedSegmentIndex)!
        config.allowSelectedTogether = allowTogetherSelectedSwitch.isOn
        config.allowLoadPhotoLibrary = allowLoadPhotoLibrarySwitch.isOn
        config.creationDate = createdDateSwitch.isOn
        config.reverseOrder = sortControl.selectedSegmentIndex == 1
        config.photoList.allowAddCamera = photoListAddCameraSwitch.isOn
        if showGifControl.isOn {
            config.selectOptions.insert(.gifPhoto)
        }else {
            config.selectOptions.remove(.gifPhoto)
        }
        if showLivePhotoSwitch.isOn {
            config.selectOptions.insert(.livePhoto)
        }else {
            config.selectOptions.remove(.livePhoto)
        }
        
        config.maximumSelectedPhotoCount = Int(photoMaxField.text ?? "0") ?? 0
        config.maximumSelectedVideoCount = Int(videoMaxField.text ?? "0") ?? 0
        config.maximumSelectedCount = Int(totalMaxField.text ?? "0") ?? 0
        config.minimumSelectedVideoDuration = Int(videoMinDurationField.text ?? "0") ?? 0
        config.maximumSelectedVideoDuration = Int(videoMaxDurationField.text ?? "0") ?? 0
        config.maximumSelectedPhotoFileSize = Int(photoMaxFileSizeField.text ?? "0") ?? 0
        config.maximumSelectedVideoFileSize = Int(videoMaxFileSizeField.text ?? "0") ?? 0
        config.photoList.saveSystemAlbum = saveAlbumSwitch.isOn
        config.photoList.customAlbumName = customAlbumNameField.text
        
        delegate?.ConfigurationViewControllerDidSave(config)
        dismiss(animated: true, completion: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    required init?(coder aDecoder: NSCoder) {
        self.config = PickerConfiguration()
        super.init(coder: aDecoder)
    }
}
