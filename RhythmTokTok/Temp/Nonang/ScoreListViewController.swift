//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit

class ScoreListViewController: UIViewController {

    // ScoreListView를 뷰로 사용
    var scoreListView: ScoreListView! {
        return view as? ScoreListView
    }
    
    // 데이터
    let musicList = [
        "꽃을 든 남자 - 이백호",
        "사랑의 배터리 - 홍진영",
        "꽃밭에서 / 아코디언",
        "울어라 열풍아~~",
        "갈대의 순정... 조순재",
        "생일 축하곡 - 손주 생일을 위해"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 설정
        setupNavigationBar()
        
        // 테이블 뷰 설정
        scoreListView.tableView.delegate = self
        scoreListView.tableView.dataSource = self
        scoreListView.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        
        // 테이블 뷰의 separator 제거
        scoreListView.tableView.separatorStyle = .none
        
        // 하단 버튼 액션 연결
        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // 네비게이션 바 설정
    func setupNavigationBar() {
        navigationItem.title = "악보 목록"
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(didTapSettings))
        
        navigationItem.rightBarButtonItems = [settingsButton, searchButton]
    }
    
    @objc func didTapSearch() {
        print("Search tapped")
    }
    
    @objc func didTapSettings() {
        print("Settings tapped")
    }
    
    @objc func didTapAddButton() {
        print("Add button tapped")
    }
    
    // UIView 대신 ScoreListView를 사용
    override func loadView() {
        view = ScoreListView()
    }
}

// UITableViewDelegate, UITableViewDataSource 구현
extension ScoreListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: musicList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70  // 각 셀의 높이를 70으로 설정
    }
}
