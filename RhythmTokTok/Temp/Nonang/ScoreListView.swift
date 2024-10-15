//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit

class ScoreListView: UIView {
    
    // 테이블뷰 선언
    let tableView = UITableView()
    
    // 하단 버튼 선언
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 악보 추가하기", for: .normal)
        button.setImage(UIImage(systemName: "document"), for: .normal)
        
        // 버튼 스타일 설정
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
        
        // 테이블뷰 설정
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 하단 버튼 추가
        addSubview(addButton)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 테이블 뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            
            // 하단 버튼 레이아웃
            addButton.widthAnchor.constraint(equalToConstant: 139),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
