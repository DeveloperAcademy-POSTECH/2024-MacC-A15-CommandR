//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//
// ViewController.swift

// ViewController.swift

import UIKit
import WatchConnectivity
import AVFoundation

class ViewController: UIViewController {
    
    let statusLabel = UILabel()
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // WatchManager 초기화 (싱글톤 인스턴스)
        let _ = WatchManager.shared
        updateWatchAppStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchAppStatus), name: .watchConnectivityStatusChanged, object: nil)
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
    
    // MARK: - WCSessionDelegate 메서드
    
    // 세션 활성화 완료 시 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("WCSession 활성화 완료")
        }
        if let error = error {
            print("Error [ViewController]: Failed to WCSession 활성화 실패 \(error.localizedDescription)")
        }
        
        NotificationCenter.default.post(name: .watchConnectivityStatusChanged, object: nil)
    }
    
    // 워치 앱의 연결 상태가 변경될 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("워치 앱 연결 상태 변경됨: \(session.isReachable)")
        NotificationCenter.default.post(name: .watchConnectivityStatusChanged, object: nil)
    }
}
