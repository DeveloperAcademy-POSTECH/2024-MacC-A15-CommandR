//
//  StatusTagView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/30/24.
//

import UIKit

class StatusTagView: UIView {
    var currentScore: Score?
    
    private let soundSetTag = UIView()
    private let hapticSetTag = UIView()
    private let soundSetLabel = UILabel()
    private let hapticLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateTag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        soundSetTag.backgroundColor = .clear
        soundSetTag.layer.cornerRadius = 20
        soundSetTag.layer.borderWidth = 1
        soundSetTag.layer.borderColor = UIColor.borderTertiary.cgColor
        soundSetTag.translatesAutoresizingMaskIntoConstraints = false
        
        hapticSetTag.backgroundColor = .clear
        hapticSetTag.layer.cornerRadius = 20
        hapticSetTag.layer.borderWidth = 1
        hapticSetTag.layer.borderColor = UIColor.borderTertiary.cgColor
        hapticSetTag.translatesAutoresizingMaskIntoConstraints = false
        
        soundSetLabel.text = ""
        soundSetLabel.textAlignment = .center
        soundSetLabel.font = UIFont.customFont(forTextStyle: .body2Medium)
        soundSetLabel.adjustsFontForContentSizeCategory = true
        soundSetLabel.textColor = UIColor(named: "lable_tertiary")
        soundSetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hapticLabel.text = ""
        hapticLabel.textAlignment = .center
        hapticLabel.font = UIFont.customFont(forTextStyle: .body2Medium)
        hapticLabel.adjustsFontForContentSizeCategory = true
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
    
    func updateTag() {
        guard let soundSetting = currentScore?.soundOption else { return }
        guard let hapticSetting = currentScore?.hapticOption else { return }

        switch soundSetting {
        case .melodyBeat:
            soundSetLabel.text = "🎼 멜로디 + 메트로놈"
        case .melody:
            soundSetLabel.text = "🎵 멜로디"
        case .beat:
            soundSetLabel.text = "🥁 메트로놈"
        case .mute:
            soundSetLabel.text = "🔇 소리 끄기"
        case .voice:
            soundSetLabel.text = "🗣️ 계이름"
        }
        
        if hapticSetting {
            let text = "🫨 워치 진동 ON"
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.success,
                                          range: (text as NSString).range(of: "ON"))
            hapticLabel.attributedText = attributedString
        } else {
            hapticLabel.text = "🚫 워치 진동 OFF"
        }
    }
}
