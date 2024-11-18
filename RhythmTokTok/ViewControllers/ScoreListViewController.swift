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
        return view as! ScoreListView
    }
    var scoreList: [Score] = []
    let mediaManager = MediaManager()
    let scoreService = ScoreService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기 데이터 확인 후 필요시 삽입
         checkAndInsertDummyDataIfNeeded()
        // MARK: - ListView상단 바 제거, 나중에 검색 넣어야해서 주석처리함.
        //         네비게이션 바 설정
        setupNavigationBar()
        
        // 테이블 뷰 설정
        setupTableView()
        
        //         하단 버튼 액션 연결
        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // 초기 데이터 확인 및 삽입 함수
    private func checkAndInsertDummyDataIfNeeded() {
        if UserDefaults.standard.bool(forKey: "hasInsertedDummyData") == false {
            Task {
                await scoreService.insertDummyDataIfNeeded()
                // 데이터 삽입 후 score 리스트 로드
                loadScoreList()
            }
        } else {
            // 이미 데이터가 삽입되어 있는 경우 바로 리스트 로드
            loadScoreList()
        }
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
    
    @objc func reloadScoreList() {
        print("reload")
        loadScoreList() // 데이터 다시 불러오기
    }
    
    // MARK: 악보리스트 출력
    private func loadScoreList() {
        let scoreService = ScoreService()
        let storedScores = scoreService.fetchAllScores()
        
        print("loading score")
        for storedScore in storedScores {
            let score = convertScore(storedScore)
            scoreList.append(score)
        }
        
        DispatchQueue.main.async {
            self.scoreListView.tableView.reloadData() // 테이블뷰 업데이트
        }
    }
    
    // 저장된 CoreData Score를 Score Model로 변환하는 함수
    // TODO: - 리스트에서 변환된 전체 Score정보를 가지고 있을 필요가 없음. id랑 title 만 가지고 있도록 수정해야 함..
    private func convertScore(_ scoreEntity: ScoreEntity) -> Score {
        let modelScore = Score()
        modelScore.title = scoreEntity.title ?? ""
        modelScore.id = scoreEntity.id ?? ""
        modelScore.divisions = Int(scoreEntity.divisions ?? 1)
        
        var measuresDict: [Int: [Measure]] = [:]
        var partID = "P1" // 기본값 P1
        scoreEntity.notes?.forEach { note in // 역으로 note를 Part, Measure에 넣어주기
            // 1. Measure에 Note를 넣는다
            if let noteEntity = note as? NoteEntity {
                partID = noteEntity.part!
                
                // 필요에 따라 여기서 Note 객체를 만들고 처리
                var modelNote = Note(
                    pitch: noteEntity.pitch ?? "",
                    duration: Int(noteEntity.duration),
                    octave: Int(noteEntity.octave),
                    type: noteEntity.type ?? "",
                    voice: Int(noteEntity.voice),
                    staff: Int(noteEntity.staff),
                    startTime: Int(noteEntity.startTime),
                    isRest: noteEntity.isRest,
                    accidental: Accidental(rawValue: Int(noteEntity.accidental ?? 0)) ?? Accidental.natural,
                    tieType: noteEntity.tieType
                )
                
                // measureNumber에 해당하는 Measure 배열 가져오기
                if var measureArray = measuresDict[Int(noteEntity.lineNumber)] {
                    // 1. Measure가 있는지 확인해서 있으면 note 추가
                    var measureFound = false
                    for idx in 0..<measureArray.count {
                        if measureArray[idx].number == Int(noteEntity.measureNumber) {
                            measureArray[idx].notes.append(modelNote)
                            measureFound = true
                            break
                        }
                    }
                    
                    // 2. 해당 Measure가 없으면 새 Measure 생성 후 추가
                    if !measureFound {
                        var newMeasure = Measure(number: Int(noteEntity.measureNumber), notes: [], currentTimes: [:], startTime: modelNote.startTime)
                        newMeasure.notes.append(modelNote)
                        measureArray.append(newMeasure)
                    }
                    
                    // 수정된 existingLines를 다시 measuresDict에 저장
                    measuresDict[Int(noteEntity.lineNumber)] = measureArray
                } else {
                    // 1. 새로운 line을 생성하고, 새로운 Measure를 생성하여 note 추가
                    var newMeasure = Measure(number: Int(noteEntity.measureNumber), notes: [], currentTimes: [:], startTime: modelNote.startTime)
                    newMeasure.notes.append(modelNote)
                    
                    // 새로운 line에 Measure를 추가
                    measuresDict[Int(noteEntity.lineNumber)] = [newMeasure]
                }
            }
        }
        // 2. Part에 Measure 넣는다
        // Part 구조체 초기화
        let part = Part(id: partID, measures: measuresDict)
        // 3. Score에 Part 넣는다
        modelScore.parts = [part] // TODO: - 현재는 part가 하나.. part가 여러개일 경우 로직 수정 필요
        
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
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        self.present(documentPicker, animated: true, completion: nil)
        let checkPDFViewController = CheckPDFViewController()
        
        navigationController?.pushViewController(checkPDFViewController, animated: true)
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
//extension ScoreListViewController: UIDocumentPickerDelegate {
//    // 파일 선택에 호출
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let selectedFileURL = urls.first else {
//            return
//        }
//        // 선택된 파일 URL을 저장하고 확인 화면으로 이동
//        self.selectedFileURL = selectedFileURL
//        self.navigateToCheckPDFViewController(with: selectedFileURL)
//    }
//    
//    // 선택한 파일 확인 뷰로 이동
//    private func navigateToCheckPDFViewController(with fileURL: URL) {
//        let checkPDFViewController = CheckPDFViewController()
//        checkPDFViewController.fileURL = fileURL
//        
//        navigationController?.pushViewController(checkPDFViewController, animated: true)
//    }
//    
//    // 취소 버튼을 누르면 호출되는 메소드
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        print("사용자가 파일 선택을 취소했습니다.")
//    }
//}
