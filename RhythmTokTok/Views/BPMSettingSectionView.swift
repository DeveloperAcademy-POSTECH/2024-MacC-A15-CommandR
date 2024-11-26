//
//  BPMSettingView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class BPMSettingSectionView: UIView {
    var currentScore: Score?
    var onBPMButtonTapped: (() -> Void)?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "빠르기 설정"
        label.font = UIFont.customFont(forTextStyle: .heading2Bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "· 원하는 빠르기를 설정하면, 그 빠르기에 맞는 멜로디와 메트로놈이 함께 재생돼요."
        label.font = UIFont.customFont(forTextStyle: .captionRegular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lableTertiary
        label.numberOfLines = 0
        return label
    }()
    
    // BPM 버튼 관련 요소들
    lazy var bpm: Int = currentScore?.bpm ?? 60 {
        didSet {
            bpmLabel.text = "\(bpm) BPM"
            bpmDescriptionLabel.text = "| \(BPMDescription.description(for: bpm))"
        }
    }
    
    lazy var bpmDescription: String = "| \(BPMDescription.description(for: bpm))"
    
    let bpmLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.customFont(forTextStyle: .heading1Medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        return label
    }()
    
    let bpmDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .gray
        return label
    }()
    
    let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var buttonStackView: UIStackView = {
        let uiStackView = UIStackView()
        uiStackView.axis = .horizontal
        uiStackView.distribution = .fill
        uiStackView.spacing = 8
        uiStackView.isUserInteractionEnabled = false // 터치 이벤트 비활성화
        
        uiStackView.addArrangedSubview(bpmLabel)
        uiStackView.addArrangedSubview(bpmDescriptionLabel)
        uiStackView.addArrangedSubview(UIView())
        uiStackView.addArrangedSubview(chevronImageView)
        
        return uiStackView
    }()
    
    lazy var bpmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: button.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        bpmLabel.text = "\(bpm) BPM"
        bpmDescriptionLabel.text = bpmDescription
        
        // 버튼 액션 추가
        bpmButton.addTarget(self, action: #selector(bpmButtonTapped), for: .touchUpInside)
        setupLabelTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        bpmLabel.text = "\(bpm) BPM"
        bpmDescriptionLabel.text = bpmDescription
        bpmButton.addTarget(self, action: #selector(bpmButtonTapped), for: .touchUpInside)
        setupLabelTapGesture()
    }
    
    @objc private func bpmButtonTapped() {
        onBPMButtonTapped?()
    }
    
    private func setupLabelTapGesture() {
        titleLabel.isUserInteractionEnabled = true // 기본적으로 false이므로 활성화
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bpmButtonTapped))
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(bpmButton)
        addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bpmButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // titleLabel 제약 조건
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            // bpmButton 제약 조건
            bpmButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bpmButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            bpmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            bpmButton.heightAnchor.constraint(equalToConstant: 44), // 버튼 높이 설정
            
            // descriptionLabel 제약 조건
            descriptionLabel.topAnchor.constraint(equalTo: bpmButton.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}
