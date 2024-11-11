//
//  ProgressBarView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/30/24.
//

import UIKit

class ProgressBarView: UIView {

    private let progressLayer = CALayer()
    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        layer.backgroundColor = UIColor(named: "border_tertiary")?.cgColor
        progressLayer.backgroundColor = UIColor.blue500.cgColor
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        self.progress = max(0, min(1, progress))  // Keep between 0 and 1
        let newWidth = bounds.width * self.progress

        if animated {
            animateProgressChange(to: newWidth)
        } else {
            progressLayer.frame = CGRect(x: 0, y: 0, width: newWidth, height: bounds.height)
        }
    }
    
    private func animateProgressChange(to newWidth: CGFloat) {
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = progressLayer.bounds.width
        animation.toValue = newWidth
        animation.duration = 0.05
        progressLayer.add(animation, forKey: "progressAnimation")
        
        // Update the frame at the end of the animation
        progressLayer.frame = CGRect(x: 0, y: 0, width: newWidth, height: bounds.height)
    }
}
