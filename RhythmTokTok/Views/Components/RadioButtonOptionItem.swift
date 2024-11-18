//
//  RadioButtonOptionItem.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/31/24.
//
import UIKit

class RadioButtonOptionItem: UIView {
    let radioButton = RadioButton()
    let titleLabel = UILabel()
    
    // 항목 식별자 또는 값
    let optionValue: String
    
    init(title: String, value: String) {
        self.optionValue = value
        super.init(frame: .zero)
        setupView(title: title)
    }
    
    required init?(coder: NSCoder) {
        self.optionValue = ""
        super.init(coder: coder)
        setupView(title: "")
    }
    
    private func setupView(title: String) {
        // 라디오 버튼 설정
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.isChecked = false
        
        // 타이틀 라벨 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        // 뷰에 추가
        addSubview(radioButton)
        addSubview(titleLabel)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
