//
//  ScoreSearchViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/19/24.
//

import UIKit

class ScoreSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
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
        
        searchView.parentViewController = self // parentViewController 연결
        
        searchView.searchTextField.delegate = self
        
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
            
            // 상태 업데이트: 빈 검색 화면 표시
            searchView.beforeSearchView.isHidden = false
            searchView.emptyResultView.isHidden = true
            searchView.tableView.isHidden = true
            return
        }
        
        filteredScores = scoreList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        searchView.tableHeaderLabel.isHidden = false
        
        // 상태 업데이트: 결과 여부에 따라 뷰 전환
        if filteredScores.isEmpty {
            searchView.beforeSearchView.isHidden = true
            searchView.emptyResultView.isHidden = false
            searchView.tableView.isHidden = true
        } else {
            searchView.beforeSearchView.isHidden = true
            searchView.emptyResultView.isHidden = true
            searchView.tableView.isHidden = false
        }
        
        searchView.tableView.reloadData()
    }
    
    // MARK: - 텍스트필드 테두리 컬러 지정
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 텍스트 필드가 선택되었을 때
        searchView.searchTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트 필드 선택이 해제되었을 때
        searchView.searchTextField.layer.borderColor = UIColor(named: "border_secondary")?.cgColor
    }
    
    // MARK: - UITableViewDataSource
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedScore = filteredScores[indexPath.row]
        let practiceViewController = ScorePracticeViewController(currentScore: selectedScore)
        navigationController?.pushViewController(practiceViewController, animated: true)
    }
}
