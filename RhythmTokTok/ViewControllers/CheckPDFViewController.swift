//
//  CheckPDFViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee Hong on 10/13/24.
//

import UIKit
import PDFKit

class CheckPDFViewController: UIViewController {
    
    var fileURL: URL?
    var pdfView: PDFView!
    var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupConstraints()
        setupActions()
        
        loadPDFDocument()
    }
    
    // UI 구성
    private func setupUI() {
        // PDFView 설정
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        view.addSubview(pdfView)
        
        // 확인 버튼 설정
        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("이 파일이 맞습니다", for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
    }
    
    // 제약조건 설정
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),

            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(equalToConstant: 200),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 버튼 액션 설정
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

    // PDF 파일 로드
    private func loadPDFDocument() {
        if let fileURL = fileURL {
            let pdfDocument = PDFDocument(url: fileURL)
            pdfView.document = pdfDocument
        }
    }

    // 확인 버튼 액션
    @objc private func confirmButtonTapped() {
        print("사용자가 PDF 파일을 확인하고 선택을 완료했습니다.")
        // 모달로 띄운 경우 dismiss 사용
        let titleInputViewController = TitleInputViewController()
        titleInputViewController.fileURL = fileURL
        navigationController?.pushViewController(titleInputViewController, animated: true)
        self.dismiss(animated: true, completion: nil)  
    }
}
