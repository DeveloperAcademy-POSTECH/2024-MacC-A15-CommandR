//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import UIKit

class ScoreListView: UIView {
    
    // 테이블 라벨 선언
    let tableHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "악보 목록"
        let customFont = UIFont(name: "Pretendard-Bold", size: 24)
        label.font = customFont
        label.textAlignment = .left  // 좌측 정렬
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 테이블 선언
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .gray03
        return tableView
    }()
    
    // 하단 버튼 선언
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 악보 추가하기", for: .normal)
        button.setImage(UIImage(systemName: "document"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 뷰 구성
    private func setupView() {
        backgroundColor = UIColor.systemGray6
        
        addSubview(tableHeaderLabel)
        addSubview(tableView)
        addSubview(addButton)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 헤더 레이블 레이아웃
            tableHeaderLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableHeaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 테이블뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: tableHeaderLabel.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 하단 버튼 레이아웃
            addButton.widthAnchor.constraint(equalToConstant: 139),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
