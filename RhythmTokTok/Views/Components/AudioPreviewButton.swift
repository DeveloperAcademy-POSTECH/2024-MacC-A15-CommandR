//
//  AudioPreviewButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/25/24.
//

import UIKit
import Lottie

class AudioPreviewButton: UIView {
    private var lottieAnimationView: LottieAnimationView!
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "미리듣기"
        label.font = UIFont.customFont(forTextStyle: .button2Medium)
        label.textColor = .lableSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .buttonSecondary
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sound") // 기본 이미지
        return imageView
    }()
    
    var isPlaying = false {
        didSet {
            if isPlaying {
                hideStaticImage()
                showLottieAnimation()
            } else {
                hideLottieAnimation()
                showStaticImage()
            }
        }
    }
    
    var onAudioPreviewButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(button)
        addSubview(textLabel)
        addSubview(imageView)
        
        // 버튼 제약 조건
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // WebView 설정
        // LottieAnimationView 설정
        lottieAnimationView = LottieAnimationView(name: "sound")
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.isHidden = true // 초기에는 숨김
        addSubview(lottieAnimationView)
        
        // LottieAnimationView 제약 조건
        NSLayoutConstraint.activate([
            lottieAnimationView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 13),
            lottieAnimationView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            lottieAnimationView.widthAnchor.constraint(equalToConstant: 24),
            lottieAnimationView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // ImageView 제약 조건
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 13),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // 텍스트 레이블 제약 조건 (버튼 안에서 위치 조정)
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4)
        ])
        
        // 버튼 액션 설정
        button.addTarget(self, action: #selector(audioPreviewButtonTapped), for: .touchUpInside)
    }
    
    @objc private func audioPreviewButtonTapped() {
        onAudioPreviewButtonTapped?()
        isPlaying.toggle()
    }
    
    private func showLottieAnimation() {
        DispatchQueue.main.async {
            self.lottieAnimationView.isHidden = false
            self.lottieAnimationView.play()
        }
    }

    private func hideLottieAnimation() {
        DispatchQueue.main.async {
            self.lottieAnimationView.isHidden = true
            self.lottieAnimationView.stop()
        }
    }

    private func showStaticImage() {
        DispatchQueue.main.async {
            self.imageView.isHidden = false // 기본 이미지 표시
            self.button.backgroundColor = .buttonSecondary
            self.textLabel.text = "미리듣기"
            self.textLabel.textColor = .lableSecondary
        }
    }
    
    private func hideStaticImage() {
        DispatchQueue.main.async {
            self.imageView.isHidden = true // 기본 이미지 표시
            self.button.backgroundColor = .gray800
            self.textLabel.text = "재생 중"
            self.textLabel.textColor = .white
        }
    }
}
