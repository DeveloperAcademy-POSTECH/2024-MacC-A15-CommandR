//
//  ScoreListViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/15/24.
//
import CoreData
import UIKit
import UniformTypeIdentifiers

class ScoreListViewController: UIViewController {
    var selectedFileURL: URL?
    var scoreListView: ScoreListView! {
        return view as? ScoreListView
    }
    var scoreList: [Score] = []
    let mediaManager = MediaManager()
    let scoreService = ScoreService()
    let scoreTitleChangeVC = ScoreTitleChangeViewController()

    var dimmedBackgroundView: UIView?
    
    override func loadView() {
        view = ScoreListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        scoreListView.navigationBar.onListButtonTapped = {  [weak self] in
            self?.didTapRequestButton()
        }
        scoreListView.navigationBar.onSearchButtonTapped = { [weak self] in
            self?.didTapSearch()
        }
        setupTableView()
        scoreListView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 초기 데이터 확인 후 필요시 삽입
        checkAndInsertDummyDataIfNeeded()
    }
    
    // 초기 데이터 확인 및 삽입 함수
    private func checkAndInsertDummyDataIfNeeded() {
        if UserDefaults.standard.bool(forKey: "hasInsertedDummyData") == false {
            print("UserDefaultshasInsertedDummyData is false")
            Task {
                await scoreService.insertDummyDataIfNeeded()
                // 데이터 삽입 후 score 리스트 로드
                loadScoreList()
            }
        } else {
            print("UserDefaultshasInsertedDummyData is true")
            // 이미 데이터가 삽입되어 있는 경우 바로 리스트 로드
            loadScoreList()
        }
    }
    
    // 테이블 뷰 설정
    func setupTableView() {
        scoreListView.tableView.backgroundColor = UIColor.backgroundTertiary
        scoreListView.tableView.delegate = self
        scoreListView.tableView.dataSource = self
        scoreListView.tableView.register(ListItemCellView.self, forCellReuseIdentifier: ListItemCellView.identifier)
        scoreListView.tableView.separatorStyle = .none
    }
    
    // MARK: - Data
    private func loadScoreList() {
        scoreList = [] // 리스트 한번 비워주기
        
        let storedScores = scoreService.fetchAllScores()
        print("loading score")
        
        var titlesFromCoreData: [String] = []
        
        for storedScore in storedScores {
            let score = convertScore(storedScore)
            scoreList.append(score)
            titlesFromCoreData.append(score.title) // CoreData에서 제목 수집
        }
        
        // UserDefaults에 저장된 takenTitle 배열 가져오기
        var takenTitles = UserDefaults.standard.stringArray(forKey: "takenTitle") ?? []
        
        // CoreData에서 불러온 제목을 중복 없이 추가
        for title in titlesFromCoreData {
            if !takenTitles.contains(title) {
                takenTitles.append(title)
            }
        }
        
        // 업데이트된 배열을 UserDefaults에 저장
        UserDefaults.standard.set(takenTitles, forKey: "takenTitle")
        
        print("UserDefaults: takenTitle: \(UserDefaults.standard.stringArray(forKey: "takenTitle"))")
        
        DispatchQueue.main.async {
            self.scoreListView.tableView.reloadData() // 테이블뷰 업데이트
        }
    }
}

// MARK: - [Ext] ScoreEntity 변환 관련
extension ScoreListViewController {
    
    private func convertScore(_ scoreEntity: ScoreEntity) -> Score {
        let modelScore = Score()
        modelScore.title = scoreEntity.title ?? ""
        modelScore.id = scoreEntity.id ?? ""
        modelScore.divisions = Int(scoreEntity.divisions)
        modelScore.bpm = Int(scoreEntity.bpm)
        modelScore.soundOption = SoundSetting(rawValue: scoreEntity.soundOption) ?? .melodyBeat
        modelScore.hapticOption = scoreEntity.isHapticOn
        
        var measuresDict: [Int: [Measure]] = [:]
        var partID = "P1" // 기본값 P1
        
        // 1. Measure에 Note를 넣는다
        convertNotesToMeasures(from: scoreEntity, into: &measuresDict, partID: &partID)
        
        // 2. Part에 Measure 넣는다
        let part = Part(id: partID, measures: measuresDict)
        
        // 3. Score에 Part 넣는다
        modelScore.parts = [part]
        
        return modelScore
    }
    
