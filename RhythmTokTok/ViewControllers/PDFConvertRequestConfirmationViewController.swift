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
        uploadPDFtoServer()
    }
    
    private func uploadPDFtoServer() {
        // 파일 이름 설정: 사용자가 입력한 파일명을 사용
        guard let filename = filename, !filename.isEmpty else {
            print("Filename is missing")
            ToastAlert.show(message: "제목을 입력해주세요.", in: self.view, iconName: "error_icon")
            return
        }
        
        // 사용자가 추가한 PDF 파일 가져오기
        guard let pdfURL = fileURL else {
            print("PDF 파일 URL이 없습니다.")
            ToastAlert.show(message: "PDF 파일을 선택해주세요.", in: self.view, iconName: "error_icon")
            return
        }
        
        // 페이지 수 가져오기
        guard let page = pageCount else {
            print("PDF 페이지 수를 가져올 수 없습니다.")
            ToastAlert.show(message: "페이지 수를 확인할 수 없습니다.", in: self.view, iconName: "error_icon")
            return
        }
        
        // 서버로 업로드
        let title = filename // 사용자 입력 제목
        let deviceID = encrypt(ServerManager.shared.getDeviceUUID())
        
        ServerManager.shared.uploadPDF(deviceID: deviceID, title: title, pdfFileURL: pdfURL, page: page) { status, message in
            print("Upload status: \(status), message: \(message)")
            DispatchQueue.main.async {
                if status == 1 {
                    ToastAlert.show(message: "PDF 업로드 성공했어요.", in: self.view, iconName: "check.circle.color")
                } else {
                    ToastAlert.show(message: "PDF 업로드 실패: \(message)", in: self.view, iconName: "error_icon")
                }
            }
        }
    }
    
    private func encrypt(_ input: String) -> String {
        do {
            return try AES256Cryption.encrypt(string: input)
        } catch {
            print("Device UUID before encryption: \(input)")
            ErrorHandler.handleError(error: error)
            return ""
        }
    }
}
