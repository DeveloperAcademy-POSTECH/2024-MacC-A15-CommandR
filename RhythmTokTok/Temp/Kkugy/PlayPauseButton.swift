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
            updateButtonAppearance()
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
        config.image = UIImage(systemName: "play.fill") // 초기 이미지는 "재생"으로 설정
        config.title = "재생" // 초기 텍스트는 "재생"
        config.baseForegroundColor = .white // 텍스트 및 이미지 색상
        config.baseBackgroundColor = .blue05 // 버튼 배경색
        config.imagePadding = 10 // 이미지와 텍스트 간격
        config.cornerStyle = .medium // 라운드 코너 스타일

        // 버튼 설정 적용
        self.configuration = config
        // 클릭 시 이벤트 설정
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // 버튼이 클릭될 때 호출되는 함수
    @objc private func buttonTapped() {
        isPlaying.toggle() // 재생/일시정지 상태 변경
        // TODO: 실행 로직 연결
    }

    // 버튼의 이미지를 재생/일시정지 상태에 맞게 업데이트
    private func updateButtonAppearance() {
        var config = UIButton.Configuration.filled()

        if isPlaying {
            setImage(UIImage(systemName: "pause.fill"), for: .normal)
            setTitle("일시정지", for: .normal)
            config.baseBackgroundColor = .gray13

        } else {
            setImage(UIImage(systemName: "play.fill"), for: .normal)
            setTitle("재생", for: .normal)
            config.baseBackgroundColor = .blue05
        }
        config.baseForegroundColor = .white
        config.imagePadding = 10
        config.cornerStyle = .medium

        self.configuration = config
    }
}
