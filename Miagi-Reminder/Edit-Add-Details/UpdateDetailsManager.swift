//
//  UpdateDetailsManager.swift
//  Miagi-Reminder
//
//  Created by apple on 8/27/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func customBorder(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 0.05
    }
}

extension UILabel {
    func makeRoundedLable(radius: CGFloat){
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

