//
//  StatusTagView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/30/24.
//

import UIKit

class StatusTagView: UIView {

    private let soundSetTag = UIView()
    private let hapticSetTag = UIView()
    private let soundSetLabel = UILabel()
    private let hapticLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        soundSetTag.backgroundColor = UIColor(named: "background_secondary")
        soundSetTag.layer.cornerRadius = 12
        soundSetTag.layer.borderWidth = 1
        soundSetTag.layer.borderColor = UIColor(named: "background_tertiary")?.cgColor
        soundSetTag.translatesAutoresizingMaskIntoConstraints = false

        hapticSetTag.backgroundColor = UIColor(named: "background_secondary")
        hapticSetTag.layer.cornerRadius = 12
        hapticSetTag.layer.borderWidth = 1
        hapticSetTag.layer.borderColor = UIColor(named: "background_tertiary")?.cgColor
        hapticSetTag.translatesAutoresizingMaskIntoConstraints = false

        soundSetLabel.text = "🎵 멜로디"
        soundSetLabel.textAlignment = .center
        soundSetLabel.textColor = UIColor(named: "lable_tertiary")
        soundSetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hapticLabel.text = "🫨 워치 진동"
        hapticLabel.textAlignment = .center
        hapticLabel.textColor = UIColor(named: "lable_tertiary")
        hapticLabel.translatesAutoresizingMaskIntoConstraints = false

        soundSetTag.addSubview(soundSetLabel)
        hapticSetTag.addSubview(hapticLabel)
        
        let stackView = UIStackView(arrangedSubviews: [soundSetTag, hapticSetTag, UIView()])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            soundSetLabel.leadingAnchor.constraint(equalTo: soundSetTag.leadingAnchor, constant: 12),
            soundSetLabel.trailingAnchor.constraint(equalTo: soundSetTag.trailingAnchor, constant: -12),
            soundSetLabel.topAnchor.constraint(equalTo: soundSetTag.topAnchor, constant: 8),
            soundSetLabel.bottomAnchor.constraint(equalTo: soundSetTag.bottomAnchor, constant: -8),

            hapticLabel.leadingAnchor.constraint(equalTo: hapticSetTag.leadingAnchor, constant: 12),
            hapticLabel.trailingAnchor.constraint(equalTo: hapticSetTag.trailingAnchor, constant: -12),
            hapticLabel.topAnchor.constraint(equalTo: hapticSetTag.topAnchor, constant: 8),
            hapticLabel.bottomAnchor.constraint(equalTo: hapticSetTag.bottomAnchor, constant: -8)
        ])
    }
}
