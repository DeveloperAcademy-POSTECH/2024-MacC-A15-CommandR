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
    var scoreListView: ScoreListView! {
        return view as? ScoreListView
    }
    var scoreList: [Score] = []
    let mediaManager = MediaManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateMusicXMLAudio()
        
        // MARK: - ListView상단 바 제거, 나중에 검색 넣어야해서 주석처리함.
        // 네비게이션 바 설정
//        setupNavigationBar()
        
        // 테이블 뷰 설정
        setupTableView()
        
        // 하단 버튼 액션 연결
//        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // 네비게이션 바 설정
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명 배경 설정
        appearance.backgroundColor = .white  // 네비게이션 바 배경색 흰색 설정
        appearance.shadowColor = .clear  // 하단의 그림자 제거 (선 제거)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // 텍스트 색상 설정
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
        
//        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
//        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(didTapSettings))
        
//        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    // 테이블 뷰 설정
    func setupTableView() {
        scoreListView.tableView.backgroundColor = UIColor.systemGray6
        scoreListView.tableView.delegate = self
        scoreListView.tableView.dataSource = self
        scoreListView.tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
        scoreListView.tableView.separatorStyle = .none
    }
    
    // MARK: - 임시 파일 score생성
    private func generateMusicXMLAudio() {
//        let xmls = ["red", "mannam", "MoonRiver"]
        let xmls = ["doraji", "cry", "shinsadong", "kankan", "minuetGmajor", "star", "metronome"]
//        let scoreNames = ["붉은 노을 - 이문세", "만남 - 노사연", "Moon River"]
        let scoreNames = ["도라지타령", "울어라 열풍아", "신사동 그사람", "캉캉", "미뉴엣 G 장조", "반짝반짝 작은별", "메트로놈"]
      
        for (index, xmlName) in xmls.enumerated() {
            guard let xmlPath = Bundle.main.url(forResource: xmlName, withExtension: "xml") else {
                ErrorHandler.handleError(error: "Failed to find MusicXML file in bundle.")
                return
            }
            
            Task {
                do {
                    let xmlData = try Data(contentsOf: xmlPath)
                    print("Successfully loaded MusicXML data.")
                    let parser = MusicXMLParser()
                    let score = await parser.parseMusicXML(from: xmlData)
                    score.title = scoreNames[index]
                    
                    updateScore(score: score)
                    
                } catch {
                    ErrorHandler.handleError(error: error)
                }
            }
        }
    }
    
    private func updateScore(score: Score) {
        scoreList.append(score)
        print("score 생성")
        scoreListView.tableView.reloadData() // 테이블뷰 업데이트
    }
    
    // TODO: 검색 기능 추가 예정
    @objc func didTapSearch() {
        // MARK: 임시로 검색버튼에 기존 테스트뷰 넣어놨어요
//        let viewController = ViewController()
//        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // TODO: 리스트에서는 설정으로 이동 없어짐 (곡별 설정)
    @objc func didTapSettings() {
//        let settingViewController = SettingViewController()
//        navigationController?.pushViewController(settingViewController, animated: true)
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
        return scoreList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let scorePracticeViewController = ScorePracticeViewController(currentScore: scoreList[indexPath.row])
        navigationController?.pushViewController(scorePracticeViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCellView.identifier,
                                                       for: indexPath) as? ListItemCellView else {
            return UITableViewCell()
        }
        cell.configure(with: scoreList[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0  // 섹션 사이 간격
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
