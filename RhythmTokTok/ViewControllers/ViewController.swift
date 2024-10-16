//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//

import UIKit
import WatchConnectivity
import AVFoundation
import UniformTypeIdentifiers
import Lottie

class ViewController: UIViewController {
    
    let statusLabel = UILabel()
    var selectedFileURL: URL?
    var selectedSongTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
        
        _ = WatchManager.shared
        setupObservers()
        updateWatchAppStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .watchConnectivityStatusChanged, object: nil)
    }
    
    // 워치 앱 상태 업데이트 메서드
    @objc func updateWatchAppStatus() {
        DispatchQueue.main.async {
            let isWatchAppReachable = WatchManager.shared.isWatchAppReachable
            print("ViewController: updateWatchAppStatus - isWatchAppReachable = \(isWatchAppReachable)")
            
            if isWatchAppReachable {
                self.statusLabel.text = "워치 앱 켜짐"
                self.statusLabel.textColor = UIColor.systemGreen
            } else {
                self.statusLabel.text = "워치 앱 꺼짐"
                self.statusLabel.textColor = UIColor.systemRed
            }
        }
    }
    
    func setupUI() {
        let loadingButton = UIButton(type: .system)
        loadingButton.setTitle("로딩뷰", for: .normal)
        loadingButton.translatesAutoresizingMaskIntoConstraints = false
        loadingButton.addTarget(self, action: #selector(navigateToLoadingViewController), for: .touchUpInside)
        view.addSubview(loadingButton)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("추가하기", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(selectPDFButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        let watchTestButton = UIButton(type: .system)
        watchTestButton.setTitle("워치 테스트 화면", for: .normal)
        watchTestButton.translatesAutoresizingMaskIntoConstraints = false
        watchTestButton.addTarget(self, action: #selector(navigateToWatchTestViewController), for: .touchUpInside)
        view.addSubview(watchTestButton)
        
        let loadingViewButton = UIButton(type: .system)
        loadingViewButton.setTitle("로띠뷰가기", for: .normal)
        loadingViewButton.translatesAutoresizingMaskIntoConstraints = false
        loadingViewButton.addTarget(self, action: #selector(navigateToLottieViewController), for: .touchUpInside)
        view.addSubview(loadingViewButton)
        
        let practiceViewButton = UIButton(type: .system)
        practiceViewButton.setTitle("연습뷰가기", for: .normal)
        practiceViewButton.translatesAutoresizingMaskIntoConstraints = false
        practiceViewButton.addTarget(self, action: #selector(navigateToMusicPracticeViewController), for: .touchUpInside)
        view.addSubview(practiceViewButton)

        let listViewButton = UIButton(type: .system)
        listViewButton.setTitle("리스트뷰가기", for: .normal)
        listViewButton.translatesAutoresizingMaskIntoConstraints = false
        listViewButton.addTarget(self, action: #selector(navigateToListViewController), for: .touchUpInside)
        view.addSubview(listViewButton)

        NSLayoutConstraint.activate([
            loadingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: loadingButton.bottomAnchor, constant: 20),

            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),

            watchTestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            watchTestButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20),

            loadingViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingViewButton.topAnchor.constraint(equalTo: watchTestButton.bottomAnchor, constant: 20),

            practiceViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            practiceViewButton.topAnchor.constraint(equalTo: loadingViewButton.bottomAnchor, constant: 20),

            listViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listViewButton.topAnchor.constraint(equalTo: practiceViewButton.bottomAnchor, constant: 20)
        ])
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchAppStatus),
                                               name: .watchConnectivityStatusChanged, object: nil)

        print("ViewController: setupObservers - 알림 옵저버 추가됨")
    }
    
    @objc private func navigateToLoadingViewController() {
        let loadingViewController = LoadingViewController()
        present(loadingViewController, animated: true, completion: nil)
    }
  
    // PDF 파일 선택 버튼 액션
    @objc func selectPDFButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
  
    @objc private func navigateToSettingViewController() {
        let settingViewController = SettingViewController()
        present(settingViewController, animated: true)
    }

    // PDF 파일을 미리 보기하고 확인할 수 있는 뷰로 이동
    func navigateToCheckPDFViewController(with fileURL: URL) {
        let checkPDFViewController = CheckPDFViewController()
        checkPDFViewController.fileURL = fileURL
        self.present(checkPDFViewController, animated: true, completion: nil) // 모달로 띄우기
    }
  
    @objc private func navigateToLottieViewController() {
        let addGridViewController = LottieViewController()
        present(addGridViewController, animated: true)
    }
   
    @objc private func navigateToWatchTestViewController() {
        let watchTestVC = WatchTestViewController()
        watchTestVC.modalPresentationStyle = .fullScreen // 필요에 따라 스타일 설정
        present(watchTestVC, animated: true, completion: nil)
    }
    
    // 필요한 인수를 제공하여 메서드 호출 수정
    @objc func navigateToMusicPracticeViewController() {
        let musicPracticeViewController = MusicPracticeViewController()
        navigationController?.pushViewController(musicPracticeViewController, animated: true)
    }
    
    //화면 표시용 테스트 버튼
    @objc private func navigateToListViewController() {
        let scoreListViewController = ScoreListViewController()
        navigationController?.pushViewController(scoreListViewController, animated: true)
    }
    
    @objc private func sendMessageToWatch() {
        if selectedSongTitle == nil {
            selectedSongTitle = "꽃을 든 남자 - 이백호"  // 테스트용 곡 제목 설정
        }
        guard let songTitle = selectedSongTitle else {
            print("선택된 곡이 없습니다.")
            return
        }
        let isSelectedSong = true
        WatchManager.shared.sendSongSelectionToWatch(isSelectedSong: isSelectedSong, songTitle: songTitle)
    }
    
    // 곡을 선택하는 메서드 예시
    func selectSong(title: String) {
        self.selectedSongTitle = title
        // 곡이 선택되었으므로 워치로 메시지 전송
        sendMessageToWatch()
    }
}


// PDF 파일 선택에 사용되는 extension
extension ViewController: UIDocumentPickerDelegate {
    
    // 파일을 선택한 후 호출되는 메소드
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        // 선택된 파일 URL을 저장하고 확인 화면으로 이동
        self.selectedFileURL = selectedFileURL
        self.navigateToCheckPDFViewController(with: selectedFileURL)
    }
    
    // 취소 버튼을 누르면 호출되는 메소드
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("사용자가 파일 선택을 취소했습니다.")
    }
}
