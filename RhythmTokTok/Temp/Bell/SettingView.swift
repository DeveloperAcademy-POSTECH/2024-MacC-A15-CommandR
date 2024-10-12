//
//  SettingView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
import UIKit

class SettingView: UIView {
    
    // MARK: - UI 요소
    
    // 소리 설정 라벨
    let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "소리 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 소리 설정 버튼들
    let soundButtons: [UIButton] = [
        createCustomButton(title: "계이름으로 듣기"),
        createCustomButton(title: "멜로디로 듣기"),
        createCustomButton(title: "박자만 듣기")
    ]
    // 진동 가이드 설정 라벨
    let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch 진동 가이드 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 진동 가이드 설정 버튼들
    let vibrationButtons: [UIButton] = [
        createCustomButton(title: "진동 가이드 받기"),
        createCustomButton(title: "진동 가이드 받지 않기")
    ]
    // 글자 크기 설정 라벨
    let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "글자 크기 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 글자 크기 설정 버튼들
    let fontSizeButtons: [UIButton] = [
        createCustomButton(title: "작게", tag: 1),
        createCustomButton(title: "보통", tag: 2),
        createCustomButton(title: "크게", tag: 3),
        createCustomButton(title: "아주 크게", tag: 4)
    ]
    
    
    let fontSizeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "선호하는 글자 크기로 조절 됩니다."
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        backgroundColor = .white
        
        // 소리 설정과 진동 가이드 스택뷰
        let soundStackView = createVerticalStackView(arrangedSubviews: [soundNoteButton, soundMelodyButton, soundBeatButton])
        let vibrationStackView = createVerticalStackView(arrangedSubviews: [vibrationOnButton, vibrationOffButton])
        
        // 글자 크기 설정 스택뷰
        let fontSizeStackView = createHorizontalStackView(arrangedSubviews: fontSizeButtons)
        
        // 메인 스택뷰
        let mainStackView = UIStackView(arrangedSubviews: [
            soundLabel,
            soundStackView,
            vibrationLabel,
            vibrationStackView,
            fontSizeLabel,
            fontSizeStackView,
            fontSizeDescriptionLabel
        ])
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Helper Methods
    
    private static func createCustomButton(title: String, tag: Int = 0) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.tag = tag
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private func createVerticalStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createHorizontalStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
