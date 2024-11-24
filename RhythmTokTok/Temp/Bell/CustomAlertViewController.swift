//
//  CustomAlertViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

class CustomAlertViewController: UIViewController {
    let titleText: String
    let messageText: String
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
        setupBackgroundDismissGesture()
        setupAlertView()
    }
    
    private func setupBackgroundDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupAlertView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let alertContainer = createAlertContainer()
        view.addSubview(alertContainer)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor(named: "lable_primary")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0 // 멀티라인 허용
        titleLabel.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        alertContainer.addSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = messageText
        messageLabel.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = UIColor(named: "lable_tertiary")
        messageLabel.numberOfLines = 0 // 멀티라인 허용
        messageLabel.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        applyHighlights(to: messageLabel)
        alertContainer.addSubview(messageLabel)

        let closeButton = createButton(title: cancelButtonText,
                                       color: cancelButtonColor,
                                       action: #selector(cancelButtonTapped))
        alertContainer.addSubview(closeButton)

        let confirmButton = createButton(title: confirmButtonText,
                                         color: confirmButtonColor,
                                         action: #selector(confirmAction))
        alertContainer.addSubview(confirmButton)

        setupConstraints(for: alertContainer,
                         titleLabel: titleLabel,
                         messageLabel: messageLabel,
                         closeButton: closeButton,
                         confirmButton: confirmButton)
    }

    private func createAlertContainer() -> UIView {
        let alertContainer = UIView()
        alertContainer.backgroundColor = UIColor(named: "background_primary")
        alertContainer.layer.cornerRadius = 16
        alertContainer.isUserInteractionEnabled = true
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
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.numberOfLines = 0 // 멀티라인 허용
        button.titleLabel?.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
//        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 38, bottom: 10, right: )
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

    private func setupConstraints(for alertContainer: UIView,
                                  titleLabel: UILabel,
                                  messageLabel: UILabel,
                                  closeButton: UIButton,
                                  confirmButton: UIButton) {
        NSLayoutConstraint.activate([
            alertContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            alertContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            alertContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 196),
            
            // titleLabel 제약 조건
            titleLabel.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -20),

            // messageLabel 제약 조건
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            messageLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -20),
            
            // closeButton 제약 조건
            closeButton.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 20),
            closeButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor), // 버튼 크기 동일
            closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48), // 텍스트 + 패딩

            // confirmButton 제약 조건
            confirmButton.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 143), // 최소 가로 크기
            confirmButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48), // 텍스트 + 패딩
            
            // 버튼 간 간격
            closeButton.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor, constant: -10),
            
            // alertContainer의 동적 높이 설정
            messageLabel.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20)
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
    
    // 알림창 말고 배경 누를때 창 꺼지기
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
         let touchPoint = gesture.location(in: view)
         let alertFrame = view.subviews.first?.frame ?? .zero
         if !alertFrame.contains(touchPoint) {
             dismiss(animated: true, completion: nil)
         }
     }
}
