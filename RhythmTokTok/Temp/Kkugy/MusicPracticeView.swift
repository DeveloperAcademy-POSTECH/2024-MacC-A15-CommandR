//
//  MusicPracticeView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeView: UIView {
    
    // UI 요소 선언
    // Spacer 역할을 할 빈 뷰 생성
    let spacerView1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Divider 역할을 할 선
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let pageLabel: UILabel = {
        let label = UILabel()
        label.text = "0/0장"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Press Me", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        
        // 제목 HStack 요소 추가
        titleHStackView.addArrangedSubview(titleLabel)
        titleHStackView.addArrangedSubview(spacerView1)
        titleHStackView.addArrangedSubview(pageLabel)

        // UI 요소 추가
        addSubview(titleHStackView) // 타이틀 스택
        addSubview(divider) // divider
        addSubview(actionButton)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 타이틀 스택
            titleHStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleHStackView.topAnchor.constraint(equalTo: topAnchor, constant: 66),
            titleHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            // divider
            divider.topAnchor.constraint(equalTo: titleHStackView.bottomAnchor, constant: 16),
            divider.widthAnchor.constraint(equalTo: titleHStackView.widthAnchor), // 타이틀 스택뷰 길이만큼 차지하게 설정
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }
}
