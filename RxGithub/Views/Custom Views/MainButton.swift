//
//  MainButton.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

class MainButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .systemGreen : UIColor.systemGreen.withAlphaComponent(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        backgroundColor = .systemGreen
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 5
    }
}
