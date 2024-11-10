//
//  RequestView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import UIKit

class RequestView: UIView {
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    let requestActionButton = UIButton(type: .system)
    private let contentStackView = UIStackView()
    
    var request: Request? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let request = request else { return }
        titleLabel.text = request.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = "요청 날짜: \(dateFormatter.string(from: request.date))"
        
        switch request.status {
        case .inProgress:
            requestActionButton.setTitle("요청 취소", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "red01")
            requestActionButton.setTitleColor(UIColor(named: "red05"), for: .normal)
        case .downloaded:
            requestActionButton.setTitle("악보 보기", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "button_secondary")
            requestActionButton.setTitleColor(UIColor(named: "lable_secondary"), for: .normal)
        case .scoreReady:
            requestActionButton.setTitle("악보 추가", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "button_primary")
            requestActionButton.setTitleColor(.white, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.layer.cornerRadius = 12
        self.backgroundColor = .white

        // UI 요소들 추가
        addSubview(contentStackView)
        addSubview(requestActionButton)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        requestActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 스택뷰 설정
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = 10
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        // 추가적인 스타일 설정
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .darkGray
        requestActionButton.layer.cornerRadius = 8

        // 오토레이아웃 제약 조건 설정
        NSLayoutConstraint.activate([
            // 컨텐츠 스택뷰 제약 조건
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: requestActionButton.leadingAnchor, constant: -10),
            
            // 버튼 제약 조건
            requestActionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            requestActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            requestActionButton.widthAnchor.constraint(equalToConstant: 80),
            requestActionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
