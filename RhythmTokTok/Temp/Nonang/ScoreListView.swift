//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import UIKit

class ScoreListView: UIView {
    
    // 테이블뷰 선언
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .gray03
        return tableView
    }()
    
    // 제목 라벨 선언
    let tableHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "악보 목록"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left  // 좌측 정렬
        label.frame = CGRect(x: 16, y: 15, width: UIScreen.main.bounds.width - 32, height: 30)
        return label
    }()
    
    // 하단 버튼 선언
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("악보 추가하기", for: .normal)
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

        // 테이블뷰 헤더 설정
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        headerView.addSubview(tableHeaderLabel)
        tableView.tableHeaderView = headerView

        // 테이블뷰 설정
        addSubview(tableView)
        
        // 하단 버튼 추가
        addSubview(addButton)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 테이블 뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
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
