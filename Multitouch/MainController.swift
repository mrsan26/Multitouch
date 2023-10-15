//
//  ViewController.swift
//  Multitouch
//
//  Created by Sanchez on 30.09.2023.
//

import UIKit
import Combine

class MainController: UIViewController {
    
    @IBOutlet weak var mainInteractiveView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var centerInfoLabel: UILabel!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    
    private var fingerCircle: CustomImageView {
        let uiImageView = CustomImageView()
        uiImageView.image = UIImage(systemName: "circle")
        uiImageView.tintColor = .systemBlue
        return uiImageView
    }
    
    @Published private var circles: [Int: CustomImageView] = [:]
    private var timer: Timer?
    private var gameEnded: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainInteractiveView.isMultipleTouchEnabled = true
        addGesture()
        binding()
    }
    
    private func addGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addFirstCircle(_:)))
        gesture.minimumPressDuration = 0
        gesture.delegate = self
        mainInteractiveView.addGestureRecognizer(gesture)
    }
    
    private func binding() {
        $circles.dropFirst().sink { [weak self] circlesArray in
            guard let self else { return }
            if circlesArray.count > 1 {
                self.stopCountdown()
                self.startCountdown { [weak self] in
                    guard let self else { return }
                    self.play()
                }
            } else {
                self.stopCountdown()
                self.centerInfoLabel.isHidden = false
            }
            
            self.bottomInfoLabel.isHidden = !(circlesArray.count == 1)
        }.store(in: &cancellables)
    }
    
    private func stopCountdown() {
        countdownLabel.isHidden = true
        timer?.invalidate()
        timer = nil
    }
    
    private func startCountdown(completion: (() -> Void)?) {
        var counter = 3
        countdownLabel.isHidden = false
        centerInfoLabel.isHidden = true
        countdownLabel.animateSoftAppearance(text: String(counter))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            counter -= 1
            self.countdownLabel.animateSoftAppearance(text: String(counter))
            Vibration.light.vibrate()
            if counter < 1 {
                self.stopCountdown()
                completion?()
            }
        })
    }
    
    private func play() {
        var allViews: [CustomImageView] = []
        guard allViews.isEmpty else { return }
        
        circles.forEach { (key: Int, value: CustomImageView) in
            allViews.append(value)
        }
        allViews.forEach { imageView in
            imageView.tintColor = .systemGreen
        }
        let randomView = allViews.randomElement()
        randomView?.tintColor = .systemRed
        randomView?.defeatStatus = true
        randomView?.animatePulse()
        gameEnded = true
        Vibration.error.vibrate()
    }
    
    private func addCircle(position: CGPoint, hash: Int) {
        let fingerCircle = fingerCircle
        
        var position = position
        let size = fingerCircle.frame.size
        position.x -= size.width / 2
        position.y -= size.height / 2

        circles[hash] = fingerCircle
        fingerCircle.frame = CGRect(origin: position, size: size)

        self.view.addSubview(fingerCircle)
        Vibration.medium.vibrate()
    }
    
    private func redCircleWasRemoving() -> Bool {
        var circlesDefeatStatus: [Bool] = []
        circles.forEach { (key: Int, value: CustomImageView) in
            circlesDefeatStatus.append(value.defeatStatus)
        }
        return Set(circlesDefeatStatus).count == 1
    }
    
    private func endOfTouch(hash: Int) {
        circles[hash]?.removeFromSuperview()
        circles.removeValue(forKey: hash)
        
        if gameEnded, !redCircleWasRemoving() {
            removeAllCircles()
            gameEnded = false
        }
    }
    
    private func cancelTouches() {
        removeAllCircles()
        centerInfoLabel.isHidden = false
        centerInfoLabel.animatePulse()
        Vibration.error.vibrate()
    }
    
    private func removeAllCircles() {
        circles.forEach { (key: Int, value: CustomImageView) in
            value.removeFromSuperview()
        }
        circles.removeAll()
    }
    
    @objc private func addFirstCircle(_ sender: UITapGestureRecognizer) {
        let senderHash = sender.hash
        if sender.state == .began {
            addCircle(position: sender.location(in: self.view), hash: senderHash)
        }
        if sender.state == .ended {
            endOfTouch(hash: senderHash)
        }
        if sender.state == .cancelled {
            removeAllCircles()
        }
    }
}

extension MainController: UIGestureRecognizerDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            addCircle(position: touch.location(in: self.view), hash: touch.hash)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let touchHash = touch.hash
            endOfTouch(hash: touchHash)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelTouches()
    }
}
