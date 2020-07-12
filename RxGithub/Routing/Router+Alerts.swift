//
//  Router+Alerts.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 11.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

extension Router {
    
    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, configureAlert: ((UIAlertController) -> ())? = nil, actionHandler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: actionHandler)
        alert.addAction(action)
        
        self.present(alert)
    }
    
    func showAlert(error: Error) {
        self.showAlert(title: "Error", message: error.localizedDescription)
    }
}
