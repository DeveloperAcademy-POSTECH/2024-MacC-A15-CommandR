//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/14/24.
//
import UIKit
import Lottie

protocol PDFUploadDoneViewDelegate: AnyObject {
    func didTapDismissButton()
    func didTapNavigateButton()
}

class PDFUploadDoneView: UIView {
    weak var delegate: PDFUploadDoneViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        startLottieAnimation()
    }
    
    var lottieView: LottieAnimationView!
    var titleLabel: UILabel!
    var subtitleLabel1: UILabel!
    var subtitleLabel2: UILabel!
    var subtitleLabel3: UILabel!
    var dismissButton: UIButton!
    var navigateButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        // LottieView 셋업
        lottieView = LottieAnimationView(name: "Change")
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.contentMode = .center
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
//        lottieView.isHidden =
        addSubview(lottieView)
        
        // Title label 셋업
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "음악 요청이 완료되었어요"
        titleLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(named: "lable_primary")
        addSubview(titleLabel)
        
        // Subtitle label1 셋업
        subtitleLabel1 = UILabel()
        subtitleLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        // Full text
        let fullText = "요청하신 음악은 1~2일 내로 완성될 거에요."

        // Create an NSMutableAttributedString for the full text
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .foregroundColor: UIColor(named: "lable_tertiary") ?? .gray
        ])

        // Define the range for "1~2일 내" and apply a different color
        if let highlightRange = fullText.range(of: "1~2일 내") {
            let nsRange = NSRange(highlightRange, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor(named: "blue500") ?? .blue, range: nsRange)
        }

        subtitleLabel1.attributedText = attributedString
        subtitleLabel1.font = UIFont.customFont(forTextStyle: .body2Medium)
        subtitleLabel1.adjustsFontForContentSizeCategory = true
        subtitleLabel1.textAlignment = .center
        addSubview(subtitleLabel1)
        
        // Subtitle label2 셋업
        subtitleLabel2 = UILabel()
        subtitleLabel2.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel2.text = "완료 시 알림을 보내드릴게요."
        subtitleLabel2.font = UIFont.customFont(forTextStyle: .body2Medium)
        subtitleLabel2.adjustsFontForContentSizeCategory = true
        subtitleLabel2.textAlignment = .center
        subtitleLabel2.textColor = UIColor(named: "lable_tertiary")
        addSubview(subtitleLabel2)
        
        // dismissButton 셋업
        dismissButton = UIButton(type: .system)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setTitle("확인", for: .normal)
        dismissButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        dismissButton.titleLabel?.adjustsFontForContentSizeCategory = true
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.backgroundColor = UIColor(named: "button_primary")
        dismissButton.layer.cornerRadius = 12
        // TODO: dismiss action 연결하기
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        addSubview(dismissButton)
        
        // navigateButton 셋업
        navigateButton = UIButton(type: .system)
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        navigateButton.setTitle("요청한 음악 목록 보기", for: .normal)
        navigateButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button2Medium)
        navigateButton.titleLabel?.adjustsFontForContentSizeCategory = true
        navigateButton.titleLabel?.textColor = UIColor(named: "lable_secondary")
        navigateButton.backgroundColor = UIColor(.white)
        navigateButton.layer.cornerRadius = 12
        // TODO: navigateButton action 연결하기
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
        addSubview(navigateButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lottieView.topAnchor.constraint(equalTo: topAnchor, constant: 210),
            lottieView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lottieView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lottieView.heightAnchor.constraint(equalToConstant: 120),
            
            // 제목과 부제목의 제약 조건
            titleLabel.topAnchor.constraint(equalTo: lottieView.bottomAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel1.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel2.topAnchor.constraint(equalTo: subtitleLabel1.bottomAnchor, constant: 8),
            subtitleLabel2.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Dismiss button 제약 조건
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dismissButton.heightAnchor.constraint(equalToConstant: 64),
            dismissButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            // Navigate button 제약 조건
            navigateButton.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 16),
            navigateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            navigateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            navigateButton.heightAnchor.constraint(equalToConstant: 50),
            navigateButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -40)
        ])
    }
    
    private func startLottieAnimation() {
        lottieView.play()
    }
    
    @objc private func dismissButtonTapped() {
        delegate?.didTapDismissButton()
    }
    
    @objc private func navigateButtonTapped() {
        delegate?.didTapNavigateButton()
    }
}
