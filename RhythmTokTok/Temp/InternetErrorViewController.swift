//
//  InternetErrorView.swift
//  RhythmTokTok
//
//  Created by 백록담 on 11/21/24.
//

import Foundation
import UIKit

class InternetErrorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // 기본 배경색 설정
        view.backgroundColor = .white

        // 1. 와이파이 경고 아이콘
        let wifiIcon = UIImageView()
        wifiIcon.image = UIImage(named: "caution.wifi") ?? UIImage(systemName: "wifi.exclamationmark")
        wifiIcon.tintColor = .gray300
        wifiIcon.contentMode = .scaleAspectFit
        wifiIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wifiIcon)

        // 2. 메인 메시지 레이블
        let mainMessageLabel = UILabel()
        mainMessageLabel.text = "인터넷 연결이 끊겼어요"
        mainMessageLabel.textColor = .lablePrimary
        mainMessageLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        mainMessageLabel.textAlignment = .center
        mainMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        mainMessageLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(mainMessageLabel)

        // 3. 하위 메시지 레이블
        let subMessageLabel = UILabel()
        subMessageLabel.text = "확인 후 다시 시도해 주세요"
        subMessageLabel.textColor = .lableTertiary
        subMessageLabel.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        subMessageLabel.textAlignment = .center
        subMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        subMessageLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(subMessageLabel)

        // 4. 버튼
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("재시도", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        retryButton.backgroundColor = .buttonPrimary
        retryButton.layer.cornerRadius = 10
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        view.addSubview(retryButton)

        // 버튼 액션 추가
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        // 5. Auto Layout 설정
        NSLayoutConstraint.activate([
            // 와이파이 아이콘
            wifiIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wifiIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            wifiIcon.widthAnchor.constraint(equalToConstant: 80),
            wifiIcon.heightAnchor.constraint(equalToConstant: 80),

            // 메인 메시지 레이블
            mainMessageLabel.topAnchor.constraint(equalTo: wifiIcon.bottomAnchor, constant: 20),
            mainMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 하위 메시지 레이블
            subMessageLabel.topAnchor.constraint(equalTo: mainMessageLabel.bottomAnchor, constant: 10),
            subMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 버튼
            retryButton.topAnchor.constraint(equalTo: subMessageLabel.bottomAnchor, constant: 30),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 150),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func retryButtonTapped() {
        // 재시도 버튼 동작
        print("재시도 버튼 클릭됨")
        // 네트워크 연결 상태를 재확인하거나 다른 동작 추가 가능
    }
}
