//
//  TestEditorViewController.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import HXPHPicker

class TestEditorViewController: UIViewController {
    
    lazy var editorView: EditorView = {
        let view = EditorView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "打开选择器",
            style: .plain,
            target: self,
            action: #selector(openPickerController)
        )
        view.addSubview(editorView)
        editorView.frame = view.bounds
    }
    
    @objc
    func openPickerController() {
        hx.present(
            picker: .init()
        ) { [weak self] result, pickerController in
            guard let self = self else { return }
            result.getImage(mageHandler: nil) { images in
                self.editorView.setImage(images.first)
            }
        }
    }
}
