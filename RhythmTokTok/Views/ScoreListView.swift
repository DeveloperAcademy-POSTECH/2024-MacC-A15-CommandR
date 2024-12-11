//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import UIKit

class ScoreListView: UIView {
    
    // MARK: - UI 구성 요소

    let navigationBar = CommonNavigationBar()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 테이블 헤더 라벨
    let tableHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "음악 목록"
        label.font = UIFont.customFont(forTextStyle: .heading1Bold)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 테이블 뷰
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "background_tertiary")
        return tableView
    }()
    
    // TODO: 악보 추가하기 버튼 임시 주석처리
//    // 하단 버튼 선언
//    let addButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle(" 음악 추가하기", for: .normal)
//        button.setImage(UIImage(named: "add"), for: .normal)
//        button.tintColor = .white
//        button.backgroundColor = UIColor.systemBlue
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.titleLabel?.font = UIFont.customFont(forTextStyle: .body2Medium)
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        
//        // 텍스트와 아이콘 간의 여백 설정
//        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
//        
//        // 버튼 크기를 텍스트와 이미지에 맞게 조정
//        button.sizeToFit()
//        
//        // 그림자 설정
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2) // 그림자의 방향과 거리
//        button.layer.shadowOpacity = 0.3 // 그림자의 투명도
//        button.layer.shadowRadius = 4 // 그림자의 흐림 정도
//        return button
//    }()
    
    // MARK: - 초기화

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 설정 메서드

    private func setupNavigationBar() {
        navigationBar.configure(title: "", buttonType: .main)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)
        addSubview(divider)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 64),
            
            divider.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupView() {
        backgroundColor = .backgroundPrimary
        
        addSubview(tableView)
//        addSubview(addButton)
        
        // 테이블 헤더 설정
        let headerContainer = UIView()
        headerContainer.backgroundColor = .backgroundTertiary
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(tableHeaderLabel)
        
        NSLayoutConstraint.activate([
            tableHeaderLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            tableHeaderLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 24),
            tableHeaderLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            tableHeaderLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 0)
        ])
        
        // 헤더 크기 계산
        headerContainer.layoutIfNeeded()
        let headerSize = headerContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerContainer.frame = CGRect(x: 0, y: 0, width: frame.width, height: headerSize.height)
        tableView.tableHeaderView = headerContainer
        
        // 레이아웃 제약조건 설정
        NSLayoutConstraint.activate([
            // 테이블뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: divider.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
//            // 추가 버튼 레이아웃
//            addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 139),
//            addButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
//            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
}
