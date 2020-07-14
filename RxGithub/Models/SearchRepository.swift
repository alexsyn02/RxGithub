//
//  SearchRepository.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 14.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

struct SearchRepository {
    
    enum SearchType: Int {
        case search = 0, recent
    }
    
    let query: String
    let page: Int
    let type: SearchType
}
