//
//  PDFConvertRequestConfirmationView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/11/24.
//

//
//  TitleInputView\.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 11/9/24.
//

import UIKit

protocol PDFConvertRequestConfirmationViewDelegate: AnyObject {
    var filename: String? { get }
    func didTapConfirmationButton()
}


class PDFConvertRequestConfirmationView: UIView {
    weak var delegate: PDFConvertRequestConfirmationViewDelegate? {
        didSet {
            filenameLabel.text = delegate?.filename
        }
    }
    var titleLabel: UILabel!
    var filenameLabel: UILabel!
    var subtitleLabel: UILabel!
    var cardView: UIView!
    var confirmationButton: UIButton!
    
    // Labels inside the cardView
    var scoreInfoLabel: UILabel!
    var titleLabelInsideCard: UILabel!
    var pageCountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        // Title label 셋업
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "이대로 악보를 만들어 드릴까요?"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        addSubview(titleLabel)
        
        // Subtitle label 셋업
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "입력한 정보가 맞는지 확인해 주세요"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.gray
        addSubview(subtitleLabel)
        
        //CardView 셋업
        cardView = UIView()
        cardView.backgroundColor = UIColor(named: "background_secondary")
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(named: "border_tertiary")?.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        
        // Labels inside the cardView
        scoreInfoLabel = UILabel()
        scoreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreInfoLabel.text = "악보 정보"
        scoreInfoLabel.font = UIFont.systemFont(ofSize: 16)
        cardView.addSubview(scoreInfoLabel)
        
        titleLabelInsideCard = UILabel()
        titleLabelInsideCard.translatesAutoresizingMaskIntoConstraints = false
        titleLabelInsideCard.text = "악보 제목"
        titleLabelInsideCard.font = UIFont.systemFont(ofSize: 16)
        cardView.addSubview(titleLabelInsideCard)
        
        // Setup filename label
        filenameLabel = UILabel()
        filenameLabel.translatesAutoresizingMaskIntoConstraints = false
        filenameLabel.text = delegate?.filename
        filenameLabel.font = UIFont.systemFont(ofSize: 14)
        filenameLabel.textColor = .darkGray
        filenameLabel.textAlignment = .right
        addSubview(filenameLabel)
        
        
        
        pageCountLabel = UILabel()
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.text = "페이지 수"
        pageCountLabel.font = UIFont.systemFont(ofSize: 16)
        cardView.addSubview(pageCountLabel)
        
        // confirmaationButton button 셋업
        confirmationButton = UIButton(type: .system)
        confirmationButton.translatesAutoresizingMaskIntoConstraints = false
        confirmationButton.setTitle("악보 요청 보내기", for: .normal)
        confirmationButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 18)
        confirmationButton.setTitleColor(.white, for: .normal)
        confirmationButton.backgroundColor = UIColor.systemBlue
        confirmationButton.layer.cornerRadius = 12
        confirmationButton.addTarget(self, action: #selector(confirmationButtonTapped), for: .touchUpInside)
        addSubview(confirmationButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 제목과 부제목의 제약 조건
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            //카드 뷰의 제약 조건
            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardView.heightAnchor.constraint(equalToConstant: 190),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Labels inside cardView
            scoreInfoLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            scoreInfoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            titleLabelInsideCard.topAnchor.constraint(equalTo: scoreInfoLabel.bottomAnchor, constant: 8),
            titleLabelInsideCard.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            
            // Filename label constraints
            filenameLabel.centerYAnchor.constraint(equalTo: titleLabelInsideCard.centerYAnchor),
            filenameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabelInsideCard.trailingAnchor, constant: 8),
            filenameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Spacer effect by keeping titleLabel and filenameLabel spaced within the view
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: filenameLabel.leadingAnchor, constant: -10),
            
            pageCountLabel.topAnchor.constraint(equalTo: titleLabelInsideCard.bottomAnchor, constant: 8),
            pageCountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            pageCountLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            
            // confirmaationButton butto 버튼제약 조건
            confirmationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            confirmationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            confirmationButton.heightAnchor.constraint(equalToConstant: 64),
            confirmationButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func confirmationButtonTapped() {
        delegate?.didTapConfirmationButton()
    }
}
