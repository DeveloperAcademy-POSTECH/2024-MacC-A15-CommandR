//
//  ToastAlert.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

class ToastAlert {
    static func show(message: String, in view: UIView, iconName: String, duration: TimeInterval = 3.0) {
        // Blur Effect 추가
        let blurEffect = UIBlurEffect(style: .dark)  // 블러 스타일을 .dark로 설정
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.cornerRadius = 12
        blurEffectView.clipsToBounds = true
        
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(named: "gray800")?.withAlphaComponent(0.8)
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.alpha = 0.0
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        toastContainer.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: toastContainer.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor)
        ])
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 컨테이너에 아이콘과 텍스트 레이블 추가
        toastContainer.addSubview(iconImageView)
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            // 컨테이너 제약 조건
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastContainer.heightAnchor.constraint(equalToConstant: 64),
            
            // 아이콘 이미지 제약 조건
            iconImageView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // 텍스트 레이블 제약 조건
            toastLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            toastLabel.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor)
        ])
        
        // 초기 위치를 아래쪽으로 설정
        toastContainer.transform = CGAffineTransform(translationX: 0, y: 100)
        
        // 나타나는 애니메이션
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
            toastContainer.transform = .identity
        }
        ) { _ in
            // 사라지는 애니메이션
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastContainer.alpha = 0.0
                toastContainer.transform = CGAffineTransform(translationX: 0, y: 100)
            }
            ) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
