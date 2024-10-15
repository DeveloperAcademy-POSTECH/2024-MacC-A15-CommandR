//
//  ProgressTableViewCell.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class ProgressButtonTableViewCell: UITableViewCell {

    let progressBar = MeasureProgressView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        selectionStyle = .none
        // 프로그레스 버튼 추가
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressBar)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            progressBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            progressBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            progressBar.heightAnchor.constraint(equalToConstant: 56) // 높이 56 설정
        ])
        
        // 버튼이 터치 이벤트를 받지 않게 설정
        progressBar.isUserInteractionEnabled = false
    }

    // 프로그레스 값을 설정하는 함수
    func configure(progress: CGFloat) {
        progressBar.progress = progress
    }
    
    // 버튼 네임 설정
    func setTitle(buttonName: String) {
        progressBar.titleLabel.text = buttonName
    }
}
