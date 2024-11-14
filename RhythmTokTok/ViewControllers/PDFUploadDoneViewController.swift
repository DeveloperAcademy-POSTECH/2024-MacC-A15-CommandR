//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/14/24.
//

import UIKit

class PDFUploadDoneViewController: UIViewController, PDFUploadDoneViewDelegate {
    private var uploadDoneView: PDFUploadDoneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPDFUplodDonewView()
    }
    
    private func setupPDFUplodDonewView() {
        uploadDoneView = PDFUploadDoneView()
        uploadDoneView.delegate = self
        view.addSubview(uploadDoneView)
        uploadDoneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadDoneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadDoneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadDoneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadDoneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func didTapDismissButton() {
        print("dismiss")
        dismiss(animated: true) {
               // Access the main app window and set its root view controller to the home view
               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first {
                   let homeViewController = ScoreListViewController()
                   window.rootViewController = UINavigationController(rootViewController: homeViewController)
                   window.makeKeyAndVisible()
               }
           }
    }
    
    func didTapNavigateButton() {
        
    }
}
