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
        containerView.addSubview(tableHeaderLabel)
        containerView.addSubview(tableView)
        containerView.addSubview(addButton)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 컨테이너 뷰 레이아웃
            containerView.topAnchor.constraint(equalTo: divider.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 헤더 레이블 레이아웃
            tableHeaderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            tableHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tableHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // 테이블뷰 레이아웃
            tableView.topAnchor.constraint(equalTo: tableHeaderLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // 하단 버튼 레이아웃
            addButton.widthAnchor.constraint(equalToConstant: 139),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
