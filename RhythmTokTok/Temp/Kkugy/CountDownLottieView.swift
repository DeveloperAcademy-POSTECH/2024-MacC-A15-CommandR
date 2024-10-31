//
//  CountDownLottieView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/31/24.
//

import UIKit
import Lottie

class CountDownLottieView {
    private let animationView: LottieAnimationView
    private let backgroundView: UIView
    
    init(view: UIView, animationName: String, opacity: Float = 0.6, animationSpeed: CGFloat = 1.0) {
        // 배경 뷰 설정
        backgroundView = UIView()
        backgroundView.backgroundColor = .placeholder
        backgroundView.layer.opacity = opacity
        backgroundView.isHidden = true
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Lottie 애니메이션 뷰 설정
        animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = animationSpeed
        animationView.isHidden = true
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func play() {
        backgroundView.isHidden = false
        animationView.isHidden = false
        animationView.play { [weak self] _ in
            self?.backgroundView.isHidden = true
            self?.animationView.isHidden = true
        }
    }
    
    func stop() {
        animationView.stop()
        backgroundView.isHidden = true
        animationView.isHidden = true
    }
}
