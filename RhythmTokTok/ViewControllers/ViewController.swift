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
        
        let loadingViewButton = UIButton(type: .system)
        loadingViewButton.setTitle("로띠뷰가기", for: .normal)
        loadingViewButton.translatesAutoresizingMaskIntoConstraints = false
        loadingViewButton.addTarget(self, action: #selector(navigateToLottieViewController), for: .touchUpInside)
        view.addSubview(loadingViewButton)

        NSLayoutConstraint.activate([
            loadingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: loadingButton.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            loadingViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingViewButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20)
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
    func showPDFConfirmationView(with fileURL: URL) {
        let pdfViewController = PDFConfirmationViewController()
        pdfViewController.fileURL = fileURL
        self.present(pdfViewController, animated: true, completion: nil) // 모달로 띄우기
    }
  
    @objc private func navigateToLottieViewController() {
        let addGridViewController = LottieViewController()
        present(addGridViewController, animated: true)
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
        self.showPDFConfirmationView(with: selectedFileURL)
    }
    
    // 취소 버튼을 누르면 호출되는 메소드
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("사용자가 파일 선택을 취소했습니다.")
    }
}
