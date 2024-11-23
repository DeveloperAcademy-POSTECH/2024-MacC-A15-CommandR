//
//  ControlButtonView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//

import UIKit
class ControlButtonView: UIView {
    let playPauseButton = PlayPauseButton()
    let resetButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.circlepath"),
                                              title: "처음부터", backGroundColor: .buttonTertiary,
                                              foregoundColor: .lableSecondary,
                                              strokeColor: .borderActive, pressedColor: .buttonTertiaryPress)
    let previousButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.left"),
                                                 title: "이전마디", backGroundColor: .buttonSecondary,
                                                 foregoundColor: .lableSecondary, pressedColor: .buttonSecondaryPress)
    let nextButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.right"),
                                             title: "다음마디", backGroundColor: .buttonSecondary,
                                             foregoundColor: .lableSecondary, pressedColor: .buttonSecondaryPress)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        resetButton.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            
            // 상태에 따라 텍스트 색상 업데이트
            let customFont = UIFont.customFont(forTextStyle: .button1Medium)
            var updatedAttributedTitle = AttributedString("처음부터")
            updatedAttributedTitle.font = customFont
            updatedAttributedTitle.foregroundColor = button.isEnabled ?
                .lableSecondary : .placeholder
            
            updatedConfig?.attributedTitle = updatedAttributedTitle
            
            // 상태에 따라 테두리 색상 업데이트
            updatedConfig?.background.strokeColor = button.isEnabled ?
                .borderActive : .buttonInactive
            button.configuration = updatedConfig
        }
        
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        resetButton.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            
            // 상태에 따라 텍스트 색상 업데이트
            let customFont = UIFont.customFont(forTextStyle: .button1Medium)
            var updatedAttributedTitle = AttributedString("처음부터")
            updatedAttributedTitle.font = customFont
            updatedAttributedTitle.foregroundColor = button.isEnabled ?
                .lableSecondary : .placeholder
            
            updatedConfig?.attributedTitle = updatedAttributedTitle
            
            // 상태에 따라 테두리 색상 업데이트
            updatedConfig?.background.strokeColor = button.isEnabled ?
                .borderActive : .buttonInactive
            button.configuration = updatedConfig
        }
        
        setupButtons()
    }
    
    private func setupButtons() {
        
        let measureStack = UIStackView(arrangedSubviews: [previousButton, resetButton, nextButton])
        measureStack.axis = .horizontal
        measureStack.distribution = .equalCentering
        measureStack.spacing = 8
        measureStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainVStack = UIStackView(arrangedSubviews: [playPauseButton, measureStack])
        mainVStack.axis = .vertical
        mainVStack.distribution = .fillEqually
        mainVStack.spacing = 8
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainVStack)
        
        NSLayoutConstraint.activate([
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainVStack.topAnchor.constraint(equalTo: topAnchor),
            mainVStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            previousButton.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -8),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            nextButton.leadingAnchor.constraint(equalTo: resetButton.trailingAnchor, constant: 8)
        ])
    }
}
