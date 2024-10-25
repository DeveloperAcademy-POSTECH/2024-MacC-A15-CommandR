//
//  ListItemCellView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit

class ListItemCellView: UITableViewCell {
    
    // identifier를 static 상수로 정의
    static let identifier = "ListItemCellView"
    
    // 둥근 모서리 배경을 위한 뷰
    let roundedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white  // 기본 배경색
        view.layer.cornerRadius = 12   // 둥근 모서리
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 레이블
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 셀과 contentView의 배경을 투명하게 설정
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // selectedBackgroundView를 투명한 뷰로 설정하여 기본 선택 배경 제거
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = .clear
        selectedBackgroundView = selectedBackground
        
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
    
   // ---
    
    // 선택 및 하이라이트 상태에 따른 배경색 변경
        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            updateBackgroundColor()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            updateBackgroundColor()
        }

        // 배경색 업데이트 메서드
        private func updateBackgroundColor() {
            if isHighlighted || isSelected {
                roundedBackgroundView.backgroundColor = UIColor.lightGray  // 선택되었을 때의 색상
            } else {
                roundedBackgroundView.backgroundColor = UIColor.white  // 기본 색상
            }
        }
}
