//
//  BPMSettingView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class BPMSettingSectionView: UIView {
    var onBPMButtonTapped: (() -> Void)?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "빠르기 설정"
        label.font = UIFont(name: "Pretendard-Bold", size: 21)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "· 원하는 BPM을 설정하면, 악보가 그 BPM에 맞춰 재생됩니다."
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    // BPM 버튼 관련 요소들
    var bpm: Int = 120 {
        didSet {
            bpmLabel.text = "\(bpm) bpm"
            updateBPMDescription()
        }
    }
    
    var bpmDescription: String = "| 조금 빠르게" {
        didSet { bpmDescriptionLabel.text = bpmDescription }
    }
    
    let bpmLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Pretendard-Medium", size: 21)
        label.textColor = .black
        return label
    }()
    
    let bpmDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "| 조금 빠르게"
        label.font = UIFont(name: "Pretendard-Regular", size: 18)
        label.textColor = .gray
        return label
    }()
    
    private func updateBPMDescription() {
        switch bpm {
        case 0..<60: bpmDescription = "| 매우 느리게"
        case 60..<80: bpmDescription = "| 느리게"
        case 80..<100: bpmDescription = "| 조금 느리게"
        case 100..<120: bpmDescription = "| 보통"
        case 120..<140: bpmDescription = "| 조금 빠르게"
        case 140..<160: bpmDescription = "| 빠르게"
        case 160...: bpmDescription = "| 매우 빠르게"
        default: bpmDescription = "| 기본 속도"
        }
    }
    
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
        
        // `buttonStackView`의 제약 조건 설정
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: button.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        
        return button
    }()
    
    // 초기화 메서드에서 뷰를 설정합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        bpmLabel.text = "\(bpm) bpm"
        bpmDescriptionLabel.text = bpmDescription
        
        // 버튼 액션 추가
        bpmButton.addTarget(self, action: #selector(bpmButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        bpmLabel.text = "\(bpm) bpm"
        bpmDescriptionLabel.text = bpmDescription
        
        // 버튼 액션 추가
        bpmButton.addTarget(self, action: #selector(bpmButtonTapped), for: .touchUpInside)
    }
    
    @objc private func bpmButtonTapped() {
        onBPMButtonTapped?()
    }
    
    // 뷰를 추가하는 메서드
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(bpmButton)
        addSubview(descriptionLabel)
    }
    
    // 제약 조건을 설정하는 메서드
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

protocol BPMSettingSectionDelegate: AnyObject {
    func bpmButtonTapped()
}
