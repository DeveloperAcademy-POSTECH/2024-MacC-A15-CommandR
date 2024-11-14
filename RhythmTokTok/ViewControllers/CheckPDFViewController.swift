//
//  CheckPDFViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee Hong on 10/13/24.
//

import UIKit

class CheckPDFViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentPickerDelegate {
    var fileURL: URL?
    var pdfPages: [UIImage] = []
    let checkPDFView = CheckPDFView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupActions()
        loadPDFDocument()
    }
    
    private func setupView() {
        // checkPDFView 추가 및 제약 설정
        view.addSubview(checkPDFView)
        checkPDFView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkPDFView.topAnchor.constraint(equalTo: view.topAnchor),
            checkPDFView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            checkPDFView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            checkPDFView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // CollectionView의 데이터 소스와 델리게이트를 설정
        checkPDFView.collectionView.dataSource = self
        checkPDFView.collectionView.delegate = self
        checkPDFView.collectionView.register(PDFPageCell.self, forCellWithReuseIdentifier: "PDFPageCell")
    }
    
    private func setupActions() {
        checkPDFView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        checkPDFView.changePDFButton.addTarget(self, action: #selector(changePDFButtonTapped), for: .touchUpInside)
    }
    
    private func loadPDFDocument() {
        guard let fileURL = fileURL else { return }
        
        // PDF 페이지를 모델을 통해 로드하고 CollectionView를 리로드
        pdfPages = PDFConvertManager.loadPDFPages(from: fileURL)
        checkPDFView.collectionView.reloadData()
    }

    @objc private func changePDFButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }

    @objc private func confirmButtonTapped() {
        let titleInputVC = TitleInputViewController()
        titleInputVC.fileURL = fileURL
        navigationController?.pushViewController(titleInputVC, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        fileURL = urls.first
        loadPDFDocument()  // 새로운 파일을 로드하고 리로드
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfPages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PDFPageCell",
                                                      for: indexPath) as! PDFPageCell
        cell.imageView.image = pdfPages[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
