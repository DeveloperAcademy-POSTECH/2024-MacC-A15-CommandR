//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/14/24.
//

import UIKit

class PDFUploadDoneViewController: UIViewController {
    private var uploadDoneView: PDFUploadDoneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPDFUplodDonewView()
    }
    
    private func setupPDFUplodDonewView() {
        uploadDoneView = PDFUploadDoneView()
        
        view.addSubview(uploadDoneView)
        uploadDoneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadDoneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadDoneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadDoneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadDoneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}



