//
//  UITableView+Extension.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

extension UITableView {
    func register(_ cellType: UITableViewCell.Type) {
        register(UINib(nibName: cellType.className, bundle: Bundle(for: cellType)), forCellReuseIdentifier: cellType.className)
    }
}

extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>(with cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: cellType.className, for: indexPath) as! Cell
    }
}
