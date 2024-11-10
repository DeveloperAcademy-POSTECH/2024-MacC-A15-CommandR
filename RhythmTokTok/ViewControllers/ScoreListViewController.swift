//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import UIKit
import UniformTypeIdentifiers
import CoreData

class ScoreListViewController: UIViewController {
    
    var selectedFileURL: URL?
    var scoreListView: ScoreListView! {
        return view as? ScoreListView
    }
    var scoreList: [Score] = []
    let mediaManager = MediaManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScoreList()
        print("viewDidLoad")
        
        // MARK: - ListView상단 바 제거, 나중에 검색 넣어야해서 주석처리함.
//         네비게이션 바 설정
        setupNavigationBar()
        
        // 테이블 뷰 설정
        setupTableView()
        
//         하단 버튼 액션 연결
        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
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
        
        let requestButtonImage = UIImage(named: "list")
        let requestButton = UIBarButtonItem(image: requestButtonImage, style: .plain, target: self, action: #selector(didTapRequestButton))
        
        navigationItem.rightBarButtonItem = requestButton
//        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
//        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(didTapSettings))
        
        //        navigationItem.rightBarButtonItems = [settingsButton]
    }
    @objc func didTapRequestButton() {
        let requestViewController = RequestProcessingViewController()
        navigationController?.pushViewController(requestViewController, animated: true)
    }
    // 테이블 뷰 설정
    func setupTableView() {
        scoreListView.tableView.backgroundColor = UIColor.backgroundTertiary
        scoreListView.tableView.delegate = self
        scoreListView.tableView.dataSource = self
        scoreListView.tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
        scoreListView.tableView.separatorStyle = .none
    }
    
    // MARK: 악보리스트 출력
    private func loadScoreList() {
        let scoreService = ScoreService()
        let storedScores = scoreService.fetchAllScores()
        
        print("loading score")
        for storedScore in storedScores {
            var score = convertScore(storedScore)
            scoreList.append(score)
        }
        scoreListView.tableView.reloadData() // 테이블뷰 업데이트
    }
    
    // 저장된 CoreData Score를 Score Model로 변환하는 함수
    // TODO: - 리스트에서 변환된 전체 Score정보를 가지고 있을 필요가 없음. id랑 title 만 가지고 있도록 수정해야 함..
    private func convertScore(_ scoreEntity: ScoreEntity) -> Score {
        let modelScore = Score()
        modelScore.title = scoreEntity.title ?? ""
        modelScore.id = scoreEntity.id ?? ""
        
        var measuresDict: [Int: [Measure]] = [:]
        var partID = "P1" // 기본값 P1
        scoreEntity.notes?.forEach { note in // 역으로 note를 Part, Measure에 넣어주기
            partID = (note as AnyObject).part!
            // 1. Measure에 Note를 넣는다
            if let pitch = (note as AnyObject).pitch as? String,
               let localDuration = (note as AnyObject).dura,
               let octave = (note as AnyObject).octave,
               let voice = (note as AnyObject).voice,
               let staff = (note as AnyObject).staff,
               let startTime = (note as AnyObject).startTime,
               let measureNumber = (note as AnyObject).measure as? Int {
                
                var modelNote = Note(
                    pitch: pitch,
                    duration: Int(localDuration),
                    octave: Int(octave),
                    type: (note as AnyObject).type ?? "",
                    voice: Int(voice),
                    staff: Int(staff),
                    startTime: Int(startTime)
                )
                
                // measureNumber에 해당하는 Measure 배열 가져오기
                if var existingMeasures = measuresDict[measureNumber] {
                    // 이미 존재하는 Measure에 Note 추가
                    if var lastMeasure = existingMeasures.last {
                        lastMeasure.addNote(modelNote)
                    } else {
                        // Measure가 존재하지 않으면 새로 생성하고 추가
                        var newMeasure = Measure(number: measureNumber, notes: [], currentTimes: [:])
                        newMeasure.addNote(modelNote)
                        existingMeasures.append(newMeasure)
                    }
                    measuresDict[measureNumber] = existingMeasures
                } else {
                    // 새로운 Measure 생성 후 Note 추가
                    var newMeasure = Measure(number: measureNumber, notes: [], currentTimes: [:])
                    newMeasure.addNote(modelNote)
                    measuresDict[measureNumber] = [newMeasure]
                }
            }
        }
        // 2. Part에 Measure 넣는다
        let part = Part(id: partID, measures: measuresDict)
        // 3. Score에 Part 넣는다 TODO: - 현재는 하나라서.. part가 여러개일 경우 로직 수정 필요
        modelScore.parts = [part] // partID
        
        return modelScore
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
        // TODO: - 실제 테이블 정보
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
