//
//  HXVideoEditorCropConfirmView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit

protocol HXVideoEditorCropConfirmViewDelegate: NSObjectProtocol {
    func cropConfirmView(didFinishButtonClick cropConfirmView: HXVideoEditorCropConfirmView)
    func cropConfirmView(didCancelButtonClick cropConfirmView: HXVideoEditorCropConfirmView)
}
class HXVideoEditorCropConfirmView: UIView {
    weak var delegate: HXVideoEditorCropConfirmViewDelegate?
    var config: HXVideoCropConfirmViewConfiguration
    lazy var maskLayer: CAGradientLayer = {
        let layer = CAGradientLayer.init()
        layer.contentsScale = UIScreen.main.scale
        let blackColor = UIColor.black
        layer.colors = [blackColor.withAlphaComponent(0).cgColor,
                        blackColor.withAlphaComponent(0.15).cgColor,
                        blackColor.withAlphaComponent(0.35).cgColor,
                        blackColor.withAlphaComponent(0.6).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.locations = [0.15, 0.35, 0.6, 0.9]
        layer.borderWidth = 0.0
        return layer
    }()
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton.init(type: .custom)
        cancelButton.setTitle("取消".localized, for: .normal)
        cancelButton.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        cancelButton.layer.cornerRadius = 3
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(didCancelButtonClick(button:)), for: .touchUpInside)
        return cancelButton
    }()
    
    lazy var finishButton: UIButton = {
        let finishButton = UIButton.init(type: .custom)
        finishButton.setTitle("完成".localized, for: .normal)
        finishButton.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        finishButton.layer.cornerRadius = 3
        finishButton.layer.masksToBounds = true
        finishButton.addTarget(self, action: #selector(didFinishButtonClick(button:)), for: .touchUpInside)
        return finishButton
    }()
    @objc func didFinishButtonClick(button: UIButton) {
        delegate?.cropConfirmView(didFinishButtonClick: self)
    }
    @objc func didCancelButtonClick(button: UIButton) {
        delegate?.cropConfirmView(didCancelButtonClick: self)
    }
    init(config: HXVideoCropConfirmViewConfiguration) {
        self.config = config
        super.init(frame: .zero)
        layer.addSublayer(maskLayer)
        addSubview(finishButton)
        addSubview(cancelButton)
        configColor()
    }
    func configColor() {
        let isDark = HXPHManager.isDark
        finishButton.setTitleColor(isDark ? config.finishButtonTitleDarkColor : config.finishButtonTitleColor, for: .normal)
        finishButton.setBackgroundImage(UIImage.image(for: isDark ? config.finishButtonDarkBackgroundColor : config.finishButtonBackgroundColor, havingSize: .zero), for: .normal)
        cancelButton.setTitleColor(isDark ? config.cancelButtonTitleDarkColor : config.cancelButtonTitleColor, for: .normal)
        cancelButton.setBackgroundImage(UIImage.image(for: isDark ? config.cancelButtonDarkBackgroundColor : config.cancelButtonBackgroundColor, havingSize: .zero), for: .normal)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.x = UIDevice.leftMargin + 12
        var cancelWidth = (cancelButton.currentTitle?.width(ofFont: cancelButton.titleLabel!.font, maxHeight: 33) ?? 0) + 20
        if cancelWidth < 60 {
            cancelWidth = 60
        }
        cancelButton.width = cancelWidth
        cancelButton.height = 33
        cancelButton.centerY = 25
        
        var finishWidth = (finishButton.currentTitle?.width(ofFont: finishButton.titleLabel!.font, maxHeight: 33) ?? 0) + 20
        if finishWidth < 60 {
            finishWidth = 60
        }
        finishButton.width = finishWidth
        finishButton.height = 33
        finishButton.x = width - finishButton.width - 12 - UIDevice.rightMargin
        finishButton.centerY = 25
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
