//
//  PhotoEditorFilterView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/23.
//

import UIKit
import CoreImage
#if canImport(Harbeth)
import Harbeth
#endif

protocol PhotoEditorFilterViewDelegate: AnyObject {
    func filterView(shouldSelectFilter filterView: PhotoEditorFilterView) -> Bool
    func filterView(_ filterView: PhotoEditorFilterView, didSelected filter: PhotoEditorFilter, atItem: Int)
    
    func filterView(_ filterView: PhotoEditorFilterView, didSelectedParameter filter: PhotoEditorFilter, at index: Int)
    
    func filterView(_ filterView: PhotoEditorFilterView, didSelectedEdit editModel: PhotoEditorFilterEditModel)
}

class PhotoEditorFilterView: UIView {
    
    weak var delegate: PhotoEditorFilterViewDelegate?
    
    lazy var backgroundView: UIVisualEffectView = {
        let visualEffect = UIBlurEffect.init(style: .dark)
        let view = UIVisualEffectView.init(effect: visualEffect)
        view.contentView.addSubview(collectionView)
        view.contentView.addSubview(editView)
        #if canImport(Harbeth)
        view.contentView.addSubview(bottomView)
        #endif
        return view
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 60, height: 90)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 0, height: 50),
            collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(
            PhotoEditorFilterViewCell.self,
            forCellWithReuseIdentifier: "PhotoEditorFilterViewCellID"
        )
        return collectionView
    }()
    
    lazy var editView: PhotoEditorFilterEditView = {
        let view = PhotoEditorFilterEditView()
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.addSubview(filterButton)
        view.addSubview(editButton)
        view.addSubview(bottomLineView)
        return view
    }()
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = filterConfig.selectedColor
        view.height = 2
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("滤镜".localized, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(didFilterButtonClick), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.isEnabled = false
        return button
    }()
    
    @objc
    func didFilterButtonClick() {
        filterButton.isEnabled = false
        editButton.isEnabled = true
        UIView.animate(withDuration: 0.25) {
            self.setupBottomLineViewFrame()
        }
    }
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("画面调整".localized, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.addTarget(self, action: #selector(didEditButtonClick), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    @objc
    func didEditButtonClick() {
        editButton.isEnabled = false
        filterButton.isEnabled = true
        UIView.animate(withDuration: 0.25) {
            self.setupBottomLineViewFrame()
        }
    }
    
    var filters: [PhotoEditorFilter] = []
    
    var image: UIImage? = nil {
        didSet {
            collectionView.reloadData()
            scrollToSelectedCell()
        }
    }
    
    
    var currentSelectedIndex: Int
    let filterConfig: PhotoEditorConfiguration.Filter
    init(
        filterConfig: PhotoEditorConfiguration.Filter,
        hasLastFilter: Bool,
        isVideo: Bool = false
    ) {
        self.filterConfig = filterConfig
        let originalFilter = PhotoEditorFilter(
            filterName: isVideo ? "原片".localized : "原图".localized
        )
        originalFilter.isOriginal = true
        originalFilter.isSelected = true
        filters.append(originalFilter)
        currentSelectedIndex = 0
        super.init(frame: .zero)
        if hasLastFilter {
            originalFilter.isSelected = false
            currentSelectedIndex = -1
        }
        for filterInfo in filterConfig.infos {
            var parameters: [PhotoEditorFilterParameterInfo] = []
            for parameter in filterInfo.parameters {
                parameters.append(.init(parameter: parameter))
            }
            let filter = PhotoEditorFilter(
                filterName: filterInfo.filterName,
                parameters: parameters
            )
            filters.append(filter)
        }
        addSubview(backgroundView)
    }
    func reloadData() {
        currentSelectedCell()?.updateParameter()
        editView.reloadData()
    }
    func scrollToSelectedCell() {
        if currentSelectedIndex > 0 {
            collectionView.scrollToItem(
                at: IndexPath(
                    item: currentSelectedIndex,
                    section: 0
                ),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
    func currentSelectedCell() -> PhotoEditorFilterViewCell? {
        collectionView.cellForItem(at: IndexPath(item: currentSelectedIndex, section: 0)) as? PhotoEditorFilterViewCell
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        collectionView.frame = CGRect(x: 0, y: 0, width: width, height: 120)
        flowLayout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 15 + UIDevice.leftMargin,
            bottom: 0,
            right: 15 + UIDevice.rightMargin
        )
        editView.frame = .init(x: 0, y: 0, width: width, height: 120)
        bottomView.frame = CGRect(x: 0, y: collectionView.frame.maxY, width: width, height: 30)
        filterButton.frame = .init(x: 0, y: 0, width: width * 0.5, height: 30)
        editButton.frame = .init(x: width * 0.5, y: 0, width: width * 0.5, height: 30)
        bottomLineView.y = filterButton.height
        setupBottomLineViewFrame()
    }
    
    func setupBottomLineViewFrame() {
        if !filterButton.isEnabled {
            bottomLineView.width = (filterButton.titleLabel?.textWidth ?? 0) + 2
            bottomLineView.centerX = filterButton.centerX
            collectionView.isHidden = false
            editView.isHidden = true
        }else {
            bottomLineView.width = (editButton.titleLabel?.textWidth ?? 0) + 2
            bottomLineView.centerX = editButton.centerX
            collectionView.isHidden = true
            editView.isHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEditorFilterView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoEditorFilterViewCellID",
            for: indexPath
        ) as! PhotoEditorFilterViewCell
        cell.delegate = self
        let filter = filters[indexPath.item]
        if filter.isOriginal {
            cell.imageView.image = image
        }
        cell.selectedColor = filterConfig.selectedColor
        cell.filter = filter
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let shouldSelect = delegate?.filterView(shouldSelectFilter: self), !shouldSelect {
            return
        }
        if currentSelectedIndex == indexPath.item {
            return
        }
        if currentSelectedIndex >= 0 {
            let currentFilter = filters[currentSelectedIndex]
            currentFilter.sourceIndex = 0
            currentFilter.isSelected = false
        }
        if let currentCell = collectionView.cellForItem(
            at: IndexPath(
                item: currentSelectedIndex,
                section: 0
            )
        ) as? PhotoEditorFilterViewCell {
            currentCell.updateSelectedView(true)
            currentCell.updateParameter()
        }else {
            collectionView.reloadItems(at: [IndexPath(item: currentSelectedIndex, section: 0)])
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoEditorFilterViewCell {
            cell.filter.isSelected = true
            cell.filter.sourceIndex = indexPath.item - 1
            cell.updateSelectedView(false)
            cell.updateParameter()
            delegate?.filterView(self, didSelected: cell.filter, atItem: indexPath.item - 1)
        }
        currentSelectedIndex = indexPath.item
    }
}

extension PhotoEditorFilterView: PhotoEditorFilterViewCellDelegate {
    func filterViewCell(fetchFilter cell: PhotoEditorFilterViewCell) -> UIImage? {
        guard let index = filters.firstIndex(of: cell.filter) else {
            return nil
        }
        let filterInfo = filterConfig.infos[index - 1]
        if let handler = filterInfo.filterHandler, let image = image?.ci_Image {
            return handler(
                image,
                cell.imageView.image,
                cell.filter.parameters,
                true
            )?.image
        }else {
            #if canImport(Harbeth)
            if let filter = filterInfo.metalFilterHandler?(cell.filter.parameters.first, true) {
                return try? image?.make(filter: filter)
            }
            #endif
        }
        return nil
    }
    
    func filterViewCell(didEdit cell: PhotoEditorFilterViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        delegate?.filterView(self, didSelectedParameter: cell.filter, at: indexPath.item)
    }
}

extension PhotoEditorFilterView: PhotoEditorFilterEditViewDelegate {
    func filterEditView(
        _ filterEditView: PhotoEditorFilterEditView,
        didSelected editModel: PhotoEditorFilterEditModel
    ) {
        delegate?.filterView(self, didSelectedEdit: editModel)
    }
}

protocol PhotoEditorFilterViewCellDelegate: AnyObject {
    func filterViewCell(fetchFilter cell: PhotoEditorFilterViewCell) -> UIImage?
    func filterViewCell(didEdit cell: PhotoEditorFilterViewCell)
}

class PhotoEditorFilterViewCell: UICollectionViewCell {
    weak var delegate: PhotoEditorFilterViewCellDelegate?
    
    lazy var imageView: UIImageView = {
        let view = UIImageView.init()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var filterNameLb: UILabel = {
        let label = UILabel.init()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var selectedView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("hx_editor_tools_filter_edit".image, for: .normal)
        button.addTarget(self, action: #selector(didEditButtonClick), for: .touchUpInside)
        return button
    }()
    
    @objc
    func didEditButtonClick() {
        delegate?.filterViewCell(didEdit: self)
    }
    
    lazy var parameterLb: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    var selectedColor: UIColor? {
        didSet {
            selectedView.layer.borderColor = selectedColor?.cgColor
            selectedView.backgroundColor = selectedColor?.withAlphaComponent(0.25)
        }
    }
    var filter: PhotoEditorFilter! {
        didSet {
            updateFilter()
        }
    }
    
    func updateFilter() {
        filterNameLb.text = filter.filterName
        if !filter.isOriginal {
            imageView.image = delegate?.filterViewCell(fetchFilter: self)
        }
        updateSelectedView(!filter.isSelected)
        updateParameter()
    }
    
    func updateParameter() {
        if let para = filter.parameters.first, filter.isSelected {
            parameterLb.isHidden = false
            parameterLb.text = String(Int(para.value * 100))
        }else {
            parameterLb.isHidden = true
        }
    }
    
    func updateSelectedView(_ isHidden: Bool) {
        selectedView.isHidden = isHidden
        if !filter.parameters.isEmpty {
            editButton.isHidden = isHidden
        }else {
            editButton.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(selectedView)
        contentView.addSubview(editButton)
        contentView.addSubview(filterNameLb)
        contentView.addSubview(parameterLb)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 4, y: 4, width: width - 8, height: width - 8)
        editButton.frame = imageView.frame
        selectedView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        let filterNameY = imageView.frame.maxY + 12
        var filterNameHeight = filterNameLb.text?.height(ofFont: filterNameLb.font, maxWidth: width) ?? 15
        if filterNameHeight > height - filterNameY {
            filterNameHeight = height - filterNameY
        }
        filterNameLb.frame = CGRect(x: 0, y: filterNameY, width: width, height: filterNameHeight)
        parameterLb.y = filterNameLb.frame.maxY + 2
        parameterLb.width = width
        parameterLb.height = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoEditorFilterSlider: UISlider {
    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: 0, y: (bounds.height - 3) * 0.5, width: bounds.width, height: 3)
    }
    override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: 0, y: (bounds.height - 3) * 0.5, width: bounds.width, height: 3)
    }
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return CGRect(x: rect.minX, y: (bounds.height - 3) * 0.5, width: rect.width, height: 3)
    }
}

class PhotoEditorFilterEditModel: Equatable {
    
    enum `Type` {
        case brightness
        case contrast
        case saturation
        case warmth
        case vignette
        case sharpen
        
        var title: String {
            switch self {
            case .brightness:
                return "亮度".localized
            case .contrast:
                return "对比度".localized
            case .saturation:
                return "饱和度".localized
            case .warmth:
                return "色温".localized
            case .vignette:
                return "暗角".localized
            case .sharpen:
                return "锐化".localized
            }
        }
        
        var imageNamed: String {
            switch self {
            case .brightness:
                return "hx_editor_filter_edit_brightness"
            case .contrast:
                return "hx_editor_filter_edit_contrast"
            case .saturation:
                return "hx_editor_filter_edit_saturation"
            case .warmth:
                return "hx_editor_filter_edit_warmth"
            case .vignette:
                return "hx_editor_filter_edit_vignette"
            case .sharpen:
                return "hx_editor_filter_edit_sharpen"
            }
        }
    }
    
    let type: `Type`
    
    let parameters: [PhotoEditorFilterParameterInfo]
    
    init(
        type: `Type`,
        parameters: [PhotoEditorFilterParameterInfo]
    ) {
        self.type = type
        self.parameters = parameters
    }
    
    static func == (lhs: PhotoEditorFilterEditModel, rhs: PhotoEditorFilterEditModel) -> Bool {
        lhs === rhs
    }
}

protocol PhotoEditorFilterEditViewDelegate: AnyObject {
    func filterEditView(_ filterEditView: PhotoEditorFilterEditView, didSelected editModel: PhotoEditorFilterEditModel)
}

class PhotoEditorFilterEditView: UIView {
    
    weak var delegate: PhotoEditorFilterEditViewDelegate?
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 60, height: 90)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 0, height: 50),
            collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(
            PhotoEditorFilterEditViewCell.self,
            forCellWithReuseIdentifier: "PhotoEditorFilterEditViewCellID"
        )
        return collectionView
    }()
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    let models: [PhotoEditorFilterEditModel]
    
    init() {
        models = [
            .init(
                type: .brightness,
                parameters: [.init(parameter: .init(defaultValue: 0), sliderType: .center)]
            ),
            .init(
                type: .contrast,
                parameters: [.init(parameter: .init(defaultValue: 0), sliderType: .center)]
            ),
            .init(
                type: .saturation,
                parameters: [.init(parameter: .init(defaultValue: 0), sliderType: .center)]
            ),
            .init(
                type: .warmth,
                parameters: [.init(parameter: .init(defaultValue: 0), sliderType: .center)]
            ),
            .init(
                type: .vignette, parameters: [.init(parameter: .init(defaultValue: 0))]
            ),
            .init(
                type: .sharpen,
                parameters: [.init(parameter: .init(defaultValue: 0))]
            )
        ]
        super.init(frame: .zero)
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        flowLayout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 15 + UIDevice.leftMargin,
            bottom: 0,
            right: 15 + UIDevice.rightMargin
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoEditorFilterEditView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoEditorFilterEditViewCellID",
            for: indexPath
        ) as! PhotoEditorFilterEditViewCell
        cell.model = models[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        delegate?.filterEditView(self, didSelected: models[indexPath.item])
    }
}

