//
//  XibLoadedView.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit
import SnapKit

class XibLoadedView: UIView {
    func loadFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib    = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view   = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    func xibSetup() {
        let view = self.loadFromNib()
        self.addSubview(view)
        view.snp.makeConstraints { make -> Void in
            make.edges.equalTo(self)
        }
    }
}
