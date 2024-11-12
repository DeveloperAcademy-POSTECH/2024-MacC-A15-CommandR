//
//  MeasureProgressView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MeasureProgressView: UIView {
    private let progressView = UIView()
    private let progressIndicatorImageView = UIImageView()
    private var progressWidthConstraint: NSLayoutConstraint!
    
    let titleHeader: UILabel = {
        let label = UILabel()
        label.text = "🎼"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // 기본 레이아웃 설정
        self.backgroundColor = .gray
        self.layer.cornerRadius = 12
        self.clipsToBounds = true

        // ProgressView 설정
        progressView.backgroundColor = .gray
        progressView.layer.cornerRadius = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        // 이미지 뷰 설정
        progressIndicatorImageView.image = UIImage(named: "progressCursor")
        progressIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressIndicatorImageView)
        addSubview(titleHeader)
        addSubview(titleLabel)

        // 레이아웃 제약 조건
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressWidthConstraint,
            
            // 이미지 뷰 제약 조건
            progressIndicatorImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressIndicatorImageView.heightAnchor.constraint(equalToConstant: 62),
            
            // 타이틀 제약 조건
            titleHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleHeader.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleHeader.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // 프로그레스 업데이트 함수
    private func updateProgress() {
        let totalWidth = self.bounds.width
        let progressWidth = totalWidth * progress
        progressWidthConstraint.constant = progressWidth

        progressIndicatorImageView.isHidden = progress >= 1.0
        UIView.animate(withDuration: 0.25) {
            self.progressIndicatorImageView.center.x = progressWidth
            self.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 프로그레스 바의 너비가 변경될 때마다 업데이트
        updateProgress()
    }
}
