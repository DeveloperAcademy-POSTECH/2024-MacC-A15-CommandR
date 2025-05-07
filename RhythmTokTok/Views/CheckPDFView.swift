//
//  CheckPDFView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/14/24.
//

import UIKit

class CheckPDFView: UIView {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let headerLabel = UILabel()
    let subHeaderLabel = UILabel()
    let confirmButton = UIButton()
    let containerView = UIView()
    let changePDFButton = UIButton()
    let addPDFButton = UIButton()
    let collectionContainerView = UIView()
    var collectionView: UICollectionView!
    
    private var collectionContainerViewHeightConstraint: NSLayoutConstraint?

    var isFileSelected: Bool = false {
        didSet {
            updateLayoutForFileSelection()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        updateLayoutForFileSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // scrollView 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Header Label 설정
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        headerLabel.text = "악보 PDF 파일을 선택해주세요"
        headerLabel.numberOfLines = 0
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.textColor = .lableSecondary
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)

        // Subheader Label 설정
        subHeaderLabel.textAlignment = .left
        subHeaderLabel.font = UIFont.customFont(forTextStyle: .body2Regular)
        subHeaderLabel.text = "디지털 PDF 악보만 지원되며, 사진이나 스캔본은 사용할 수 없어요."
        subHeaderLabel.numberOfLines = 0
        subHeaderLabel.adjustsFontForContentSizeCategory = true
        subHeaderLabel.textColor = .lableTertiary
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subHeaderLabel)

        // 악보 뒤의 회색 배경 Container View 설정
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .backgroundSecondary
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // 악보를 보여줄 Collection Container View 설정
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        collectionContainerView.layer.cornerRadius = 8
        collectionContainerView.layer.shadowColor = UIColor.black.cgColor
        collectionContainerView.layer.shadowOpacity = 0.25
        collectionContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionContainerView.layer.shadowRadius = 4
        containerView.addSubview(collectionContainerView) // Moved to containerView

        // Collection View 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.layer.cornerRadius = 8
        collectionView.layer.masksToBounds = true
        collectionContainerView.addSubview(collectionView)

        // Change PDF Button 설정
        changePDFButton.setTitle("다른 파일로 변경하기", for: .normal)
        changePDFButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        changePDFButton.titleLabel?.adjustsFontForContentSizeCategory = true
        changePDFButton.setTitleColor(.lableSecondary, for: .normal)
        changePDFButton.backgroundColor = .buttonTertiary
        changePDFButton.layer.borderColor = UIColor.borderPrimary.cgColor
        changePDFButton.layer.borderWidth = 1
        changePDFButton.layer.cornerRadius = 8
        changePDFButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(changePDFButton)

        // Add PDF Button 설정
        addPDFButton.setTitle("PDF 파일 선택", for: .normal)
        addPDFButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        addPDFButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addPDFButton.setTitleColor(.lableSecondary, for: .normal)
        addPDFButton.backgroundColor = .buttonTertiary
        addPDFButton.layer.borderColor = UIColor.borderPrimary.cgColor
        addPDFButton.layer.borderWidth = 1
        addPDFButton.layer.cornerRadius = 12
        addPDFButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(addPDFButton)

        // Confirm Button 설정
        confirmButton.setTitle("선택 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmButton)
    }

    private func setupConstraints() {
        let collectionHeightConstraint = collectionContainerView.heightAnchor.constraint(equalToConstant: 266)
           collectionContainerViewHeightConstraint = collectionHeightConstraint // Store the reference
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor), // Important for vertical scroll

            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            containerView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            collectionHeightConstraint, //activate constraint
            collectionContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            collectionContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 74),
            collectionContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -73),

            collectionView.topAnchor.constraint(equalTo: collectionContainerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: collectionContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: collectionContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: collectionContainerView.bottomAnchor),

//            addPDFButton.topAnchor.constraint(equalTo: collectionContainerView.bottomAnchor, constant: 40), // Stacked vertically
            addPDFButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addPDFButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            addPDFButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            addPDFButton.heightAnchor.constraint(equalToConstant: 56),

            changePDFButton.topAnchor.constraint(equalTo: collectionContainerView.bottomAnchor, constant: 8), // Stacked vertically
            changePDFButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            changePDFButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            changePDFButton.heightAnchor.constraint(equalToConstant: 48),
            changePDFButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20), // Pin bottom of container

            confirmButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 27), // Below the container
            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 64),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -27), // Pin bottom of contentView
        ])
    }

    private func updateLayoutForFileSelection() {
        if isFileSelected {
            headerLabel.text = "선택한 파일이 맞나요?"
            collectionContainerView.isHidden = false
            collectionContainerViewHeightConstraint?.constant = 380 // Set to the desired height
            confirmButton.isEnabled = true
            confirmButton.backgroundColor = .buttonPrimary
            changePDFButton.isHidden = false
            addPDFButton.isHidden = true
        } else {
            headerLabel.text = "악보 PDF 파일을 선택해주세요"
            collectionContainerView.isHidden = true
            collectionContainerViewHeightConstraint?.constant = 380     // 빈 공간의 높이를 조절
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = .buttonDisabled
            changePDFButton.isHidden = true
            addPDFButton.isHidden = false
        }
    }
}
