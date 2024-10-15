//
//  MeasureProgressView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MeasureProgressView: UIView {
    private let progressView = UIView()
    private var progressWidthConstraint: NSLayoutConstraint!

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
        self.backgroundColor = .gray03
        self.layer.cornerRadius = 12 // 라운드 처리 (높이 56에 대한 절반)
        self.clipsToBounds = true

        // ProgressView 설정
        progressView.backgroundColor = .progress
        progressView.layer.cornerRadius = 0 // 라운드 처리
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)

        // 레이아웃 제약 조건
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressWidthConstraint
        ])
    }

    // 프로그레스 업데이트 함수
    private func updateProgress() {
        let totalWidth = self.bounds.width
        progressWidthConstraint.constant = totalWidth * progress
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 프로그레스 바의 너비가 변경될 때마다 업데이트
        updateProgress()
    }
}
