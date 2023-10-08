//
//  Animation.swift
//  Multitouch
//
//  Created by Sanchez on 08.10.2023.
//

import Foundation
import UIKit

extension UILabel {
    func animateSoftAppearance(duration: TimeInterval = 0.18, text: String) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.text = text
        },  completion: nil)
    }
}

extension UIView {
    func animatePulse() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            self.alpha = 0.5
        }) { (_) in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity
                self.alpha = 1.0
            }
        }
    }
}
