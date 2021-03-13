//
//  ExampleViewController.swift
//  Example
//
//  Created by Slience on 2021/3/11.
//

import UIKit

class ExampleViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Example"
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
         
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.allCases.count
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return Section.allCases[section].allRowCase.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
//        let rowType = Section.allCases[indexPath.section].allRowCase[indexPath.row]
//        cell.textLabel?.text = rowType.title
//        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let rowType = Section.allCases[indexPath.section].allRowCase[indexPath.row]
//        navigationController?.pushViewController(rowType.controller, animated: true)
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return Section.allCases[section].title
//    }
}

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
