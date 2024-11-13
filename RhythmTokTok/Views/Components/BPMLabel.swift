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
        updateSpeedText()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateSpeedText()
    }

    // View 설정
    private func setupView() {
        speedStatusLabel.text = speedText
        speedStatusLabel.textColor = UIColor(named: "label_primary")
        speedStatusLabel.font = UIFont(name: "Pretendard-Medium", size: 21)
        speedStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = "(\(speedValue)bpm)"
        valueLabel.textColor = UIColor(named: "lable_quaternary")
        valueLabel.font = UIFont(name: "Pretendard-Regular", size: 21)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        BPMHStackView.axis = .horizontal
        BPMHStackView.alignment = .center
        BPMHStackView.spacing = 2
        BPMHStackView.addArrangedSubview(speedStatusLabel)
        BPMHStackView.addArrangedSubview(valueLabel)
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
    func updateSpeedText() {
        speedValue = currentScore?.bpm ?? 60
        speedText = BPMDescription.description(for: speedValue)

        // 속도 상태 라벨과 값 라벨 업데이트
        speedStatusLabel.text = speedText
        valueLabel.text = " (\(speedValue)BPM)"
    }
    
}
