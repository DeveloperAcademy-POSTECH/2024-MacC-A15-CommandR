//
//  RequestEmptyView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/17/24.
//

import UIKit

class EmptyStateView: UIView {
    init(message: String, subMessage: String) {
        super.init(frame: .zero)
        setupView(message: message, subMessage: subMessage)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(message: "", subMessage: "")
    }

    private func setupView(message: String, subMessage: String) {
        // 배경색을 투명하게 설정
        self.backgroundColor = UIColor(named: "background_tertiary")

        // EmptyState 이미지 및 텍스트 추가
        let imageView = UIImageView(image: UIImage(named: "emptyrequest"))
        imageView.contentMode = .scaleAspectFit
             imageView.translatesAutoresizingMaskIntoConstraints = false
             addSubview(imageView)

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = UIColor(named: "lable_primary")
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)

        let subMessageLabel = UILabel()
        subMessageLabel.text = subMessage
        subMessageLabel.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        subMessageLabel.adjustsFontForContentSizeCategory = true
        subMessageLabel.textColor = UIColor(named: "lable_tertiary")
        subMessageLabel.textAlignment = .center
        subMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subMessageLabel)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -90),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            subMessageLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            subMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            subMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
}
