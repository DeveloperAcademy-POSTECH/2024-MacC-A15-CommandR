//
//  BPMSettingView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class SoundSettingSectionView: UIView, RadioButtonOptionItemPickerDelegate {
    // 선택된 옵션을 전달하기 위한 클로저
    var onOptionSelected: ((String) -> Void)?

    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "소리 설정"
        label.font = UIFont(name: "Pretendard-Bold", size: 21)
        return label
    }()
    
    // 라디오 버튼 옵션
    private let pickerOptions = [
        (title: "멜로디로 듣기", value: "melody"),
        (title: "박자만 듣기", value: "beat"),
        (title: "소리 끄기", value: "mute")
    ]
    
    public lazy var radioButtonPicker: RadioButtonOptionItemPicker = {
        let picker = RadioButtonOptionItemPicker(options: pickerOptions)
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(radioButtonPicker)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        radioButtonPicker.translatesAutoresizingMaskIntoConstraints = false

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            // RadioButtonPicker Constraints
            radioButtonPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            radioButtonPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            radioButtonPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            radioButtonPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - RadioButtonPickerDelegate
    func radioButtonPicker(_ picker: RadioButtonOptionItemPicker, didSelectOptionWithValue value: String) {
        print("선택된 소리 옵션: \(value)")
        onOptionSelected?(value)
    }
}