    private func convertNotesToMeasures(from scoreEntity: ScoreEntity,
                                        into measuresDict: inout [Int: [Measure]],
                                        partID: inout String) {
        scoreEntity.notes?.compactMap { $0 as? NoteEntity }.forEach { noteEntity in
            partID = noteEntity.part ?? partID
            let modelNote = Note(
                pitch: noteEntity.pitch ?? "",
                duration: Int(noteEntity.duration),
                octave: Int(noteEntity.octave),
                type: noteEntity.type ?? "",
                voice: Int(noteEntity.voice),
                staff: Int(noteEntity.staff),
                startTime: Int(noteEntity.startTime),
                isRest: noteEntity.isRest,
                accidental: Accidental(rawValue: Int(noteEntity.accidental)) ?? .natural,
                tieType: noteEntity.tieType
            )
            
            let lineNumber = Int(noteEntity.lineNumber)
            let measureNumber = Int(noteEntity.measureNumber)
            
            var measureArray = measuresDict[lineNumber] ?? []
            
            if let measureIndex = measureArray.firstIndex(where: { $0.number == measureNumber }) {
                measureArray[measureIndex].notes.append(modelNote)
            } else {
                let newMeasure = Measure(number: measureNumber, notes: [modelNote],
                                         currentTimes: [:], startTime: modelNote.startTime)
                measureArray.append(newMeasure)
            }
            
            measuresDict[lineNumber] = measureArray
        }
    }
}

// MARK: - [Ext] 테이블 기능 관련
extension ScoreListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedScore = scoreList[indexPath.row]
        let scorePracticeViewController = ScorePracticeViewController(currentScore: selectedScore)
        print("리스트뷰 선택 Score: \(selectedScore)")
        navigationController?.pushViewController(scorePracticeViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCellView.identifier,
                                                       for: indexPath) as? ListItemCellView else {
            
            return UITableViewCell()
        }
        cell.configure(with: scoreList[indexPath.row].title)

        // 액션 버튼 클릭 시 이벤트 설정
        cell.onActionButtonTapped = { [weak self] in
            self?.showActionSheet(for: indexPath.row)
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0  // 섹션 사이 간격
    }
}

// MARK: - [Ext] 악보 요청 화면 관련
extension ScoreListViewController {
    @objc private func didTapAddButton() {
        let checkPDFViewController = CheckPDFViewController()
        navigationController?.pushViewController(checkPDFViewController, animated: true)
    }
    @objc func didTapRequestButton() {
        let requestViewController = RequestProcessingViewController()
        navigationController?.pushViewController(requestViewController, animated: true)
    }
}

// MARK: - [Ext] 검색 기능 관련
extension ScoreListViewController {
    @objc func didTapSearch() {
        let searchViewController = ScoreSearchViewController()
        searchViewController.configure(with: scoreList) // 현재 악보 리스트 전달
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}

// MARK: - [Ext] 악보 삭제, 수정 기능 관련
extension ScoreListViewController: ScoreTitleChangeDelegate {
    private func presentTitleChangeModal() {
        if dimmedBackgroundView == nil {
            dimmedBackgroundView = UIView(frame: view.bounds)
            dimmedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmedBackgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(dimmedBackgroundView!)
        }
        scoreTitleChangeVC.delegate = self
        scoreTitleChangeVC.modalPresentationStyle = .pageSheet
        present(scoreTitleChangeVC, animated: true)
    }
    
    func removeOverlay() {
        dimmedBackgroundView?.removeFromSuperview()
    }
    
    private func showActionSheet(for index: Int) {
        let selectedScore = scoreList[index]
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "음악 제목 수정하기", style: .default, handler: { [weak self] _ in
            self?.editScore(at: index)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "음악 삭제하기", style: .destructive, handler: { [weak self] _ in
            self?.showDeleteAlert(for: index)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func editScore(at index: Int) {
        let scoreToEdit = scoreList[index]
        print("수정하기 선택: \(scoreToEdit.title)")

        scoreTitleChangeVC.currentTitle = scoreToEdit.title // Pass the current title to the modal
        scoreTitleChangeVC.onTitleChanged = { [weak self] changedTitle in
            print("Title changed to: \(changedTitle)")
            self?.scoreList[index].title = changedTitle // Update the score list with the new title
            self?.scoreService.updateScoreTitle(id: scoreToEdit.id, newTitle: changedTitle) // Update Core Data
            self?.scoreListView.tableView.reloadData() // Refresh the table view
        }

        presentTitleChangeModal()
    }
    
    private func deleteScore(at index: Int) {
        let scoreToDelete = scoreList[index]
        print("삭제하기 선택: \(scoreToDelete.title)")
        
        if let scoreEntityToDelete = scoreService.fetchScoreById(id: scoreToDelete.id) {
            scoreService.deleteScore(score: scoreEntityToDelete)
        }

        scoreList.remove(at: index)
        scoreListView.tableView.reloadData()
    }
    
    private func showDeleteAlert(for index: Int) {
        let alertVC = CustomAlertViewController(
            title: "악보를 정말 삭제하시겠어요?",
            message: "삭제하면 다시 복구할 수 없어요.",
            confirmButtonText: "삭제하기",
            cancelButtonText: "닫기",
            confirmButtonColor: UIColor(named: "button_danger") ?? .red,
            cancelButtonColor: UIColor(named: "button_cancel") ?? .gray,
            highlightedTexts: ["다시 복구할 수 없어요"]
        )
        
        alertVC.onConfirm = { [weak self] in
            self?.deleteScore(at: index)
        }
        
        alertVC.onCancel = {
            print("취소 버튼 클릭")
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
}
