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
    public var circleColor: CircleColors? {
        didSet {
            self.image = circleColor?.circle
        }
    }
    
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
    
    override func startAnimating() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.toValue = CGFloat.pi * 2
        rotate.duration = 10
        rotate.repeatCount = Float.infinity
        self.layer.add(rotate, forKey: "rotationAnimation")
    }
    
    override func stopAnimating() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
}

enum CircleColors {
    case blue
    case green
    case red
    
    var circle: UIImage {
        switch self {
        case .blue:
            return UIImage(named: "circle-blue")!
        case .green:
            return UIImage(named: "circle-green")!
        case .red:
            return UIImage(named: "circle-red")!
        }
    }
}
