//
//  Reusable.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit.UITableView

protocol ReuseIdentifiable
{
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable where Self: UICollectionReusableView
{
    static var reuseIdentifier: String
    {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReuseIdentifiable { }

extension ReuseIdentifiable where Self: UITableViewCell
{
    static var reuseIdentifier: String
    {
        return String(describing: self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }

//extension UICollectionViewCell: ReuseIdentifiable { }

extension UITableViewHeaderFooterView: ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}



protocol ReusableCell: class {
  static var height: CGFloat { get }
}

extension ReusableCell where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nibName: String {
        return String(describing: self)
    }
}


