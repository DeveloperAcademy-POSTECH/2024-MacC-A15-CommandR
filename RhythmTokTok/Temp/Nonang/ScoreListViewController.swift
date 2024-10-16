//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit
import UniformTypeIdentifiers

class ScoreListViewController: UIViewController {
    
    var selectedFileURL: URL?
    
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
        setupTableView()

        // 하단 버튼 액션 연결
        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // 네비게이션 바 설정
    func setupNavigationBar() {
        // 네이게이션 바 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명 배경 설정
        appearance.backgroundColor = .white  // 네비게이션 바 배경색 흰색 설정
        appearance.shadowColor = .clear  // 하단의 그림자 제거 (선 제거)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // 텍스트 색상 설정

        // 기본 Appearance 설정
        navigationController?.navigationBar.standardAppearance = appearance
        // 스크롤 시 적용할 Appearance 설정
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 버튼 색상 설정
        navigationController?.navigationBar.tintColor = .black
        
        // 네비게이션 바 버튼 설정
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(didTapSettings))
        
        navigationItem.rightBarButtonItems = [settingsButton, searchButton]
    }
    
    // 테이블 뷰 설정
    func setupTableView() {
        // 테이블 뷰 배경을 회색으로 설정
        scoreListView.tableView.backgroundColor = UIColor.systemGray6
        
        // 테이블 뷰 기본 컴포넌트 연결
        scoreListView.tableView.delegate = self
        scoreListView.tableView.dataSource = self
        scoreListView.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)

        // 셀 사이의 separator 제거
        scoreListView.tableView.separatorStyle = .none
    }
    
    @objc func didTapSearch() {
        print("Search tapped")
    }
    
    @objc func didTapSettings() {
        print("Settings tapped")
    }
    
    // PDF 파일 선택 버튼 액션
    @objc private func didTapAddButton() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: musicList[indexPath.row])
        return cell
    }
    
    // 각 셀의 높이를 70으로 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // 섹션 사이 간격 설정 (상, 하 간격)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10  // 섹션 사이 간격
    }
}


// PDF 파일 선택에 사용되는 extension
extension ScoreListViewController: UIDocumentPickerDelegate {
    
    // 파일 선택에 호출
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        // 선택된 파일 URL을 저장하고 확인 화면으로 이동
        self.selectedFileURL = selectedFileURL
        self.navigateToCheckPDFViewController(with: selectedFileURL)
    }
    
    // 선택한 파일 확인 뷰로 이동
    private func navigateToCheckPDFViewController(with fileURL: URL) {
        let checkPDFViewController = CheckPDFViewController()
        checkPDFViewController.fileURL = fileURL
        
        navigationController?.pushViewController(checkPDFViewController, animated: true)
    }
    
    // 취소 버튼을 누르면 호출되는 메소드
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("사용자가 파일 선택을 취소했습니다.")
    }
}
