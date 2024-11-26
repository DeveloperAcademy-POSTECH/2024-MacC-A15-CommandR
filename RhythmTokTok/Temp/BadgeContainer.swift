//
//  File.swift
//  RhythmTokTok
//
//  Created by © 2020 SwiftEverywhere. Can be used free of charge.

import Foundation


import UIKit
//protocol
protocol BadgeContainer: class {
    var badgeView: UIView? { get set }
    var badgeLabel: UILabel? { get set }
    func showBadge(blink: Bool, text: String?)
    func hideBadge()
}
//default protocol implementation
extension BadgeContainer where Self: UIView {
    func showBadge(blink: Bool, text: String?) {
        if badgeView != nil {
            if badgeView?.isHidden == false {
                return
            }
        } else {
            badgeView = UIView()
        }

        badgeView?.backgroundColor = .red
        guard let badgeViewUnwrapped = badgeView else {
            return
        }
        //adds the badge at the top
        addSubview(badgeViewUnwrapped)
        badgeViewUnwrapped.translatesAutoresizingMaskIntoConstraints = false

        var size = CGFloat(6)
        if let textUnwrapped = text {
            if badgeLabel == nil {
                badgeLabel = UILabel()
            }
            
            guard let labelUnwrapped = badgeLabel else {
                return
            }
            
            labelUnwrapped.text = textUnwrapped
            labelUnwrapped.textColor = .white
            labelUnwrapped.font = .systemFont(ofSize: 8)
            labelUnwrapped.translatesAutoresizingMaskIntoConstraints = false

            badgeViewUnwrapped.addSubview(labelUnwrapped)
            let labelConstrainst = [
                labelUnwrapped.centerXAnchor.constraint(equalTo: badgeViewUnwrapped.centerXAnchor),
                labelUnwrapped.centerYAnchor.constraint(equalTo: badgeViewUnwrapped.centerYAnchor)
            ]
            NSLayoutConstraint.activate(labelConstrainst)
            
            size = CGFloat(12 + 2 * textUnwrapped.count)
        }
        
        let sizeConstraints = [badgeViewUnwrapped.widthAnchor.constraint(equalToConstant: size), badgeViewUnwrapped.heightAnchor.constraint(equalToConstant: size)]
        NSLayoutConstraint.activate(sizeConstraints)
        
        badgeViewUnwrapped.cornerRadius = size / 2
        
        let position = [badgeViewUnwrapped.topAnchor.constraint(equalTo: self.topAnchor, constant: -size / 2),
        badgeViewUnwrapped.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: size/2)]
        NSLayoutConstraint.activate(position)
        
        if blink {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 1.2
            animation.repeatCount = .infinity
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = .init(name: .easeOut)
            badgeViewUnwrapped.layer.add(animation, forKey: "badgeBlinkAnimation")
        }
    }
    
    func hideBadge() {
        badgeView?.layer.removeAnimation(forKey: "badgeBlinkAnimation")
        badgeView?.removeFromSuperview()
        badgeView = nil
        badgeLabel = nil
    }
}

//custom class
class BadgeButton: UIButton, BadgeContainer {
    var badgeTimer: Timer?
    var badgeView: UIView?
    var badgeLabel: UILabel?
}
//extension of UIView for proper positioning of visual children
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
