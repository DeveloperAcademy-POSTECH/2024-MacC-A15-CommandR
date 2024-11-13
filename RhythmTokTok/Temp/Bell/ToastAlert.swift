//
//  ToastAlert.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

extension UIView {
    func setBlurView(style: UIBlurEffect.Style, radius: CGFloat) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // 블러 뷰를 추가하고 가장 뒤로 보내기
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
        
        // 모서리 radius 설정
        blurEffectView.layer.cornerRadius = radius
        blurEffectView.clipsToBounds = true
        
        // 오토레이아웃으로 크기 맞추기
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}


class ToastAlert {
    static func show(message: String, in view: UIView, iconName: String, duration: TimeInterval = 3.0) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(named: "gray800")?.withAlphaComponent(0.8)
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // setBlurView 확장 메서드 호출로 블러 추가
        toastContainer.setBlurView(style: .regular, radius: 12)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon과 Label을 toastContainer에 추가
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
        }) { _ in
            // 사라지는 애니메이션
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastContainer.alpha = 0.0
                toastContainer.transform = CGAffineTransform(translationX: 0, y: 100)
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
