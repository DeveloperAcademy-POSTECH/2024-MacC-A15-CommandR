//
//  PDFConvertRequestConfirmationView.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/11/24.
//


import UIKit

protocol PDFConvertRequestConfirmationViewDelegate: AnyObject {
    var filename: String? { get }
    var pageCount: Int? { get }
    func didTapConfirmationButton()
}

class PDFConvertRequestConfirmationView: UIView {
    weak var delegate: PDFConvertRequestConfirmationViewDelegate? {
        didSet {
            filenameLabel.text = delegate?.filename
            pageCount.text = "\(delegate?.pageCount ?? 0)페이지"
        }
    }
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var cardView: UIView!
    var confirmationButton: UIButton!
    
    // cardView 내부 라벨
    var scoreInfoLabel: UILabel!
    
    //fileName HStack
    var filenameHStack: UIStackView!
    var titleLabelInsideCard: UILabel!
    var filenameLabel: UILabel!
    
    // pageCount HStack
    var pageCountHStack: UIStackView!
    var pageCountLabel: UILabel!
    var pageCount: UILabel!
    
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
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.gray
        addSubview(subtitleLabel)
        
        // CardView 셋업
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
        scoreInfoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        cardView.addSubview(scoreInfoLabel)
        
        titleLabelInsideCard = UILabel()
        titleLabelInsideCard.translatesAutoresizingMaskIntoConstraints = false
        titleLabelInsideCard.text = "악보 제목"
        titleLabelInsideCard.textColor = .darkGray
        titleLabelInsideCard.font = UIFont.systemFont(ofSize: 16)
        
        filenameLabel = UILabel()
        filenameLabel.translatesAutoresizingMaskIntoConstraints = false
        filenameLabel.text = delegate?.filename
        filenameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        filenameLabel.textAlignment = .right
        
        // HStack [titleLabelInsideCardView, spacer, filenameLabel]
        filenameHStack = UIStackView(arrangedSubviews: [titleLabelInsideCard, UIView(), filenameLabel])
        filenameHStack.axis = .horizontal
        filenameHStack.spacing = 8
        filenameHStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(filenameHStack)
        
        pageCountLabel = UILabel()
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.text = "페이지 수"
        pageCountLabel.textColor = .darkGray
        pageCountLabel.font = UIFont.systemFont(ofSize: 16)
        
        pageCount = UILabel()
        pageCount.translatesAutoresizingMaskIntoConstraints = false
        pageCount.text = "\(0)"
        pageCount.font = UIFont.boldSystemFont(ofSize: 16)
        pageCount.textAlignment = .right
        
        pageCountHStack = UIStackView(arrangedSubviews: [pageCountLabel, UIView(), pageCount])
        pageCountHStack.axis = .horizontal
        pageCountHStack.spacing = 8
        pageCountHStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(pageCountHStack)
        
        
        // Confirmation button 셋업
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
            
            // 카드 뷰의 제약 조건
            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardView.heightAnchor.constraint(equalToConstant: 190),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Labels inside cardView
            scoreInfoLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            scoreInfoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            scoreInfoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            scoreInfoLabel.heightAnchor.constraint(equalToConstant: 27),
                    
            pageCountHStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),
            pageCountHStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            pageCountHStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            pageCountHStack.heightAnchor.constraint(equalToConstant: 24),
            
            // HStack 제약 조건
            filenameHStack.heightAnchor.constraint(equalToConstant: 24),
            filenameHStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            filenameHStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            filenameHStack.bottomAnchor.constraint(equalTo: pageCountHStack.topAnchor, constant: -20),
            

            // Confirmation button 제약조건
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
