//
//  PlayPauseButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class PlayPauseButton: UIButton {

    // 상태를 관리하는 변수 (재생 중인지 여부)
    var isPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateButtonAppearance()
            }
        }
    }

    // 초기 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    // 버튼 기본 설정
    private func setupButton() {
        var config = UIButton.Configuration.filled()
        let playImage = resizedImage(named: "play", size: CGSize(width: 40, height: 40))?
            .withRenderingMode(.alwaysTemplate)
        config.image = playImage
        config.title = "재생" // 초기 텍스트는 "재생"
        config.baseForegroundColor = .white // 텍스트 및 이미지 색상
        config.baseBackgroundColor = .blue500 // 버튼 배경색
        config.imagePadding = 8 // 이미지와 텍스트 간격
        
        let customFont = UIFont.customFont(forTextStyle: .heading1Medium)
        config.attributedTitle = AttributedString("재생", attributes:
            .init([.font: customFont]))

        // 버튼 설정 적용
        self.configuration = config
        self.setImage(config.image, for: .normal)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // Dynamic Type 활성화
        self.titleLabel?.font = customFont
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    // 버튼의 이미지를 재생/일시정지 상태에 맞게 업데이트
    private func updateButtonAppearance() {
        var config = UIButton.Configuration.filled()
        
        if isPlaying {
            let pauseImage = resizedImage(named: "pause", size: CGSize(width: 40, height: 40))?
                .withRenderingMode(.alwaysTemplate) // 템플릿 모드 설정
            config.image = pauseImage
            config.attributedTitle = AttributedString("일시정지", attributes:
                    .init([.font: UIFont.customFont(forTextStyle: .heading1Medium)]))
            config.baseBackgroundColor = .gray800
            
        } else {
            let playImage = resizedImage(named: "play", size: CGSize(width: 40, height: 40))?
                .withRenderingMode(.alwaysTemplate) // 템플릿 모드 설정
            config.image = playImage
            config.attributedTitle = AttributedString("재생", attributes:
                    .init([.font: UIFont.customFont(forTextStyle: .heading1Medium)]))
            config.baseBackgroundColor = .blue500
        }
        
        config.baseForegroundColor = .white
        config.imagePadding = 8
        self.configuration = config
        
        // Dynamic Type 활성화
        self.titleLabel?.font = UIFont.customFont(forTextStyle: .heading2Medium)
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    // 이미지를 리사이즈하는 유틸리티 메서드
    private func resizedImage(named name: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
