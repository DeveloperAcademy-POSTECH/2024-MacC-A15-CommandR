//
//  SoundKeySettingSectionView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 11/22/24.
//
import UIKit

class SoundKeySettingSectionView: UIView {
    var currentScore: Score?
    var currentSoundKey: Double?
    var onSoundKeyChanged: ((Double) -> Void)?
    var isAudioPreviewOn: Bool = false

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "조 설정"
        label.font = UIFont(name: "Pretendard-Bold", size: 21)
        return label
    }()
    
    let currentSoundKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 음"
        label.font = UIFont(name: "Pretendard-Medium", size: 24)
        label.textColor = .lableSecondary
        return label
    }()
    
    let currentSoundKeyValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont(name: "Pretendard-Medium", size: 24)
        label.textColor = .info
        return label
    }()
    
    let audioPreviewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("미리듣기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.setTitleColor(UIColor(named: "label_secondary") ?? UIColor.darkGray, for: .normal)
        button.backgroundColor = UIColor(named: "button_secondary")
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let flatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("내림", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.setTitleColor(.lableSecondary, for: .normal)
        button.backgroundColor = UIColor(named: "button_tertiary")
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.widthAnchor.constraint(equalToConstant: 163.5).isActive = true
        button.layer.borderColor = UIColor(named: "border_primary")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let sharpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("올림", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.setTitleColor(.lableSecondary, for: .normal)
        button.backgroundColor = UIColor(named: "button_tertiary")
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.widthAnchor.constraint(equalToConstant: 163.5).isActive = true
        button.layer.borderColor = UIColor(named: "border_primary")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let descriptionLabel1: UILabel = {
        let label = UILabel()
        label.text = "· 한 번에 0.5씩, 반음 단위로 높이거나 낮출 수 있어요."
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .lableTertiary
        label.numberOfLines = 0
        return label
    }()
    
    let descriptionLabel2: UILabel = {
        let label = UILabel()
        label.text = "· 조를 변경한 후, 미리듣기로 변경된 소리를 들을 수 있어요."
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .lableTertiary
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
//        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
//        setupGesture()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        let currentSoundKeyStackView = UIStackView(arrangedSubviews: [currentSoundKeyLabel, currentSoundKeyValueLabel])
        currentSoundKeyStackView.axis = .horizontal
        currentSoundKeyStackView.alignment = .center
        currentSoundKeyStackView.spacing = 4

        let soundKeyAudioPriviewStackView = UIStackView(arrangedSubviews: [currentSoundKeyStackView, audioPreviewButton])
        soundKeyAudioPriviewStackView.axis = .horizontal
        soundKeyAudioPriviewStackView.alignment = .center
        soundKeyAudioPriviewStackView.spacing = 16
        soundKeyAudioPriviewStackView.distribution = .equalSpacing
        
        let soundKeyButtonStackView = UIStackView(arrangedSubviews: [flatButton, sharpButton])
        soundKeyButtonStackView.axis = .horizontal
        soundKeyButtonStackView.alignment = .center
        soundKeyButtonStackView.spacing = 8
        soundKeyButtonStackView.distribution = .fillEqually
        
        let descriptionStackView = UIStackView(arrangedSubviews: [descriptionLabel1, descriptionLabel2])
        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .leading
        descriptionStackView.spacing = 4
        
        addSubview(titleLabel)
        addSubview(soundKeyAudioPriviewStackView)
        addSubview(soundKeyButtonStackView)
        addSubview(descriptionStackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        soundKeyAudioPriviewStackView.translatesAutoresizingMaskIntoConstraints = false
        soundKeyButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            audioPreviewButton.widthAnchor.constraint(equalToConstant: 110),
            audioPreviewButton.heightAnchor.constraint(equalToConstant: 40),
            
            soundKeyAudioPriviewStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            soundKeyAudioPriviewStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            soundKeyAudioPriviewStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            soundKeyAudioPriviewStackView.heightAnchor.constraint(equalToConstant: 48),

            soundKeyButtonStackView.topAnchor.constraint(equalTo: currentSoundKeyStackView.bottomAnchor, constant: 16),
            soundKeyButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            soundKeyButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            soundKeyButtonStackView.heightAnchor.constraint(equalToConstant: 48),
            
            descriptionStackView.topAnchor.constraint(equalTo: soundKeyButtonStackView.bottomAnchor, constant: 8),
            descriptionStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            descriptionStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
