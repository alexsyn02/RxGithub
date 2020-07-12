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

class RxViewModel: VMProtocol {
    var bag = DisposeBag()
}

class ModelInitializableVM<Entity: Any>: RxViewModel {
    var model: Entity!
    
   required init(model: Entity) {
        self.model = model
    }
}
