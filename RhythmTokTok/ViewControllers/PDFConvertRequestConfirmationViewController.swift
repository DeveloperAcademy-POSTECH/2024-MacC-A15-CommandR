//
//  PDFConvertRequestConfirmationView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/11/24.
//
import UIKit

class PDFConvertRequestConfirmationViewController: UIViewController, PDFConvertRequestConfirmationViewDelegate {
    private var confirmationView: PDFConvertRequestConfirmationView!

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupConfirmationView()
        }
    
    private func setupConfirmationView() {
            // Initialize and configure the confirmation view
            confirmationView = PDFConvertRequestConfirmationView()
            confirmationView.delegate = self
            confirmationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(confirmationView)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                confirmationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                confirmationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                confirmationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                confirmationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    
    func didTapConfirmationButton() {
        print("입력 완료 button tapped!")
        //TODO API 요청 보내기
    }
}
