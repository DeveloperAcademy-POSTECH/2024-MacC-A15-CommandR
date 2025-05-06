//
//  BeforeSearchView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/20/24.
//

import UIKit

class BeforeSearchView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "emptysearch"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "무엇을 찾으시나요?"
        label.font = UIFont.customFont(forTextStyle: .heading2Medium)
        label.numberOfLines = 0 // 멀티라인 허용
        label.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(named: "lable_quaternary")
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
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 22
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
}
