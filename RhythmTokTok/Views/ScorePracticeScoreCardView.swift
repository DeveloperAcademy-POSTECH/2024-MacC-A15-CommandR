//
//  MusicPracticeTitleView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import Combine
import UIKit

class ScorePracticeScoreCardView: UIView {
    private let scoreCardView = UIView()
    // UI 요소 선언
    let titleLabel = UILabel()
    let bpmLabel = BPMLabel()
    let currentMeasureHStack = UIStackView()
    let currentMeasureLabel = UILabel()
    let totalMeasureLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    var textPublisher = PassthroughSubject<String, Never>()
    
    func updateCurrentMeasureLabelText(_ text: String) {
        currentMeasureLabel.text = text
        textPublisher.send(text)
    }
    
    private func setupView() {
        scoreCardView.backgroundColor = UIColor(named: "background_secondary")
        scoreCardView.layer.cornerRadius = 12
        scoreCardView.layer.borderWidth = 1
        scoreCardView.layer.borderColor = UIColor(named: "border_tertiary")?.cgColor
        scoreCardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreCardView)

        titleLabel.text = "처리중"
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(named: "lable_primary")
        titleLabel.font = UIFont.customFont(forTextStyle: .titleBold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(titleLabel)

        bpmLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(bpmLabel)
        
        currentMeasureLabel.text = "1"
        currentMeasureLabel.textAlignment = .center
        currentMeasureLabel.textColor = UIColor.blue500
        currentMeasureLabel.font = UIFont.customFont(forTextStyle: .heading1Regular)
        currentMeasureLabel.adjustsFontForContentSizeCategory = true
        currentMeasureLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(currentMeasureLabel)

        totalMeasureLabel.text = "/ 0"
        totalMeasureLabel.textAlignment = .left
        totalMeasureLabel.textColor = UIColor(named: "lable_tertiary")
        totalMeasureLabel.font = UIFont.customFont(forTextStyle: .heading1Regular)
        totalMeasureLabel.adjustsFontForContentSizeCategory = true
        totalMeasureLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(totalMeasureLabel)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 배경
            scoreCardView.topAnchor.constraint(equalTo: topAnchor),
            scoreCardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scoreCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // 타이틀
            titleLabel.topAnchor.constraint(equalTo: scoreCardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: scoreCardView.trailingAnchor, constant: -16),

            // BPM
            bpmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bpmLabel.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            bpmLabel.trailingAnchor.constraint(equalTo: scoreCardView.trailingAnchor, constant: -16),

            currentMeasureLabel.topAnchor.constraint(greaterThanOrEqualTo: bpmLabel.bottomAnchor, constant: 12),
            currentMeasureLabel.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            currentMeasureLabel.bottomAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: -20),
            
            totalMeasureLabel.topAnchor.constraint(greaterThanOrEqualTo: bpmLabel.bottomAnchor, constant: 12),
            totalMeasureLabel.leadingAnchor.constraint(equalTo: currentMeasureLabel.trailingAnchor),
            totalMeasureLabel.trailingAnchor.constraint(equalTo: scoreCardView.trailingAnchor, constant: -16),
            totalMeasureLabel.bottomAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: -20)
        ])
    }
    
    func setTotalMeasure(totalMeasure: Int) {
        totalMeasureLabel.text = " / \(totalMeasure) 마디"
    }
}
