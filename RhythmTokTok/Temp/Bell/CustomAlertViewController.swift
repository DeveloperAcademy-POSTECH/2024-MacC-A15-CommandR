//
//  CustomAlertViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

class CustomAlertViewController: UIViewController {
    private let titleText: String
    private let messageText: String
    private let confirmButtonText: String
    private let cancelButtonText: String
    private let confirmButtonColor: UIColor
    private let cancelButtonColor: UIColor
    
    var onConfirm: (() -> Void)?
    
    init(title: String, message: String, confirmButtonText: String, cancelButtonText: String, confirmButtonColor: UIColor, cancelButtonColor: UIColor) {
        self.titleText = title
        self.messageText = message
        self.confirmButtonText = confirmButtonText
        self.cancelButtonText = cancelButtonText
        self.confirmButtonColor = confirmButtonColor
        self.cancelButtonColor = cancelButtonColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlertView()
    }
    
    private func setupAlertView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let alertContainer = UIView()
        alertContainer.backgroundColor = UIColor(named: "background_primary")
        alertContainer.layer.cornerRadius = 16
        alertContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertContainer)
        
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 21)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        alertContainer.addSubview(titleLabel)
        
        // MARK: - @lyosha 여기에 컬러 다르게 할 텍스트 지정
        let messageLabel = UILabel()
        messageLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
        messageLabel.textAlignment = .left
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        alertContainer.addSubview(messageLabel)
        let fullMessage = "취소 후에는 되돌릴 수 없어요."
        let attributedMessage = NSMutableAttributedString(string: fullMessage)
        
        // 1. 전체 텍스트의 기본 색상 설정
        attributedMessage.addAttribute(.foregroundColor, value: UIColor(named: "lable_secondary") ?? .black, range: NSRange(location: 0, length: fullMessage.count))
        
        // 2. "취소" 부분에만 강조 색상 적용
        if let cancelRange = fullMessage.range(of: "되돌릴 수 없어요.") {
            let nsRange = NSRange(cancelRange, in: fullMessage)
            attributedMessage.addAttribute(.foregroundColor, value: UIColor(named: "button_danger") ?? .red, range: nsRange)
        }
        
        messageLabel.attributedText = attributedMessage
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle(cancelButtonText, for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        closeButton.layer.cornerRadius = 12
        closeButton.backgroundColor = cancelButtonColor
        closeButton.setTitleColor(UIColor(named: "lable_secondary") ?? .black, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertContainer.addSubview(closeButton)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle(confirmButtonText, for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        confirmButton.layer.cornerRadius = 12
        confirmButton.backgroundColor = confirmButtonColor
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        alertContainer.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            alertContainer.widthAnchor.constraint(equalToConstant: 335),
            alertContainer.heightAnchor.constraint(equalToConstant: 166),
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            messageLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),
            
            closeButton.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            closeButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 143),
            closeButton.heightAnchor.constraint(equalToConstant: 48),
            
            confirmButton.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(equalToConstant: 143),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func confirmAction() {
        dismiss(animated: true) {
            self.onConfirm?()
        }
    }
}
