//
//  SoundKeySettingSectionView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 11/22/24.
//
import UIKit
import Lottie

class SoundKeySettingSectionView: UIView {
    
    var currentSoundKey: Double = 0 {
        didSet {
            updateDisplaySoundKey()
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "조 설정"
        label.font = UIFont.customFont(forTextStyle: .heading2Bold)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let currentSoundKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 음"
        label.font = UIFont.customFont(forTextStyle: .heading1Medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lableSecondary
        return label
    }()
    
    let currentSoundKeyValueImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let currentSoundKeyValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.customFont(forTextStyle: .heading1Medium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .info
        return label
    }()
    
    let audioPreviewButton = AudioPreviewButton()
    
    let flatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "flat"), for: .normal)
        button.tintColor = .lableSecondary
        button.setTitle("내림", for: .normal)
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(.lableSecondary, for: .normal)
        button.backgroundColor = UIColor(named: "button_tertiary")
        button.setBackgroundColor(.lightGray, for: .highlighted)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 163.5).isActive = true
        button.layer.borderColor = UIColor(named: "border_primary")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = true
        
        // 이미지와 텍스트 위치 조정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        
        // 이미지 크기 조정
        if let fontSize = button.titleLabel?.font.pointSize {
            let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .medium)
            button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        }
        
        button.sizeToFit()
        
        return button
    }()
    
    let sharpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "sharp"), for: .normal)
        button.tintColor = .lableSecondary
        button.setTitle("올림", for: .normal)
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(.lableSecondary, for: .normal)
        button.backgroundColor = UIColor(named: "button_tertiary")
        button.setBackgroundColor(.lightGray, for: .highlighted)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 163.5).isActive = true
        button.layer.borderColor = UIColor(named: "border_primary")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.isUserInteractionEnabled = true
        
        // 이미지와 텍스트 위치 조정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        
        // 이미지 크기 조정
        if let fontSize = button.titleLabel?.font.pointSize {
            let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .medium)
            button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        }
        
        button.sizeToFit()
        
        return button
    }()
    
    let descriptionLabel1: UILabel = {
        let label = UILabel()
        label.text = "· 한 번에 0.5씩, 반음 단위로 높이거나 낮출 수 있어요."
        label.font = UIFont.customFont(forTextStyle: .captionRegular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lableTertiary
        label.numberOfLines = 0
        return label
    }()
    
    let descriptionLabel2: UILabel = {
        let label = UILabel()
        label.text = "· 조를 변경한 후, 미리듣기로 변경된 소리를 들을 수 있어요."
        label.font = UIFont.customFont(forTextStyle: .captionRegular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lableTertiary
        label.numberOfLines = 0
        return label
    }()

// MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - Setup Views
    private func setupViews() {
        let currentSoundKeyStackView = UIStackView(arrangedSubviews: [currentSoundKeyValueImageView, currentSoundKeyValueLabel])
        currentSoundKeyStackView.axis = .horizontal
        currentSoundKeyStackView.alignment = .center
        currentSoundKeyStackView.spacing = 1
        
        let currentSoundKeyLabelStackView = UIStackView(arrangedSubviews: [currentSoundKeyLabel, currentSoundKeyStackView])
        currentSoundKeyLabelStackView.axis = .horizontal
        currentSoundKeyLabelStackView.alignment = .center
        currentSoundKeyLabelStackView.spacing = 8

        let soundKeyAudioPreviewStackView = UIStackView(arrangedSubviews: [currentSoundKeyLabelStackView, audioPreviewButton])
        soundKeyAudioPreviewStackView.axis = .horizontal
        soundKeyAudioPreviewStackView.alignment = .center
        soundKeyAudioPreviewStackView.spacing = 16
        soundKeyAudioPreviewStackView.distribution = .equalSpacing
        
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
        addSubview(soundKeyAudioPreviewStackView)
        addSubview(soundKeyButtonStackView)
        addSubview(descriptionStackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        soundKeyAudioPreviewStackView.translatesAutoresizingMaskIntoConstraints = false
        soundKeyButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            audioPreviewButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),
            audioPreviewButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            soundKeyAudioPreviewStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            soundKeyAudioPreviewStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            soundKeyAudioPreviewStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            soundKeyAudioPreviewStackView.heightAnchor.constraint(equalToConstant: 48),

            soundKeyButtonStackView.topAnchor.constraint(equalTo: currentSoundKeyStackView.bottomAnchor, constant: 16),
            soundKeyButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            soundKeyButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            soundKeyButtonStackView.heightAnchor.constraint(equalToConstant: 48),
            
            descriptionStackView.topAnchor.constraint(equalTo: soundKeyButtonStackView.bottomAnchor, constant: 8),
            descriptionStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - Setup Actions (조 변경)
extension SoundKeySettingSectionView {
    private func setupActions() {
        flatButton.addTarget(self, action: #selector(flatButtonTapped), for: .touchUpInside)
        sharpButton.addTarget(self, action: #selector(sharpButtonTapped), for: .touchUpInside)
    }
    
    @objc private func flatButtonTapped() {
        guard currentSoundKey > -6 else {
            return
        }
        currentSoundKey -= 0.5
        updateDisplaySoundKey()
    }
    
    @objc private func sharpButtonTapped() {
        guard currentSoundKey < 6 else {
            return
        }
        currentSoundKey += 0.5
        updateDisplaySoundKey()
    }
    
    private func updateDisplaySoundKey() {
        if currentSoundKey > 0 {
            currentSoundKeyValueLabel.text = String(format: "%.1f", currentSoundKey)
            currentSoundKeyValueImageView.image = UIImage(named: "plus")
            currentSoundKeyValueImageView.isHidden = false
        } else if currentSoundKey < 0 {
            currentSoundKeyValueLabel.text = String(format: "%.1f", abs(currentSoundKey))
            currentSoundKeyValueImageView.image = UIImage(named: "minus")
            currentSoundKeyValueImageView.isHidden = false
        } else {
            currentSoundKeyValueLabel.text = String(format: "%d", Int(currentSoundKey))
            currentSoundKeyValueImageView.isHidden = true
        }
        
        flatButton.isEnabled = currentSoundKey > -6
        sharpButton.isEnabled = currentSoundKey < 6
    }
}
