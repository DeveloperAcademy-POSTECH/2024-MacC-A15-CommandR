//
//  ScoreSearchViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/19/24.
//

import UIKit

class ScoreSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    private let navigationBar = CommonNavigationBar()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private var searchBar: UISearchBar!
    private var tableView: UITableView!
    private var scoreList: [Score] = [] // 모든 악보 리스트
    private var filteredScores: [Score] = [] // 검색된 악보 리스트

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        
        // 네비게이션 바 숨기고 커스텀 바 사용
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
    }

    func configure(with scores: [Score]) {
        self.scoreList = scores
        self.filteredScores = scores
    }

    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationBar.configure(title: "음악 검색")
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }

            if self.navigationController != nil {
                // Navigation Controller가 있는 경우 popViewController 호출
                self.navigationController?.popViewController(animated: true)
            } else {
                // Navigation Controller가 없는 경우 dismiss 호출
                self.dismiss(animated: true, completion: nil)
            }
        }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        // 그림자 제거를 위한 설정
         navigationBar.layer.shadowColor = UIColor.clear.cgColor
         navigationBar.layer.shadowOpacity = 0
         navigationBar.layer.shadowOffset = CGSize.zero
         navigationBar.layer.shadowRadius = 0
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "악보 제목을 검색하세요"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self

        // 기존 ListItemCellView를 재사용
        tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none // 기존 스타일 유지
        tableView.backgroundColor = UIColor.backgroundTertiary // 배경색 맞춤
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Search Bar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredScores = scoreList
        } else {
            // CoreData에서 전달된 scoreList의 제목을 검색
            filteredScores = scoreList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredScores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ListItemCellView를 사용하여 구성
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCellView.identifier,
                                                       for: indexPath) as? ListItemCellView else {
            return UITableViewCell()
        }
        cell.configure(with: filteredScores[indexPath.row].title)
        return cell
    }

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 선택된 악보
        let selectedScore = filteredScores[indexPath.row]

        // ScorePracticeViewController로 이동
        let practiceViewController = ScorePracticeViewController(currentScore: selectedScore)
        navigationController?.pushViewController(practiceViewController, animated: true)
    }
}
