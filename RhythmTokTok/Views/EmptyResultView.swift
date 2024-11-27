//
//  EmptyResultView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/20/24.
//

import UIKit

class EmptyResultView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "noresult"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "검색한 음악을 찾을 수 없어요"
        label.font = UIFont.customFont(forTextStyle: .heading2Bold)
        label.numberOfLines = 0 // 멀티라인 허용
        label.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        label.adjustsFontForContentSizeCategory = true

        label.textColor = UIColor(named: "lable_secondary")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "다른 키워드로 검색해보는 건 어떨까요?"
        label.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        label.numberOfLines = 0 // 멀티라인 허용
        label.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(named: "lable_tertiary")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(messageLabel)
        addSubview(suggestionLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 140),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 22),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16), // 좌측 여백
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16), // 우측 여백
            
            suggestionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            suggestionLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            suggestionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16), // 좌측 여백
            suggestionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16) // 우측 여백
        ])
    }
}
