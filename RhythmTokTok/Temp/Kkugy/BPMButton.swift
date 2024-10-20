//
//  BPMButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/16/24.
//

import UIKit

class BPMButton: UIButton {
//    private let speedLabel = UILabel()
//    private let dividerView = UIView()
    private let speedStatusLabel = UILabel()
    private let valueLabel = UILabel()
    private var speedValue: Int = UserSettingData.shared.bpm
    private var speedText: String = "보통"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateSpeedText()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateSpeedText()
    }

    // View 설정
    private func setupView() {
        // 라운드 사각형 버튼 스타일 설정
//        self.layer.cornerRadius = 12
//        self.backgroundColor = .gray03
        self.setTitleColor(.black, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false

        // "빠르기" 라벨 설정
//        speedLabel.text = "빠르기"
//        speedLabel.textColor = .gray13
//        speedLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        speedLabel.translatesAutoresizingMaskIntoConstraints = false
//        
        // Divider 설정
//        dividerView.backgroundColor = .black
//        dividerView.translatesAutoresizingMaskIntoConstraints = false
//        
        // 변하는 라벨 ("조금 느리게", "보통", "조금 빠르게")
        speedStatusLabel.text = speedText
        speedStatusLabel.textColor = .gray13
        speedStatusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        speedStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 값 라벨 설정 (소수점 2자리)
        valueLabel.text = "(\(speedValue)bpm)"
        valueLabel.textColor = .gray13
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼에 서브뷰 추가
//        self.addSubview(speedLabel)
//        self.addSubview(dividerView)
        self.addSubview(speedStatusLabel)
        self.addSubview(valueLabel)
        
        // 레이아웃 제약 조건
        NSLayoutConstraint.activate([
            // "빠르기" 라벨
//            speedLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            speedLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//
//            // Divider
//            dividerView.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: 8),
//            dividerView.widthAnchor.constraint(equalToConstant: 1),
//            dividerView.heightAnchor.constraint(equalToConstant: 20),
//            dividerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // 속도 상태 라벨 ("조금 느리게", "보통", "조금 빠르게")
            speedStatusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            speedStatusLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // 값 라벨
            valueLabel.leadingAnchor.constraint(equalTo: speedStatusLabel.trailingAnchor, constant: 2),
            valueLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    // 속도 상태에 따른 텍스트 변경
    private func updateSpeedText() {
        if speedValue < 100 {
            speedText = "조금 느리게"
        } else if speedValue < 120 {
            speedText = "보통"
        } else {
            speedText = "조금 빠르게"
        }

        // 속도 상태 라벨과 값 라벨 업데이트
        speedStatusLabel.text = speedText
        valueLabel.text = "(\(speedValue)BPM)"
    }
    
    override var intrinsicContentSize: CGSize {
        // Auto Layout을 사용하여 내부 요소에 맞춰 가로 크기 자동 결정
        let contentWidth = speedStatusLabel.intrinsicContentSize.width
            + valueLabel.intrinsicContentSize.width
            
        let contentHeight = 24.0

        return CGSize(width: contentWidth, height: contentHeight)
    }
}
