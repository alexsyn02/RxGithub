//
//  Double+Extensions.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

extension Double {
    var twoDecimalsString: String { format("%.2f") }
    
    func format(_ format: String) -> String { String(format: format, self) }
}
