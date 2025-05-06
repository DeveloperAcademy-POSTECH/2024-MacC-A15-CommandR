//
//  InternetErrorView.swift
//  RhythmTokTok
//
//  Created by 백록담 on 11/21/24.
//

import Foundation
import UIKit

class InternetErrorViewController: UIViewController {
    var onRetry: (() -> Void)? // 클로저 선언

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func setupUI() {
        // 기본 배경색 설정
        view.backgroundColor = .white

        // 1. 스택뷰 생성 (중앙 정렬을 위해 사용)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // 2. 와이파이 경고 아이콘
        let wifiIcon = UIImageView()
        wifiIcon.image = UIImage(named: "caution.wifi") ?? UIImage(systemName: "wifi.exclamationmark")
        wifiIcon.tintColor = .gray300
        wifiIcon.contentMode = .scaleAspectFit
        wifiIcon.translatesAutoresizingMaskIntoConstraints = false
        wifiIcon.widthAnchor.constraint(equalToConstant: 80).isActive = true
        wifiIcon.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackView.addArrangedSubview(wifiIcon)

        // 3. 메인 메시지 레이블
        let mainMessageLabel = UILabel()
        mainMessageLabel.text = "인터넷 연결이 끊겼어요"
        mainMessageLabel.textColor = .lablePrimary
        mainMessageLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        mainMessageLabel.textAlignment = .center
        mainMessageLabel.adjustsFontForContentSizeCategory = true
        mainMessageLabel.numberOfLines = 0
        mainMessageLabel.lineBreakMode = .byWordWrapping
        mainMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(mainMessageLabel)

        // 4. 하위 메시지 레이블
        let subMessageLabel = UILabel()
        subMessageLabel.text = "확인 후 다시 시도해 주세요"
        subMessageLabel.textColor = .lableTertiary
        subMessageLabel.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        subMessageLabel.textAlignment = .center
        subMessageLabel.adjustsFontForContentSizeCategory = true
        subMessageLabel.numberOfLines = 0
        subMessageLabel.lineBreakMode = .byWordWrapping
        subMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(subMessageLabel)

        // 5. 버튼
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("재시도", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        retryButton.backgroundColor = .buttonPrimary
        retryButton.layer.cornerRadius = 10
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        retryButton.setContentHuggingPriority(.required, for: .horizontal)
        retryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(retryButton)

        // 스택뷰 중앙 정렬
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            mainMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            subMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            subMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func retryButtonTapped() {
        // 이전 화면으로 이동
        navigationController?.popViewController(animated: true)
        onRetry?() // 클로저 실행
    }
}
