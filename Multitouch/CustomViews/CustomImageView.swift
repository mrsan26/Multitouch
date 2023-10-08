//
//  CustomImageView.swift
//  Multitouch
//
//  Created by Sanchez on 08.10.2023.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {
    
    public var defeatStatus: Bool = false
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.frame.size = CGSize(width: 150, height: 150)
    }
    
}
