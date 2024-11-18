//
//  CommonNavigationBar.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/18/24.
//

import UIKit

class CommonNavigationBar: UIView {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let rightButtonStackView = UIStackView()

    let watchConnectImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "watchOff")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .error
        return imageView
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("설정", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.tintColor = .blue500
        return button
    }()

    var onBackButtonTapped: (() -> Void)?
    var onSettingButtonTapped: (() -> Void)?

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear

        // Back Button
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .lableSecondary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addSubview(backButton)

        // Title Label
        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 18)
        titleLabel.textColor = .lablePrimary
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Right Button Stack View
        rightButtonStackView.axis = .horizontal
        rightButtonStackView.alignment = .center
        rightButtonStackView.spacing = 25
        addSubview(rightButtonStackView)
    }

    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightButtonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Right Button Stack View
            rightButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rightButtonStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
    
    @objc private func settingButtonTapped() {
        onSettingButtonTapped?()
    }

    // MARK: - Public Methods
    func configure(title: String, includeWatchSettingButton: Bool = false) {
        titleLabel.text = title

        // 기존 버튼 제거
        rightButtonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 워치, 설정 버튼 추가
        if includeWatchSettingButton {
            // 워치 상태 이미지 버튼 추가
            rightButtonStackView.addArrangedSubview(watchConnectImageView)
            NSLayoutConstraint.activate([
                watchConnectImageView.widthAnchor.constraint(equalToConstant: 24),
                watchConnectImageView.heightAnchor.constraint(equalToConstant: 24)
            ])

            // 설정 버튼 추가
            rightButtonStackView.addArrangedSubview(settingButton)
            settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        }
    }

    func setWatchImage(isConnected: Bool) {
        DispatchQueue.main.async {
            if isConnected {
                self.watchConnectImageView.image = UIImage(named: "watchActive")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .success
            } else {
                self.watchConnectImageView.image = UIImage(named: "watchOff")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .error
            }
        }
    }
}
