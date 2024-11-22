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
    private let highlightedTexts: [String]
    private let highlightColor: UIColor

    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    init(title: String,
         message: String,
         confirmButtonText: String,
         cancelButtonText: String,
         confirmButtonColor: UIColor,
         cancelButtonColor: UIColor,
         highlightedTexts: [String],
         highlightColor: UIColor = UIColor(named: "button_danger") ?? .red) {
        self.titleText = title
        self.messageText = message
        self.confirmButtonText = confirmButtonText
        self.cancelButtonText = cancelButtonText
        self.confirmButtonColor = confirmButtonColor
        self.cancelButtonColor = cancelButtonColor
        self.highlightedTexts = highlightedTexts
        self.highlightColor = highlightColor
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

        let alertContainer = createAlertContainer()
        view.addSubview(alertContainer)

        let titleLabel = createLabel(text: titleText, fontName: "Pretendard-Bold", fontSize: 21)
        alertContainer.addSubview(titleLabel)

        let messageLabel = createLabel(text: messageText, fontName: "Pretendard-Medium", fontSize: 16)
        applyHighlights(to: messageLabel)
        alertContainer.addSubview(messageLabel)

        let closeButton = createButton(title: cancelButtonText, color: cancelButtonColor, action: #selector(cancelButtonTapped))
        alertContainer.addSubview(closeButton)

        let confirmButton = createButton(title: confirmButtonText, color: confirmButtonColor, action: #selector(confirmAction))
        alertContainer.addSubview(confirmButton)

        setupConstraints(for: alertContainer, titleLabel: titleLabel, messageLabel: messageLabel, closeButton: closeButton, confirmButton: confirmButton)
    }

    private func createAlertContainer() -> UIView {
        let alertContainer = UIView()
        alertContainer.backgroundColor = UIColor(named: "background_primary")
        alertContainer.layer.cornerRadius = 16
        alertContainer.translatesAutoresizingMaskIntoConstraints = false
        return alertContainer
    }

    private func createLabel(text: String, fontName: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: fontName, size: fontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.layer.cornerRadius = 12
        button.backgroundColor = color
        
        // 텍스트 색상 설정
        if color == UIColor(named: "button_cancel") {
            button.setTitleColor(UIColor.black, for: .normal) // button_secondary 배경일 경우 검정색 텍스트
        } else {
            button.setTitleColor(.white, for: .normal) // 그 외 배경일 경우 흰색 텍스트
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func setupConstraints(for alertContainer: UIView, titleLabel: UILabel, messageLabel: UILabel, closeButton: UIButton, confirmButton: UIButton) {
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

    private func applyHighlights(to label: UILabel) {
        guard let text = label.text else { return }
        let attributedMessage = NSMutableAttributedString(string: text)
        
        // 기본 색상 적용
        attributedMessage.addAttribute(
            .foregroundColor,
            value: UIColor(named: "lable_secondary") ?? .black,
            range: NSRange(location: 0, length: text.count)
        )

        // 강조 텍스트 색상 적용
        for highlightedText in highlightedTexts {
            if let range = text.range(of: highlightedText) {
                let nsRange = NSRange(range, in: text)
                attributedMessage.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
            }
        }

        label.attributedText = attributedMessage
    }

    @objc private func confirmAction() {
        dismiss(animated: true) {
            self.onConfirm?()
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) {
            self.onCancel?()
        }
    }
}
