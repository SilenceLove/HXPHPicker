//
//  EditorViewController.swift
//  HXPHPicker
//
//  Created by Slience on 2023/1/11.
//

import UIKit

public class EditorViewController: BaseViewController {
    
    let assets: [EditorAsset] = []
    
    var currentIndex: Int = 0
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.register(EditorViewCell.self, forCellWithReuseIdentifier: "EditorViewCellID")
        return collectionView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func initView() {
        view.backgroundColor = .black
        view.addSubview(collectionView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margin: CGFloat = 20
        let itemWidth = view.width + margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.itemSize = view.size
        let contentWidth = (view.width + itemWidth) * CGFloat(assets.count)
        collectionView.frame = CGRect(x: -(margin * 0.5), y: 0, width: itemWidth, height: view.height)
        collectionView.contentSize = CGSize(width: contentWidth, height: view.height)
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * itemWidth, y: 0), animated: false)
    }
}

extension EditorViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditorViewCellID", for: indexPath) as! EditorViewCell
        cell.asset = assets[indexPath.item]
        return cell
    }
    
}

public class EditorAsset: Equatable {
    
    let type: `Type`
    
    public init(type: `Type`) {
        self.type = type
    }
    
    public static func == (lhs: EditorAsset, rhs: EditorAsset) -> Bool {
        lhs === rhs
    }
    
}

public extension EditorAsset {
    enum `Type` {
        case image(UIImage)
        case imageData(Data)
        case video(URL)
        case networkVideo(URL)
        
        case networkImage(URL)
        
        case photoAsset(PhotoAsset)
    }
}
