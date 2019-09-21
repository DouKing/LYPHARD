//
// Ferragamo
// View+Nib.swift
// Created by WuYikai on 2019/8/1.
// Copyright © 2019 Secoo. All rights reserved.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>(owner: Any? = nil, options: [UINib.OptionsKey: Any]? = nil) -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: owner, options: options)![0] as! T
    }
}
