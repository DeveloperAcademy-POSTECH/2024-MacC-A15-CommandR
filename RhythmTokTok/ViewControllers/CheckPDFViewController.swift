//
//  CheckPDFViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee Hong on 10/13/24.
//

import UIKit
import PDFKit

class CheckPDFViewController: UIViewController, UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout, UIDocumentPickerDelegate {
    var fileURL: URL?
    var pdfPages: [UIImage] = []
    let collectionContainerView = UIView()
    var collectionView: UICollectionView!
    var headerLabel = UILabel()
    var subHeaderLabel = UILabel()
    var confirmButton = UIButton()
    var containerView = UIView()
    var changePDFButton = UIButton()

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
        headerLabel.text = "선택한 파일이 맞나요?"
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont(name: "Pretendard-Bold", size: 24)
        headerLabel.textColor = .lableSecondary
        headerLabel.textAlignment = .left
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        subHeaderLabel.text = "악보 파일이 제대로 되었는지 확인해 주세요."
        subHeaderLabel.textAlignment = .center
        subHeaderLabel.font = UIFont(name: "Pretendard-Regular", size: 16)
        subHeaderLabel.textColor = .lableTertiary
        subHeaderLabel.textAlignment = .left
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subHeaderLabel)
        
        // 라운드 사각형 컨테이너 뷰 설정
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .backgroundSecondary
        view.addSubview(containerView)
        
        // CollectionView 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        // 그림자를 적용할 컨테이너 뷰 설정
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        collectionContainerView.layer.cornerRadius = 8
        collectionContainerView.layer.shadowColor = UIColor.black.cgColor  // 그림자 색상
        collectionContainerView.layer.shadowOpacity = 0.25                 // 그림자 불투명도
        collectionContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)  // 그림자 위치
        collectionContainerView.layer.shadowRadius = 4                      // 그림자 반경
        collectionContainerView.layer.masksToBounds = false
        view.addSubview(collectionContainerView)

        // CollectionView 설정 및 containerView에 추가
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PDFPageCell.self, forCellWithReuseIdentifier: "PDFPageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.layer.cornerRadius = 8
        collectionView.layer.masksToBounds = true  // 컬렉션 뷰 안의 셀도 둥근 모서리에 맞게 잘리도록 설정
        collectionContainerView.addSubview(collectionView)
        
        // PDF 변경 버튼 설정
        changePDFButton.setTitle("다른 파일로 변경하기", for: .normal)
        changePDFButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        changePDFButton.setTitleColor(.lableSecondary, for: .normal)
        changePDFButton.backgroundColor = .buttonTertiary
        changePDFButton.layer.borderColor = UIColor.borderPrimary.cgColor
        changePDFButton.layer.borderWidth = 1
        changePDFButton.layer.cornerRadius = 8
        changePDFButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(changePDFButton)
        
        // 확인 버튼 설정
        confirmButton.setTitle("선택 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 12
        confirmButton.backgroundColor = .buttonPrimary
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
    }
    
    // 제약조건 설정
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 158),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerLabel.heightAnchor.constraint(equalToConstant: 34),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            subHeaderLabel.heightAnchor.constraint(equalToConstant: 24),

            containerView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -28),

            collectionContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48),
            collectionContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 74),
            collectionContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -73),
            collectionContainerView.heightAnchor.constraint(equalToConstant: 266),
            
            collectionView.topAnchor.constraint(equalTo: collectionContainerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: collectionContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionContainerView.bottomAnchor),
            
            changePDFButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            changePDFButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            changePDFButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            changePDFButton.heightAnchor.constraint(equalToConstant: 48),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -27),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    // 버튼 액션 설정
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        changePDFButton.addTarget(self, action: #selector(changePDFButtonTapped), for: .touchUpInside)
    }

    // PDF 파일을 이미지 배열로 로드
    private func loadPDFDocument() {
        guard let fileURL = fileURL, let pdfDocument = PDFDocument(url: fileURL) else { return }
        // PDF 페이지 로드 및 컬렉션 업데이트
        pdfPages = PDFConvertManager.loadPDFPages(from: fileURL)
        collectionView.reloadData()

    }
    
    // PDF 변경 버튼 액션
    @objc private func changePDFButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }

    // UIDocumentPickerViewControllerDelegate 메서드 구현
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }

        // 새로운 PDF 파일을 선택하고 로드
        fileURL = selectedFileURL
        loadPDFDocument()
    }

    // 확인 버튼 액션
    @objc private func confirmButtonTapped() {
        let titleInputViewController = TitleInputViewController()
        titleInputViewController.fileURL = fileURL
        navigationController?.pushViewController(titleInputViewController, animated: true)
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
