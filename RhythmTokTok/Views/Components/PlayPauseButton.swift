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
        // 버튼 구성 설정
        var config = UIButton.Configuration.filled()
        let playImage = UIImage(systemName: "play.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        config.image = playImage
        config.title = "재생" // 초기 텍스트는 "재생"
        config.baseForegroundColor = .white // 텍스트 및 이미지 색상
        config.baseBackgroundColor = .blue500 // 버튼 배경색
        config.imagePadding = 18 // 이미지와 텍스트 간격
        config.attributedTitle = AttributedString("재생", attributes:
                .init([.font: UIFont(name: "Pretendard-Medium", size: 24)!])) // 텍스트 크기 설정
        // 버튼 설정 적용
        self.configuration = config
        self.setImage(config.image, for: .normal)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }

    // 버튼의 이미지를 재생/일시정지 상태에 맞게 업데이트
    private func updateButtonAppearance() {
        var config = UIButton.Configuration.filled()

        if isPlaying {
            let pauseImage = UIImage(systemName: "pause.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
            config.image = pauseImage
            config.attributedTitle = AttributedString("일시정지", attributes:
                    .init([.font: UIFont(name: "Pretendard-Medium", size: 24)!])) // 텍스트 크기 설정
            config.baseBackgroundColor = .gray800
            
        } else {
            let playImage = UIImage(systemName: "play.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
            config.image = playImage
            config.attributedTitle = AttributedString("재생", attributes:
                    .init([.font: UIFont(name: "Pretendard-Medium", size: 24)!])) // 텍스트 크기 설정
            config.baseBackgroundColor = .blue500
        }
        config.baseForegroundColor = .white
        config.imagePadding = 18
        self.configuration = config
        self.setImage(config.image, for: .normal)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }
}
