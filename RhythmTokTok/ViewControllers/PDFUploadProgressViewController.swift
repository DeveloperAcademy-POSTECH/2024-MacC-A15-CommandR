//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/21/24.
//

import UIKit
import Combine

class PDFUploadProgressViewController: UIViewController {
    private var uploadProgressView: PDFUploadProgressView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPDFUplodDonewView()
        observeUploadStatus()
    }
    
    private func setupPDFUplodDonewView() {
        uploadProgressView = PDFUploadProgressView()
        view.addSubview(uploadProgressView)
        uploadProgressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadProgressView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func observeUploadStatus() {
        ServerManager.shared.$isUploading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUploading in
                if !isUploading {
                    self?.navigateToPDFUploadDoneView()
                }
            }
            .store(in: &cancellables)
    }
    
    private func navigateToPDFUploadDoneView() {
        let pdfUploadDoneViewController = PDFUploadDoneViewController() // Replace with your actual view controller class
        navigationController?.pushViewController(pdfUploadDoneViewController, animated: true)
    }
    
}