class PhotoEditorFilterEditViewCell: UICollectionViewCell {
    
    lazy var bgView: UIVisualEffectView = {
        let visualEffect = UIBlurEffect.init(style: .dark)
        let view = UIVisualEffectView.init(effect: visualEffect)
        view.contentView.addSubview(imageView)
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var titleLb: UILabel = {
        let label = UILabel.init()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var parameterLb: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    var model: PhotoEditorFilterEditModel? {
        didSet {
            guard let model = model else {
                return
            }
            titleLb.text = model.type.title
            imageView.image = model.type.imageNamed.image
            if let para = model.parameters.first, !para.isNormal {
                parameterLb.isHidden = false
                parameterLb.text = String(Int(para.value * 100))
            }else {
                parameterLb.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bgView)
        contentView.addSubview(titleLb)
        contentView.addSubview(parameterLb)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = .init(x: 4, y: 4, width: width - 8, height: width - 8)
        bgView.layer.cornerRadius = bgView.width * 0.5
        imageView.size = .init(width: 20, height: 20)
        imageView.centerX = bgView.width * 0.5
        imageView.centerY = bgView.height * 0.5
        let titleY = bgView.frame.maxY + 12
        var titleHeight = titleLb.textHeight
        if titleHeight > height - titleY {
            titleHeight = height - titleY
        }
        titleLb.frame = CGRect(x: 0, y: titleY, width: width, height: titleHeight)
        
        parameterLb.y = titleLb.frame.maxY + 2
        parameterLb.width = width
        parameterLb.height = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
