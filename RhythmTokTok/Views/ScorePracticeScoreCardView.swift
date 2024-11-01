//
//  MusicPracticeTitleView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

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
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(titleLabel)

        bpmLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(bpmLabel)
        
        currentMeasureLabel.text = "0"
        currentMeasureLabel.textAlignment = .left
        currentMeasureLabel.textColor = UIColor.blue05
        currentMeasureLabel.font = .systemFont(ofSize: 24, weight: .regular)
        currentMeasureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalMeasureLabel.text = "/ 0"
        totalMeasureLabel.textAlignment = .left
        totalMeasureLabel.textColor = UIColor(named: "lable_tertiary")
        totalMeasureLabel.font = .systemFont(ofSize: 24, weight: .regular)
        totalMeasureLabel.translatesAutoresizingMaskIntoConstraints = false

        currentMeasureHStack.axis = .horizontal
        currentMeasureHStack.alignment = .center
        currentMeasureHStack.spacing = 0
        currentMeasureHStack.addArrangedSubview(currentMeasureLabel)
        currentMeasureHStack.addArrangedSubview(totalMeasureLabel)
        currentMeasureHStack.translatesAutoresizingMaskIntoConstraints = false
        scoreCardView.addSubview(currentMeasureHStack)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 배경
            scoreCardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreCardView.topAnchor.constraint(equalTo: topAnchor),
            scoreCardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scoreCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // 타이틀
            titleLabel.topAnchor.constraint(equalTo: scoreCardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: scoreCardView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            // BPM
            bpmLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bpmLabel.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            
            currentMeasureHStack.leadingAnchor.constraint(equalTo: scoreCardView.leadingAnchor, constant: 16),
            currentMeasureHStack.bottomAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: -20)
        ])
    }
    
    func setTotalMeasure(totalMeasure: Int) {
        totalMeasureLabel.text = " / \(totalMeasure) 마디"
    }
}
