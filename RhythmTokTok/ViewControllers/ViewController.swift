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
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    let statusLabel = UILabel()
    var selectedFileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
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
        // 기존 버튼
        let loadingButton = UIButton(type: .system)
        loadingButton.setTitle("로딩뷰", for: .normal)
        loadingButton.translatesAutoresizingMaskIntoConstraints = false
        loadingButton.addTarget(self, action: #selector(navigateToLoadingViewController), for: .touchUpInside)
        view.addSubview(loadingButton)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
        
        // 새로운 "추가하기" 버튼
        let addButton = UIButton(type: .system)
        addButton.setTitle("추가하기", for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(selectPDFButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            loadingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: loadingButton.bottomAnchor, constant: 20),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20)
        ])
    }
    
    // NotificationCenter 관찰자 설정을 별도의 메서드로 분리
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchAppStatus), name: .watchConnectivityStatusChanged, object: nil)
    }
    
    // 기존 로딩 뷰로 이동하는 함수
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

    // PDF 파일을 미리 보기하고 확인할 수 있는 뷰로 이동
    func showPDFConfirmationView(with fileURL: URL) {
        let pdfViewController = PDFConfirmationViewController()
        pdfViewController.fileURL = fileURL
        self.present(pdfViewController, animated: true, completion: nil) // 모달로 띄우기
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
