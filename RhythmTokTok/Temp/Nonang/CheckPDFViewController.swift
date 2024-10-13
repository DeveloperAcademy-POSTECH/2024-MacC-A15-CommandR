//
//  CheckPDFViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee Hong on 10/13/24.
//
// PDF 파일을 보여주는 확인용 뷰 컨트롤러
import UIKit
import PDFKit

class PDFConfirmationViewController: UIViewController {
    
    var fileURL: URL?
    var pdfView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // PDFView 생성 및 설정
        pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        view.addSubview(pdfView)
        
        if let fileURL = fileURL {
            let pdfDocument = PDFDocument(url: fileURL)
            pdfView.document = pdfDocument
        }

        // 확인 버튼 추가
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("이 파일이 맞습니다", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
        
        // 제약조건 설정
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

    // 확인 버튼을 눌렀을 때 동작
    @objc func confirmButtonTapped() {
        print("사용자가 PDF 파일을 확인하고 선택을 완료했습니다.")
        // 모달로 띄운 경우 dismiss 사용
        self.dismiss(animated: true, completion: nil)
    }
}
