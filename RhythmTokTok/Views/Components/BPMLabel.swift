//
//  BPMButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/16/24.
//

import UIKit

class BPMLabel: UIView {
    var currentScore: Score?
    
    private var BPMHStackView = UIStackView()
    private var speedStatusLabel = UILabel()
    private var valueLabel = UILabel()
    private var speedText: String = "보통"
    private lazy var speedValue: Int = currentScore?.bpm ?? 60

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateSpeedText(currentSpeed: currentScore?.bpm ?? 60)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateSpeedText(currentSpeed: currentScore?.bpm ?? 60)
    }

    // View 설정
    private func setupView() {
        speedStatusLabel.text = speedText
        speedStatusLabel.textColor = UIColor(named: "label_primary")
        speedStatusLabel.font = UIFont.customFont(forTextStyle: .heading2Medium)
        speedStatusLabel.adjustsFontForContentSizeCategory = true
        speedStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.text = "(\(speedValue)bpm)"
        valueLabel.textColor = UIColor(named: "lable_quaternary")
        valueLabel.font = UIFont.customFont(forTextStyle: .heading2Regular)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        // 오른쪽 여백을 위한 투명한 UIView 추가
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal) // 가로 공간 최대 활용
        
        BPMHStackView.axis = .horizontal
        BPMHStackView.alignment = .leading
        BPMHStackView.spacing = 2
        BPMHStackView.addArrangedSubview(speedStatusLabel)
        BPMHStackView.addArrangedSubview(valueLabel)
        BPMHStackView.addArrangedSubview(spacerView)
        BPMHStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(BPMHStackView)

        // 레이아웃 제약 조건
        NSLayoutConstraint.activate([
            BPMHStackView.topAnchor.constraint(equalTo: topAnchor),
            BPMHStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            BPMHStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            BPMHStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // 속도 상태에 따른 텍스트 변경
    func updateSpeedText(currentSpeed: Int) {
        speedValue = currentSpeed
        speedText = BPMDescription.description(for: currentSpeed)

        // 속도 상태 라벨과 값 라벨 업데이트
        valueLabel.text = " (\(speedValue)BPM)"
        speedStatusLabel.text = speedText
    }
    
}
