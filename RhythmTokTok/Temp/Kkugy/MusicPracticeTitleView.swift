//
//  MusicPracticeTitleView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeTitleView: UIView {
    
    // UI 요소 선언
    // Spacer 역할을 할 빈 뷰 생성
    let spacerView1: UIView = {
        let view = UIView()
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
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 타이틀 스택
            titleHStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleHStackView.topAnchor.constraint(equalTo: topAnchor),
            titleHStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleHStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
    }
}
