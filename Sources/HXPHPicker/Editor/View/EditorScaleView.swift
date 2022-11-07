//
//  EditorScaleView.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/2.
//

import UIKit

class EditorScaleView: UIView {
    
    lazy var shadeView: UIView = {
        let view = UIView()
        view.addSubview(collectionView)
        view.layer.mask = shadeMaskLayer
        return view
    }()
    
    lazy var shadeMaskLayer: CAGradientLayer = {
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 1)
        maskLayer.endPoint = CGPoint(x: 1, y: 1)
        maskLayer.locations = [0.0, 0.1, 0.9, 1.0]
        return maskLayer
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EditorScaleViewCell.self, forCellWithReuseIdentifier: "EditorScaleViewCellId")
        collectionView.decelerationRate = .fast
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    lazy var centerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var valueLb: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    var angleChanged: ((CGFloat) -> Void)?
    
    var offsetScale: CGFloat {
        let offsetX = collectionView.contentOffset.x + collectionView.contentInset.left
        let contentWidth = (collectionView.contentSize.width - 1) * 0.5
        let offsetScale = (offsetX / contentWidth) - 1
        return offsetScale
    }
    
    var centerOffsetX: CGFloat {
        (collectionView.contentSize.width - 1) * 0.5 - collectionView.contentInset.left
    }
    
    var count: Int = 47
    
    var centerIndex: Int = 23
    
    var centerCell: EditorScaleViewCell? {
        collectionView.cellForItem(at: .init(item: 0, section: centerIndex)) as? EditorScaleViewCell
    }
    
    var angle: CGFloat {
        min(max(-45, offsetScale * 45), 45)
    }
    
    var scale: Int {
        min(max(-45, Int(round(offsetScale * 45))), 45)
    }
    
    var currentIndex: Int = 0
    
    var themeColor: UIColor = .systemTintColor
    
    var padding: CGFloat {
        if UIDevice.isPortrait && !UIDevice.isPad {
            return 5
        }
        return width / CGFloat(count) / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isAngleChange = false
    
    func initView() {
        addSubview(valueLb)
        addSubview(shadeView)
        addSubview(centerLineView)
        DispatchQueue.main.async {
            self.currentIndex = self.centerIndex
            self.collectionView.contentOffset.x = self.centerOffsetX
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadeView.frame = .init(x: 0, y: 0, width: width, height: 30)
        collectionView.frame = shadeView.bounds
        shadeMaskLayer.frame = CGRect(x: 0, y: 0, width: shadeView.width, height: shadeView.height)
        let margin: CGFloat
        let contentWidth = collectionView.contentSize.width
        if contentWidth > width {
            margin = width * 0.5 - 0.5
        }else {
            margin = (contentWidth * 0.5 + (width - contentWidth) * 0.5) - 0.5
        }
        collectionView.contentInset.left = margin
        collectionView.contentInset.right = margin
        
        centerLineView.size = .init(width: 1, height: 25)
        centerLineView.centerX = width * 0.5
        centerLineView.y = collectionView.y + (collectionView.height - 20) * 0.5 + 20 - centerLineView.height
        
        valueLb.width = width
        valueLb.y = centerLineView.frame.maxY + 2
        valueLb.height = 15
    }
}

extension EditorScaleView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditorScaleViewCellId", for: indexPath) as! EditorScaleViewCell
        cell.isShowPoint = indexPath.section == centerIndex
        cell.isOriginal = (indexPath.section == centerIndex ||
                           indexPath.section == 0 ||
                           indexPath.section == count - 1)
        cell.isBold = cell.isOriginal ? true : (indexPath.section + 2) % 5 == 0
        cell.update()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 1, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || section == count - 1 {
            return .zero
        }
        return .init(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = centerLineView.convert(.init(x: centerLineView.width * 0.5, y: centerLineView.height * 0.5), to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            if currentIndex != indexPath.section {
                let shake = UIImpactFeedbackGenerator(style: .light)
                shake.prepare()
                if #available(iOS 13.0, *) {
                    shake.impactOccurred(intensity: 0.6)
                } else {
                    shake.impactOccurred()
                }
            }
            currentIndex = indexPath.section
        }else {
            currentIndex = -1
        }
        valueLb.text = String(scale)
        if isAngleChange {
            angleChanged?(angle)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isAngleChange = true
        UIView.animate(withDuration: 0.2) {
            self.centerLineView.backgroundColor = self.themeColor
        }
        centerCell?.showPoint()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDidStop()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidStop()
    }
    
    func scrollDidStop() {
        isAngleChange = false
        if offsetScale >= -0.02 && offsetScale <= 0.02 {
            collectionView.setContentOffset(.init(x: centerOffsetX, y: 0), animated: false)
            angleChanged?(angle)
        }
        UIView.animate(withDuration: 0.25) {
            self.centerLineView.backgroundColor = .white
        }
        if currentIndex == centerIndex {
            centerCell?.hidePoint()
        }
    }
}

extension EditorScaleView {
    struct Scale {
        let value: CGFloat
    }
}

class EditorScaleViewCell: UICollectionViewCell {
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var pointView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0
        view.backgroundColor = .white
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()
    var isShowPoint: Bool = false {
        didSet {
            pointView.isHidden = !isShowPoint
        }
    }
    
    func showPoint(_ isAnimation: Bool = true) {
        if !isAnimation {
            pointView.alpha = 1
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.pointView.alpha = 1
        }
    }
    
    func hidePoint(_ isAnimation: Bool = true) {
        if !isAnimation {
            pointView.alpha = 0
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.pointView.alpha = 0
        }
    }
    
    var isBold: Bool = false
    var isOriginal: Bool = false
    
    func update() {
        lineView.backgroundColor = isBold ? .white : .white.withAlphaComponent(0.6)
        updateLineView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        contentView.addSubview(pointView)
        contentView.addSubview(lineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLineView()
    }
    
    func updateLineView() {
        pointView.y = -5
        pointView.size = .init(width: 6, height: 6)
        pointView.centerX = width * 0.5
        lineView.size = .init(width: 1, height: isOriginal ? 15 : 10)
        lineView.centerX = width * 0.5
        lineView.y = height - lineView.height
    }
}
