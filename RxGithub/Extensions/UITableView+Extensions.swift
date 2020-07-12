//
//  UITableView+Extensions.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
    }
}
