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
        label.font = UIFont(name: "Pretendard-Medium", size: 21)
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
        addSubview(imageView)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 22)
        ])
    }
}
