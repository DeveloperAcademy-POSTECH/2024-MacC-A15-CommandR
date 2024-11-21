//
//  ScoreSearchViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/19/24.
//

import UIKit

class ScoreSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var searchView: ScoreSearchView! {
        return view as? ScoreSearchView
    }
    
    private var scoreList: [Score] = [] // 모든 악보 리스트
    private var filteredScores: [Score] = [] // 검색된 악보 리스트

    override func loadView() {
        view = ScoreSearchView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
    }
    
    func configure(with scores: [Score]) {
        self.scoreList = scores
    }
    
    @objc private func searchTextChanged() {
        guard let searchText = searchView.searchTextField.text, !searchText.isEmpty else {
            filteredScores = []
            searchView.tableHeaderLabel.isHidden = true
            searchView.searchTextField.layer.borderColor = UIColor(named: "border_secondary")?.cgColor
            searchView.tableView.reloadData()
            return
        }
        
        filteredScores = scoreList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        searchView.tableHeaderLabel.isHidden = false
        searchView.searchTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        searchView.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCellView.identifier, for: indexPath) as? ListItemCellView else {
            return UITableViewCell()
        }
        cell.configure(with: filteredScores[indexPath.row].title)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedScore = filteredScores[indexPath.row]
        let practiceViewController = ScorePracticeViewController(currentScore: selectedScore)
        navigationController?.pushViewController(practiceViewController, animated: true)
    }
}
