//
//  ExtraInfoView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/11/24.
//

import UIKit

class ExtraInfoView: UIView {
    
    var text: String? {
        didSet {
            infoLabel.text = text
        }
    }
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(forTextStyle: .captionMedium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(named: "lable_tertiary")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(text: String? = nil) {
        self.text = text
        super.init(frame: .zero)
        setupView()
        infoLabel.text = text
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
