//
//  EditorViewCell.swift
//  HXPHPicker
//
//  Created by Slience on 2023/1/20.
//

import UIKit

class EditorViewCell: UICollectionViewCell {
    
    lazy var editorView: EditorView = {
        let view = EditorView()
        
        return view
    }()
    
    var asset: EditorAsset? {
        didSet {
//            guard let asset = asset else {
//                return
//            }
//            switch asset.type {
//            case .image(let image):
//                break
//            case .imageData(let imageData):
//                break
//            case .video(let url):
//                break
//            case .networkVideo(let url):
//                break
//            case .networkImage(let url):
//                break
//            case .photoAsset(let photoAsset):
//                break
//            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    func initView() {
        contentView.addSubview(editorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        editorView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
