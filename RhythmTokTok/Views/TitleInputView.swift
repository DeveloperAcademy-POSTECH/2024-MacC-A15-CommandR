//
//  TitleInputView\.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 11/9/24.
//

import UIKit

protocol TitleInputViewDelegate: AnyObject {
    func updateAccessoryButtonState(isEnabled: Bool)
    func didTapCompleteButton(with filename: String)
    func updateBorderColor()
    func didClearTextField()
}

class TitleInputView: UIView {
    weak var delegate: TitleInputViewDelegate?
    var textField: UITextField!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var completeButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        // Title label 셋업
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "음악 제목을 입력해 주세요"
        titleLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor(named: "lable_secondary")
        addSubview(titleLabel)
        
        // Subtitle label 셋업
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "제목은 최대 20글자까지 쓸 수 있어요"
        subtitleLabel.font = UIFont.customFont(forTextStyle: .body2Regular)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = UIColor(named: "lable_tertiary")
        addSubview(subtitleLabel)

        // TextField 셋업
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.customFont(forTextStyle: .body1Medium)
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = UIColor(named: "lable_primary")
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(named: "border_primary")?.cgColor
        textField.layer.cornerRadius = 12
        textField.backgroundColor = UIColor(named: "background_secondary")
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged) // Register for text changes
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
        textField.leftViewMode = .always
        textField.placeholder = "예) 봄날은 간다 - 아코디언"
        
        // text field의 취소 버튼
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = UIColor(named: "lable_quaternary") ?? .lightGray
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        rightPaddingView.addSubview(clearButton)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        addSubview(textField)
        
        // Complete button 셋업
        completeButton = UIButton(type: .system)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setTitle("입력 완료", for: .normal)
        completeButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        completeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = UIColor(named: "button_inactive")
        completeButton.layer.cornerRadius = 12
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        addSubview(completeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 제목과 부제목의 제약 조건
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // 텍스트필드 제약조건
            textField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 64),
                
            // 완료 버튼 제약 조건
            completeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 64),
            completeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func clearTextField() {
        delegate?.didClearTextField()
    }
    
    @objc private func completeButtonTapped() {
        delegate?.didTapCompleteButton(with: textField.text!)
    }
    
    // 변화를 감지할 UITextFieldDelegate 메서드
    @objc private func textFieldDidChange() {
        delegate?.updateBorderColor()
    }
}
