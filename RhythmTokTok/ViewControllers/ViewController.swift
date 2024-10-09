//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//
// ViewController.swift


import UIKit
import WatchConnectivity
import AVFoundation

class ViewController: UIViewController {
    
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let _ = WatchManager.shared
        updateWatchAppStatus()
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .watchConnectivityStatusChanged, object: nil)
    }
    
    @objc private func navigateToNewViewController() {
        let loadingViewController = LoadingViewController()
        present(loadingViewController, animated: true, completion: nil)
    }
    
    // 워치 앱 상태 업데이트 메서드
    @objc func updateWatchAppStatus() {
        DispatchQueue.main.async {
            let session = WCSession.default
            if session.isReachable {
                self.statusLabel.text = "워치 앱 켜짐"
                self.statusLabel.textColor = UIColor.systemGreen
            } else {
                self.statusLabel.text = "워치 앱 꺼짐"
                self.statusLabel.textColor = UIColor.systemRed
            }
        }
    }
}

extension ViewController {
    func setupUI() {
        let button = UIButton(type: .system)
        button.setTitle("로딩뷰", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navigateToNewViewController), for: .touchUpInside)
        view.addSubview(button)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20)
        ])
    }
    
    // NotificationCenter 관찰자 설정을 별도의 메서드로 분리
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchAppStatus), name: .watchConnectivityStatusChanged, object: nil)
    }
}
