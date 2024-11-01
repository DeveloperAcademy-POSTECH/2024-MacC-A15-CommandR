//
//  ControlButtonView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//

import UIKit
class ControlButtonView: UIView {
    let playPauseButton = PlayPauseButton()
    let refreshButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.circlepath"),
                                             title: "처음부터", backGroundColor: .clear,
                                                foregoundColor: .lableQuaternary, strokeColor: .buttonInactive, pressedColor: .gray01)
    let previousButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.left"),
                                                 title: "이전마디", backGroundColor: .gray02,
                                                 foregoundColor: .lableSecondary, pressedColor: .gray03)
    let nextButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.right"),
                                             title: "다음마디", backGroundColor: .gray02,
                                             foregoundColor: .lableSecondary, pressedColor: .gray03)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    private func setupButtons() {
        
        let measureStack = UIStackView(arrangedSubviews: [previousButton, refreshButton, nextButton])
        measureStack.axis = .horizontal
        measureStack.distribution = .fillProportionally
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
            
            refreshButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
}
