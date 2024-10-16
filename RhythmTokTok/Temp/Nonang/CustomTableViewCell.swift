//
//  CustomTableViewCell.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    // identifier를 static 상수로 정의
        static let identifier = "CustomTableViewCell"
    
    // 둥근 모서리 배경을 위한 뷰
        let roundedBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = .white  // 흰색 배경
            view.layer.cornerRadius = 12   // 둥근 모서리
            view.layer.masksToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    // 레이블을 포함하는 컨텐츠 뷰
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 셀 자체의 배경을 투명하게 설정 (테이블 뷰의 배경색을 그대로 보이도록)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 둥근 배경 뷰 추가
        contentView.addSubview(roundedBackgroundView)
        roundedBackgroundView.addSubview(titleLabel)
        
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            // roundedBackgroundView의 레이아웃 설정
            roundedBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            roundedBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            roundedBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            roundedBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // titleLabel의 레이아웃 설정
            titleLabel.centerYAnchor.constraint(equalTo: roundedBackgroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀에 데이터를 설정하는 함수
    func configure(with title: String) {
        titleLabel.text = title
    }
}
