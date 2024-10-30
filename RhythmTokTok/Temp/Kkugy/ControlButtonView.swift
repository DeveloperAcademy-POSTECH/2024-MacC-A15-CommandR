//
//  ControlButtonView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//

import UIKit
class ControlButtonView: UIView {
    let playPauseButton = PlayPauseButton()
    let stopButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.circlepath"),
                                             title: "처음부터", backGroundColor: .clear,
                                             foregoundColor: .lableQuaternary, strokeColor: .buttonInactive)
    let previousButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.left"),
                                                 title: "이전마디", backGroundColor: .gray02,
                                                 foregoundColor: .lableSecondary)
    let nextButton = MeasureControllerButton(icon: UIImage(systemName: "arrow.right"),
                                             title: "다음마디", backGroundColor: .gray02,
                                             foregoundColor: .lableSecondary)

    var isPlaying: Bool = false {
        didSet {
            let image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
            playPauseButton.setImage(image, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    private func setupButtons() {
        let playImage = UIImage(systemName: "play.fill")
        playPauseButton.setImage(playImage, for: .normal)
        
//        previousButton.icon = UIImage(systemName: "arrow.left")
//        previousButton.title = "이전마디"
//        previousButton.titleFont = UIFont(name: "Pretendard-Medium", size: 18) ?? .systemFont(ofSize: 18)
//        previousButton.titleColor = .lableSecondary
//        previousButton.backgroundColorCustom = .gray02
//        previousButton.borderColor = .clear
//        previousButton.translatesAutoresizingMaskIntoConstraints = false

//        nextButton.icon = UIImage(systemName: "arrow.right")
//        nextButton.title = "다음"
//        nextButton.titleFont = UIFont(name: "Pretendard-Medium", size: 18) ?? .systemFont(ofSize: 18)
//        nextButton.titleColor = .lableSecondary
//        nextButton.backgroundColorCustom = .gray02
//        nextButton.borderColor = .clear
//        nextButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stopButton.icon = UIImage(systemName: "arrow.circlepath")
//        stopButton.title = "처음부터"
//        stopButton.titleFont = UIFont(name: "Pretendard-Medium", size: 18) ?? .systemFont(ofSize: 18)
//        stopButton.titleColor = .lableQuaternary
//        stopButton.backgroundColorCustom = .clear
//        stopButton.borderColor = .buttonInactive
//        stopButton.translatesAutoresizingMaskIntoConstraints = false

        let measureStack = UIStackView(arrangedSubviews: [previousButton, stopButton, nextButton])
        measureStack.axis = .horizontal
        measureStack.distribution = .fillEqually
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
            
            stopButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
}
