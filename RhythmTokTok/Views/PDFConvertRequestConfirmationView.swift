//
//  PDFConvertRequestConfirmationView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/11/24.
//

//
//  TitleInputView\.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 11/9/24.
//

import UIKit

protocol PDFConvertRequestConfirmationViewDelegate: AnyObject {
    func didTapConfirmationButton()
}


class PDFConvertRequestConfirmationView: UIView {
    weak var delegate: PDFConvertRequestConfirmationViewDelegate?
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var confirmationButton: UIButton!

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
        titleLabel.text = "이대로 악보를 만들어 드릴까요?"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        addSubview(titleLabel)
        
        // Subtitle label 셋업
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "입력한 정보가 맞는지 확인해 주세요"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.gray
        addSubview(subtitleLabel)

        
        // confirmaationButton button 셋업
        confirmationButton = UIButton(type: .system)
        confirmationButton.translatesAutoresizingMaskIntoConstraints = false
        confirmationButton.setTitle("악보 요청 보내기", for: .normal)
        confirmationButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
        confirmationButton.setTitleColor(.white, for: .normal)
        confirmationButton.backgroundColor = UIColor.systemBlue
        confirmationButton.layer.cornerRadius = 12
        confirmationButton.addTarget(self, action: #selector(confirmationButtonTapped), for: .touchUpInside)
        addSubview(confirmationButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 제목과 부제목의 제약 조건
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                
            // confirmaationButton butto 버튼제약 조건
            confirmationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            confirmationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            confirmationButton.heightAnchor.constraint(equalToConstant: 64),
            confirmationButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func confirmationButtonTapped() {
           delegate?.didTapConfirmationButton()
       }
}
