//
//  WatchTestViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/15/24.
//
// WatchTestViewController.swift

//import UIKit
//
//class WatchTestViewController: UIViewController {
//    
//    var selectedScoreTitle: String?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        setupUI()
//    }
//    
//    func setupUI() {
//        // 닫기 버튼 추가
//        let closeButton = UIButton(type: .system)
//        closeButton.setTitle("닫기", for: .normal)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
//        view.addSubview(closeButton)
//        
//        // 버튼들 생성
//        let selectScoreButton = createButton(title: "곡 선택하기", action: #selector(sendScoreSelectionToWatch))
//        let playButton = createButton(title: "재생중", action: #selector(sendPlayStatusPlay))
//        let pauseButton = createButton(title: "일시정지", action: #selector(sendPlayStatusPause))
//        let stopButton = createButton(title: "정지", action: #selector(sendPlayStatusStop))
//        
//        // 버튼들을 스택 뷰에 추가
//        let stackView = UIStackView(arrangedSubviews: [selectScoreButton, playButton, pauseButton, stopButton])
//        stackView.axis = .vertical
//        stackView.spacing = 20
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stackView)
//        
//        // 제약 조건 설정
//        NSLayoutConstraint.activate([
//            // 닫기 버튼 위치 설정
//            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            
//            // 스택 뷰 위치 설정
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    func createButton(title: String, action: Selector) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: action, for: .touchUpInside)
//        return button
//    }
//    
//    // 모달 닫기 액션
//    @objc private func dismissViewController() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    @objc private func sendScoreSelectionToWatch() {
//        if selectedScoreTitle == nil {
//            // 테스트용 곡 제목 설정
//            selectedScoreTitle = "꽃을 든 남자 - 이백호"
//        }
//        guard let scoreTitle = selectedScoreTitle else {
//            print("선택된 곡이 없습니다.")
//            return
//        }
//        IOStoWatchConnectivityManager.shared.sendScoreSelection(scoreTitle: scoreTitle, hapticSequence: [0.0, 1.0, 3.0])
//    }
//    
//    @objc private func sendPlayStatusPlay() {
//        IOStoWatchConnectivityManager.shared.sendPlayStatus(status: .play, startTime: Date().timeIntervalSince1970)
//    }
//    
//    @objc private func sendPlayStatusPause() {
//        IOStoWatchConnectivityManager.shared.sendPlayStatus(status: .pause, startTime: nil)
//    }
//    
//    @objc private func sendPlayStatusStop() {
//        IOStoWatchConnectivityManager.shared.sendPlayStatus(status: .stop, startTime: nil)
//    }
//}
