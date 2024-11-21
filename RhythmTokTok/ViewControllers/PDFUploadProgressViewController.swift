//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/21/24.
//

import UIKit

class PDFUploadProgressViewController: UIViewController {
    private var uploadProgressView: PDFUploadProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPDFUplodDonewView()
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
    
}
