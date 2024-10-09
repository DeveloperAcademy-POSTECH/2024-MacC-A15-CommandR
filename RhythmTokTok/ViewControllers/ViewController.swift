//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//

//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//

//
//  ViewController.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // "로딩뷰" 버튼 생성
        let button = UIButton(type: .system)
        button.setTitle("로딩뷰", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navigateToNewViewController), for: .touchUpInside)
        view.addSubview(button)
        
        // 워치 앱 상태를 표시할 UILabel 생성
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // 버튼 위치 설정
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 상태 라벨 위치 설정 (버튼 아래)
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20)
        ])
        
        // WatchConnectivity 세션 설정
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        // 초기 상태 업데이트
        updateWatchAppStatus()
    }
    
    @objc private func navigateToNewViewController() {
        let loadingViewController = LoadingViewController()
        present(loadingViewController, animated: true, completion: nil)
    }
    
    // 워치 앱 상태 업데이트 메서드
    func updateWatchAppStatus() {
        DispatchQueue.main.async {
            if WCSession.default.isReachable {
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
            print("WCSession 활성화 실패: \(error.localizedDescription)")
        }
    }
    
    // 워치 앱의 연결 상태가 변경될 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("워치 앱 연결 상태 변경됨: \(session.isReachable)")
        updateWatchAppStatus()
    }
    
    // 필수 메서드: 세션이 비활성화되었을 때 호출
    func sessionDidBecomeInactive(_ session: WCSession) {
        // 필요 시 구현
    }
    
    // 필수 메서드: 세션이 비활성화된 후 호출
    func sessionDidDeactivate(_ session: WCSession) {
        // 새로운 세션을 활성화하려면 이곳에서 호출합니다.
        WCSession.default.activate()
    }
}
