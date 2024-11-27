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
    private let mainStackView = UIStackView()
    
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
        updateStackViewAxis()
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
        
        // Main StackView 설정
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.alignment = .top
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Content StackView 설정
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = 10
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        // Label 설정
        titleLabel.font = UIFont.customFont(forTextStyle: .body1Bold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor(named: "lable_secondary")
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        dateLabel.font = UIFont.customFont(forTextStyle: .captionRegular)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = UIColor(named: "lable_tertiary")
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = .byWordWrapping
        
        // Button 설정
        requestActionButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button2Medium)
        requestActionButton.titleLabel?.adjustsFontForContentSizeCategory = true
        requestActionButton.titleLabel?.numberOfLines = 0
        requestActionButton.titleLabel?.lineBreakMode = .byWordWrapping
        requestActionButton.layer.cornerRadius = 8
        requestActionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        requestActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Main StackView에 요소 추가
        mainStackView.addArrangedSubview(contentStackView)
        mainStackView.addArrangedSubview(requestActionButton)
        addSubview(mainStackView)
        
        // Auto Layout 제약 조건
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // 버튼의 크기 제약 조건
            requestActionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84),
            requestActionButton.heightAnchor.constraint(greaterThanOrEqualTo: requestActionButton.titleLabel!.heightAnchor, constant: 16)
        ])
    }
    
    private func updateStackViewAxis() {
        // 버튼 크기에 따라 스택뷰 방향 변경
        if requestActionButton.intrinsicContentSize.width > 100 {
            mainStackView.axis = .vertical
        } else {
            mainStackView.axis = .horizontal
        }
        mainStackView.alignment = .center
        setNeedsLayout()
        layoutIfNeeded()
    }
}
