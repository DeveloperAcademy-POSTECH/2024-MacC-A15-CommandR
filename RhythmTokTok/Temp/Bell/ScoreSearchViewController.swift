//
//  ScoreSearchViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/19/24.
//

import UIKit

class ScoreSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    private let navigationBar = CommonNavigationBar()
    private let searchBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "background_primary")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let customSearchBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "background_secondary")
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "border_secondary")?.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "음악 제목을 입력해주세요"
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // Placeholder 색상 설정
        let placeholderColor = UIColor(named: "placeholder") ?? .gray
        textField.attributedPlaceholder = NSAttributedString(
            string: "음악 제목을 입력해주세요",
            attributes: [.foregroundColor: placeholderColor]
        )
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let tableView = UITableView()
    
    private var scoreList: [Score] = [] // 모든 악보 리스트
    private var filteredScores: [Score] = [] // 검색된 악보 리스트
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background_primary")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
        setupConstraints()
    }
    
    func configure(with scores: [Score]) {
        self.scoreList = scores
        self.filteredScores = scores
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        navigationBar.configure(title: "음악 검색")
        navigationBar.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        view.addSubview(searchBackgroundView)
        customSearchBar.addSubview(searchIcon)
        customSearchBar.addSubview(searchTextField)
        searchBackgroundView.addSubview(customSearchBar)
        
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "background_tertiary")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 64),
            
            searchBackgroundView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            searchBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBackgroundView.heightAnchor.constraint(equalToConstant: 64),
            
            customSearchBar.leadingAnchor.constraint(equalTo: searchBackgroundView.leadingAnchor, constant: 20),
            customSearchBar.trailingAnchor.constraint(equalTo: searchBackgroundView.trailingAnchor, constant: -20),
            customSearchBar.topAnchor.constraint(equalTo: searchBackgroundView.topAnchor, constant: 8),
            customSearchBar.heightAnchor.constraint(equalToConstant: 48),
            
            searchIcon.leadingAnchor.constraint(equalTo: customSearchBar.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: customSearchBar.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: customSearchBar.trailingAnchor, constant: -12),
            searchTextField.centerYAnchor.constraint(equalTo: customSearchBar.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBackgroundView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func searchTextChanged() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            filteredScores = scoreList
            tableView.reloadData()
            return
        }
        filteredScores = scoreList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        tableView.reloadData()
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredScores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let selectedScore = filteredScores[indexPath.row]
        let practiceViewController = ScorePracticeViewController(currentScore: selectedScore)
        navigationController?.pushViewController(practiceViewController, animated: true)
    }
}
