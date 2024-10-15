//
//  WatchTestViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/15/24.
//
// WatchTestViewController.swift

import UIKit

class WatchTestViewController: UIViewController {
    
    var selectedSongTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        // 닫기 버튼 추가 (모달을 닫기 위해)
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("닫기", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // "곡 선택하기" 버튼 생성
        let selectSongButton = UIButton(type: .system)
        selectSongButton.setTitle("곡 선택하기", for: .normal)
        selectSongButton.translatesAutoresizingMaskIntoConstraints = false
        selectSongButton.addTarget(self, action: #selector(sendSongSelectionToWatch), for: .touchUpInside)
        view.addSubview(selectSongButton)
        
        // "재생중" 버튼 생성
        let playButton = UIButton(type: .system)
        playButton.setTitle("재생중", for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(sendPlayStatusPlay), for: .touchUpInside)
        view.addSubview(playButton)
        
        // "일시정지" 버튼 생성
        let pauseButton = UIButton(type: .system)
        pauseButton.setTitle("일시정지", for: .normal)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.addTarget(self, action: #selector(sendPlayStatusPause), for: .touchUpInside)
        view.addSubview(pauseButton)
        
        // "정지" 버튼 생성
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("정지", for: .normal)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(sendPlayStatusStop), for: .touchUpInside)
        view.addSubview(stopButton)
        
        // 스택 뷰로 버튼들을 정렬
        let stackView = UIStackView(arrangedSubviews: [selectSongButton, playButton, pauseButton, stopButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // 닫기 버튼 위치 설정 (상단 좌측)
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            // 스택 뷰 위치 설정 (화면 중앙)
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // 모달 닫기 액션
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // "곡 선택하기" 버튼 액션
    @objc private func sendSongSelectionToWatch() {
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
    
    // "재생중" 버튼 액션
    @objc private func sendPlayStatusPlay() {
        WatchManager.shared.sendPlayStatusToWatch(status: "play")
    }
    
    // "일시정지" 버튼 액션
    @objc private func sendPlayStatusPause() {
        WatchManager.shared.sendPlayStatusToWatch(status: "pause")
    }
    
    // "정지" 버튼 액션
    @objc private func sendPlayStatusStop() {
        WatchManager.shared.sendPlayStatusToWatch(status: "stop")
    }
}
