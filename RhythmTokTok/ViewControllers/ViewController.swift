//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//

import UIKit
import WatchConnectivity
import AVFoundation

class ViewController: UIViewController {
    
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUI()
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
        addButton.addTarget(self, action: #selector(navigateToAddGridViewController), for: .touchUpInside)
        view.addSubview(addButton)
        
        // 새로운 "메세지 보내기" 버튼 추가
        let sendMessageButton = UIButton(type: .system)
        sendMessageButton.setTitle("메세지 보내기", for: .normal)
        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        sendMessageButton.addTarget(self, action: #selector(sendMessageToWatch), for: .touchUpInside)
        view.addSubview(sendMessageButton)
        
        NSLayoutConstraint.activate([
            loadingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: loadingButton.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            sendMessageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendMessageButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20)
        ])
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchAppStatus), name: .watchConnectivityStatusChanged, object: nil)
        print("ViewController: setupObservers - 알림 옵저버 추가됨")
    }
    
    @objc private func navigateToLoadingViewController() {
        let loadingViewController = LoadingViewController()
        present(loadingViewController, animated: true, completion: nil)
    }
    
    @objc private func navigateToAddGridViewController() {
        let addGridViewController = SettingViewController()
        present(addGridViewController, animated: true)
    }
    
    @objc private func sendMessageToWatch() {
        WatchManager.shared.sendSampleMessageToWatch()
    }
}
