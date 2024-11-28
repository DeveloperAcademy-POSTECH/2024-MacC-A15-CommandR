//
//  ControlButtonView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//

import UIKit
class ControlButtonView: UIView {
    let playPauseButton = PlayPauseButton()
    let resetButton = MeasureControllerButton(icon: UIImage(named: "restart"),
                                              title: "처음부터", backGroundColor: .buttonTertiary,
                                              foregoundColor: .lableSecondary,
                                              strokeColor: .borderTertiary, pressedColor: .buttonTertiaryPress)
    let previousButton = MeasureControllerButton(icon: UIImage(named: "previous"),
                                                 title: "이전마디", backGroundColor: .buttonSecondary,
                                                 foregoundColor: .lableSecondary, pressedColor: .buttonSecondaryPress)
    let nextButton = MeasureControllerButton(icon: UIImage(named: "next"),
                                             title: "다음마디", backGroundColor: .buttonSecondary,
                                             foregoundColor: .lableSecondary, pressedColor: .buttonSecondaryPress)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
            
            previousButton.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            previousButton.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -8),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            nextButton.leadingAnchor.constraint(equalTo: resetButton.trailingAnchor, constant: 8)
        ])
    }
}
