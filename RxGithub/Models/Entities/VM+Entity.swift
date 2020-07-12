//
//  VM+Entity.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift

protocol VMProtocol: class { }

protocol VMInputOutputProtocol: VMProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
