//
//  PDFConvertRequestConfirmationView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/11/24.
//
import UIKit
import PDFKit

class PDFConvertRequestConfirmationViewController: UIViewController, PDFConvertRequestConfirmationViewDelegate {
    var fileURL: URL?
    var filename: String?
    var pageCount: Int?
    
    private var confirmationView: PDFConvertRequestConfirmationView!

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupConfirmationView()
            loadPDFPageCount()
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
    
    private func loadPDFPageCount() {
           guard let fileURL = fileURL, let pdfDocument = PDFDocument(url: fileURL) else {
               print("Unable to load PDF document.")
               return
           }
           pageCount = pdfDocument.pageCount
           confirmationView.pageCount.text = "\(pageCount ?? 0) 페이지"
       }
    
    func didTapConfirmationButton() {
        print("입력 완료 button tapped!")
        //TODO API 요청 보내기
    }
}
