//
//  InProgressInfoView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

class InProgressInfoView: UIView {
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "🚨 악보 완성까지 약 1~2일이 소요될 수 있어요"
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(named: "lable_tertiary")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "gray200")
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            infoLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
