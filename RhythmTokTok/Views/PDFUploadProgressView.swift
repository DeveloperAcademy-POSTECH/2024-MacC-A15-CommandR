//
//  PDFUploadProgressView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/21/24.
//


import UIKit
import Lottie


class PDFUploadProgressView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        startLottieAnimation()
    }
    
    var lottieView: LottieAnimationView!
    var titleLabel1: UILabel!
    var titleLabel2: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        // LottieView 셋업
        lottieView = LottieAnimationView(name: "Loading")
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.contentMode = .center
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.0
        addSubview(lottieView)
        
        // Title label1 셋업
        titleLabel1 = UILabel()
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        titleLabel1.text = "음악 요청을 보내는 중이에요"
        titleLabel1.font = UIFont.customFont(forTextStyle: .heading2Bold)
        titleLabel1.adjustsFontForContentSizeCategory = true
        titleLabel1.textAlignment = .center
        titleLabel1.textColor = UIColor(named: "lable_primary")
        addSubview(titleLabel1)
        
        // Title label2 셋업
        titleLabel2 = UILabel()
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        titleLabel2.text = "잠시만 기다려 주세요"
        titleLabel2.font = UIFont.customFont(forTextStyle: .heading2Bold)
        titleLabel2.textAlignment = .center
        titleLabel2.textColor = UIColor(named: "lable_primary")
        addSubview(titleLabel2)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lottieView.topAnchor.constraint(equalTo: topAnchor, constant: 210),
            lottieView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lottieView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lottieView.heightAnchor.constraint(equalToConstant: 120),
            
            // 제목의 제약 조건
            titleLabel1.topAnchor.constraint(equalTo: lottieView.bottomAnchor, constant: 40),
            titleLabel1.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            
            titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 10),
            titleLabel2.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    private func startLottieAnimation() {
        lottieView.play()
    }
}
