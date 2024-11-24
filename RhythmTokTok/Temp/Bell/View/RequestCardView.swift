//
//  RequestView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import UIKit

class RequestCardView: UIView {
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
        dateLabel.text = "요청 날짜: \(dateFormatter.string(from: request.requestDate))"
        
        switch request.status {
        case .inProgress:
            requestActionButton.setTitle("요청 취소", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "red050")
            requestActionButton.setTitleColor(UIColor(named: "red500"), for: .normal)
        case .errorOccurred:
            requestActionButton.setTitle("자세히", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "button_secondary")
            requestActionButton.setTitleColor(.black, for: .normal)
        case .scoreReady:
            requestActionButton.setTitle("음악 추가", for: .normal)
            requestActionButton.backgroundColor = UIColor(named: "button_primary")
            requestActionButton.setTitleColor(.white, for: .normal)
        default:
            requestActionButton.isHidden = true
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
        self.backgroundColor = UIColor(named: "background_primary")
        
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
        titleLabel.font = UIFont.customFont(forTextStyle: .body1Bold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor(named: "lable_secondary")
        titleLabel.numberOfLines = 0 // 멀티라인 허용
        titleLabel.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        dateLabel.font = UIFont.customFont(forTextStyle: .captionRegular)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = UIColor(named: "lable_tertiary")
        dateLabel.numberOfLines = 0 // 멀티라인 허용
        dateLabel.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        requestActionButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button2Medium)
        requestActionButton.titleLabel?.adjustsFontForContentSizeCategory = true
        requestActionButton.titleLabel?.numberOfLines = 0 // 멀티라인 허용
        requestActionButton.titleLabel?.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        requestActionButton.layer.cornerRadius = 8
        requestActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) // 패딩 추가
        
        // 오토레이아웃 제약 조건 설정
        NSLayoutConstraint.activate([
            // 컨텐츠 스택뷰 제약 조건
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: requestActionButton.leadingAnchor,
                constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // 버튼 제약 조건
            requestActionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            requestActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
//            requestActionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 32), // 최소 높이 설정
//            requestActionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 64) // 최소 너비 설정
        ])
    }
}
