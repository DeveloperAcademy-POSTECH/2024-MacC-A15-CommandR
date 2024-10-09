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
    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "소리 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 소리 설정 버튼들
    let soundNoteButton: UIButton = createOptionButton(title: "계이름으로 듣기")
    let soundMelodyButton: UIButton = createOptionButton(title: "멜로디로 듣기")
    let soundBeatButton: UIButton = createOptionButton(title: "박자만 듣기")
    
    // 진동 가이드 설정 라벨
    private let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch 진동 가이드 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 진동 가이드 설정 버튼들
    let vibrationOnButton: UIButton = createOptionButton(title: "진동 가이드 받기")
    let vibrationOffButton: UIButton = createOptionButton(title: "진동 가이드 받지 않기")
    
    // 글자 크기 설정 라벨
    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "글자 크기 설정"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 글자 크기 설정 슬라이더
    let fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 4
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setValue(2, animated: false) // 기본값 보통
        return slider
    }()
    
    private let fontSizeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "선호하는 글자 크기로 조절 됩니다."
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minFontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "가"
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxFontSizeLabel: UILabel = {
        let label = UILabel()
        label.text = "가"
        label.font = UIFont.systemFont(ofSize: 20)
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
        
        // 스택뷰 설정
        let soundStackView = createVerticalStackView(arrangedSubviews: [soundNoteButton, soundMelodyButton, soundBeatButton])
        let vibrationStackView = createVerticalStackView(arrangedSubviews: [vibrationOnButton, vibrationOffButton])
        let sliderStackView = createSliderStackView()
        
        // 전체 레이아웃 구성
        let mainStackView = UIStackView(arrangedSubviews: [
            soundLabel,
            soundStackView,
            vibrationLabel,
            vibrationStackView,
            fontSizeLabel,
            sliderStackView,
            fontSizeDescriptionLabel
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        // Auto Layout 제약 설정
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Helper Methods
    
    // 선택 버튼 생성 메서드
    private static func createOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    // 세로 스택뷰 생성 메서드
    private func createVerticalStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // 슬라이더와 라벨을 포함한 스택뷰 생성 메서드
    private func createSliderStackView() -> UIStackView {
        let sliderContainerView = UIView()
        sliderContainerView.addSubview(fontSizeSlider)
        
        NSLayoutConstraint.activate([
            fontSizeSlider.leadingAnchor.constraint(equalTo: sliderContainerView.leadingAnchor),
            fontSizeSlider.trailingAnchor.constraint(equalTo: sliderContainerView.trailingAnchor),
            fontSizeSlider.centerYAnchor.constraint(equalTo: sliderContainerView.centerYAnchor)
        ])
        
        let labelsStackView = UIStackView(arrangedSubviews: [minFontSizeLabel, maxFontSizeLabel])
        labelsStackView.axis = .horizontal
        labelsStackView.distribution = .equalSpacing
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let sliderStackView = UIStackView(arrangedSubviews: [sliderContainerView, labelsStackView])
        sliderStackView.axis = .vertical
        sliderStackView.spacing = 5
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        return sliderStackView
    }
}
