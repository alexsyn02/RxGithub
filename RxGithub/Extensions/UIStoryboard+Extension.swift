//
//  UIStoryboard+Extension.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static let login = UIStoryboard(name: "LoginVC", bundle: nil)
    static let repositoryList = UIStoryboard(name: "RepositoryListVC", bundle: nil)
    
    func instantiateVC<T>(with type: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
}
