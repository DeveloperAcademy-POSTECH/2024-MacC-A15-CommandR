//
//  TitleInputView\.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 11/9/24.
//

import UIKit

class TitleInputView: UIView, UITextFieldDelegate {
    var textField: UITextField!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var completeButton: UIButton!
    private let maxCharacterLimit = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Title label setup
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "제목을 입력해 주세요"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        addSubview(titleLabel)
        
        // Subtitle label setup
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "제목은 최대 20글자까지 쓸 수 있어요"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.gray
        addSubview(subtitleLabel)

        // TextField setup
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: "Pretendard-Medium", size: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(named: "button_primary")?.cgColor ?? UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 12
        textField.backgroundColor = UIColor.systemGray6
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
        textField.leftViewMode = .always
        textField.placeholder = "예) 봄날은 간다 - 아코디언"
        
        // Clear button for text field
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = UIColor(named: "label_quaternary") ?? .lightGray
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        rightPaddingView.addSubview(clearButton)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        addSubview(textField)
        
        // Complete button setup
        completeButton = UIButton(type: .system)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setTitle("입력 완료", for: .normal)
        completeButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = UIColor.systemBlue
        completeButton.layer.cornerRadius = 12
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        addSubview(completeButton)

        // Title and subtitle constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])

        // TextField constraints
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 64)
        ])

        // Complete button constraints
        NSLayoutConstraint.activate([
            completeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 64),
            completeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func clearTextField() {
        textField.text = ""
        updateBorderColor()
    }
    
    @objc private func completeButtonTapped() {
        // Add action for "입력 완료" button tap, such as validating input and performing next steps
        print("입력 완료 button tapped!")
    }
    
    // UITextFieldDelegate method to monitor changes
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateBorderColor()
    }

    private func updateBorderColor() {
        if let text = textField.text, text.count > maxCharacterLimit {
            textField.layer.borderColor = UIColor.red.cgColor
            subtitleLabel.textColor = UIColor.red
        } else {
            textField.layer.borderColor = UIColor(named: "button_primary")?.cgColor ?? UIColor.systemBlue.cgColor
            subtitleLabel.textColor = UIColor.gray
        }
    }
}
