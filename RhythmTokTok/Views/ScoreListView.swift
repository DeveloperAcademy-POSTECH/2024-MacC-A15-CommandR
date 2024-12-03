//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//

import UIKit

class ScoreListView: UIView {
    let navigationBar = CommonNavigationBar()
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        return view
    }()
    
    // 테이블 라벨 선언
    let tableHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "음악 목록"
        label.font = UIFont.customFont(forTextStyle: .heading1Bold)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 테이블 선언
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor(named: "background_tertiary")
        return tableView
    }()
    
    // 하단 버튼 선언
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" 음악 추가하기", for: .normal)
        button.setImage(UIImage(named: "add"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .body2Medium)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // 텍스트와 아이콘 간의 여백 설정
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        // 버튼 크기를 텍스트와 이미지에 맞게 조정
        button.sizeToFit()

        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2) // 그림자의 방향과 거리
        button.layer.shadowOpacity = 0.3 // 그림자의 투명도
        button.layer.shadowRadius = 4 // 그림자의 흐림 정도
        return button
    }()
    
    // 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNavigationBar() {
        navigationBar.configure(title: "", buttonType: .main)
        addSubview(navigationBar)
        addSubview(divider)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
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
    
    // 뷰 구성
    private func setupView() {
        backgroundColor = .backgroundPrimary
      
        let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .backgroundTertiary // 배경색 설정
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        addSubview(containerView)
        
        // ScrollView 선언
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .backgroundTertiary
        containerView.addSubview(scrollView)

        // ContentView (스크롤뷰 내부 콘텐츠) 선언
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Header + TableView를 합친 새로운 뷰 선언
        let headerAndTableView = UIView()
        headerAndTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerAndTableView)

        headerAndTableView.addSubview(tableHeaderLabel)
        headerAndTableView.addSubview(tableView)
//        containerView.addSubview(tableHeaderLabel)
//        containerView.addSubview(tableView)
        containerView.addSubview(addButton)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 컨테이너 뷰 레이아웃
            containerView.topAnchor.constraint(equalTo: divider.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerAndTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerAndTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerAndTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 헤더 레이블 레이아웃
            tableHeaderLabel.topAnchor.constraint(equalTo: headerAndTableView.topAnchor),
            tableHeaderLabel.leadingAnchor.constraint(equalTo: headerAndTableView.leadingAnchor),
            tableHeaderLabel.trailingAnchor.constraint(equalTo: headerAndTableView.trailingAnchor),
            
            // 테이블뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: tableHeaderLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: headerAndTableView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: headerAndTableView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: headerAndTableView.bottomAnchor),
            
            // 하단 버튼 레이아웃
            addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 139),
            addButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
