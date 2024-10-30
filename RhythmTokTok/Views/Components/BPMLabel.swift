//
//  BPMButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/16/24.
//

import UIKit

class BPMLabel: UIView {
    private var BPMHStackView = UIStackView()
    private var speedStatusLabel = UILabel()
    private var valueLabel = UILabel()
    private var speedText: String = "보통"
    // TODO: CoreData 변경 필요
    private var speedValue: Int = UserSettingData.shared.bpm

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
        speedStatusLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        speedStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.text = "(\(speedValue)bpm)"
        valueLabel.textColor = UIColor(named: "lable_quaternary")
        valueLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
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
        // TODO: 나중에 범위 값 설정 후 조정, CoreData로 변경 필요
        speedValue = UserSettingData.shared.bpm
        
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
}
