//
//  SettingView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import UIKit

class SettingView: UIView {
    
    // MARK: - UI 요소
    
    // 1. 소리 설정 라벨
    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "소리 설정"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 소리 설정 버튼들
    let soundNoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("계이름으로 듣기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        return button
    }()
    
    let soundMelodyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("멜로디로 듣기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        return button
    }()
    
    let soundBeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("박자만 듣기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 2
        return button
    }()
    
    // 2. Watch 진동 가이드 설정 라벨
    private let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch 진동 가이드 설정"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 진동 가이드 버튼들
    let vibrationOnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("진동 가이드 켜기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        return button
    }()
    
    let vibrationOffButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("진동 가이드 끄기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        return button
    }()
    
    // 3. 글자 크기 설정 라벨
    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "글자 크기 설정"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 글자 크기 설정 버튼들
    let fontSizeSmallButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1: 작음", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        return button
    }()
    
    let fontSizeMediumButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("2: 보통", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 2
        return button
    }()
    
    let fontSizeLargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("3: 큼", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 3
        return button
    }()
    
    let fontSizeExtraLargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("4: 매우 큼", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 4
        return button
    }()
    
    // MARK: - 초기화
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 설정
    
    private func setupUI() {
        self.backgroundColor = .systemBackground
        
        // 스택뷰 생성
        let stackView = UIStackView(arrangedSubviews: [
            soundLabel,
            soundNoteButton,
            soundMelodyButton,
            soundBeatButton,
            vibrationLabel,
            vibrationOnButton,
            vibrationOffButton,
            fontSizeLabel,
            fontSizeSmallButton,
            fontSizeMediumButton,
            fontSizeLargeButton,
            fontSizeExtraLargeButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
        
        // 버튼 스타일 설정 (선택 시 배경색 변경)
        let buttons = [soundNoteButton, soundMelodyButton, soundBeatButton,
                       vibrationOnButton, vibrationOffButton,
                       fontSizeSmallButton, fontSizeMediumButton, fontSizeLargeButton, fontSizeExtraLargeButton]
        
        for button in buttons {
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.setTitleColor(.systemBlue, for: .normal)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
}
