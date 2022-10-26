//
//  PhotoEditorViewController+BrushColorView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/11/15.
//

import UIKit

extension PhotoEditorViewController: PhotoEditorBrushColorViewDelegate {
    func brushColorView(didUndoButton colorView: PhotoEditorBrushColorView) {
        imageView.undoDraw()
        brushColorView.canUndo = imageView.canUndoDraw
    }
    func brushColorView(_ colorView: PhotoEditorBrushColorView, changedColor colorHex: String) {
        imageView.drawColorHex = colorHex
    }
    func brushColorView(_ colorView: PhotoEditorBrushColorView, changedColor color: UIColor) {
        imageView.drawColor = color
    }
    
    class BrushSizeView: UIView {
        lazy var borderLayer: CAShapeLayer = {
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.lineWidth = 2
            borderLayer.shadowColor = UIColor.black.cgColor
            borderLayer.shadowRadius = 2
            borderLayer.shadowOpacity = 0.4
            borderLayer.shadowOffset = CGSize(width: 0, height: 0)
            return borderLayer
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(borderLayer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            borderLayer.frame = bounds
            
            let path = UIBezierPath(
                arcCenter: CGPoint(x: width * 0.5, y: height * 0.5),
                radius: width * 0.5 - 1,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            borderLayer.path = path.cgPath
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
