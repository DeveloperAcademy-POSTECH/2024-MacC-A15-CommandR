//
//  MusicPracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeViewController: UIViewController {
    // 커스텀 네비게이션 바 선언
    let practicNavBar = PracticeNavigationBar()
    // MusicPracticeTitleView 선언
    let musicPracticeTitleView = MusicPracticeTitleView()
    // 테이블뷰 선언
    let tableView = UITableView()
    let progressData: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 0.4] // TODO: 여기에 줄 진행 정도 비율 계산 로직 연결 필요

    // Divider 역할을 할 선
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func loadView() {
        // 루트 뷰를 설정할 컨테이너 뷰 생성
        let containerView = UIView()
        containerView.backgroundColor = .white
        // 커스텀 네비게이션 바 추가
        containerView.addSubview(practicNavBar)
        practicNavBar.translatesAutoresizingMaskIntoConstraints = false
        // MusicPracticeView 추가
        containerView.addSubview(musicPracticeTitleView)
        musicPracticeTitleView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(divider) // divider

        // 루트 뷰 설정
        self.view = containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블 뷰 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProgressButtonTableViewCell.self, forCellReuseIdentifier: "ProgressButtonCell")
        view.addSubview(tableView)
        tableView.separatorStyle = .none // 구분선 없애기

        musicPracticeTitleView.titleLabel.text = "MoonRiver" // TODO: 여기에 제목 연결
        musicPracticeTitleView.pageLabel.text = "0/0장" // TODO: 여기에 페이지 내용 만들 함수 연결
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 커스텀 네비게이션 바와 MusicPracticeView 레이아웃 설정
        NSLayoutConstraint.activate([
            // 커스텀 네비게이션 바 레이아웃 설정
            practicNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practicNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practicNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practicNavBar.heightAnchor.constraint(equalToConstant: 60),
            
            // MusicPracticeView 레이아웃 설정 (네비게이션 바 아래에 위치)
            musicPracticeTitleView.topAnchor.constraint(equalTo: practicNavBar.bottomAnchor, constant: 10),
            musicPracticeTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            musicPracticeTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            musicPracticeTitleView.heightAnchor.constraint(equalToConstant: 30),

            // divider
            divider.topAnchor.constraint(equalTo: musicPracticeTitleView.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 좌우 패딩 없이 전체 너비
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            // 테이블뷰
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: divider.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MusicPracticeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressButtonCell", for: indexPath) as! ProgressButtonTableViewCell
        let progress = progressData[indexPath.row]
        cell.configure(progress: progress)
        cell.setTitle(buttonName: "\(indexPath.row)") // TODO: 장 줄 네임 연결
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Progress button at row \(indexPath.row) clicked")
        // TODO: 여기에 버튼 클릭 시 해당 줄부터 연주되게 만들기
    }
}
