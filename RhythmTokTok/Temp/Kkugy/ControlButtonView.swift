//
//  ControlButtonView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//

import UIKit

class ControlButtonView: UIView {
    let playPauseButton = PlayPauseButton()
    let stopButton = UIButton(type: .system)
    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)

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
        let measureStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        measureStack.axis = .horizontal
        measureStack.distribution = .fillEqually
        measureStack.spacing = 10
        measureStack.translatesAutoresizingMaskIntoConstraints = false
        
        let playStack = UIStackView(arrangedSubviews: [playPauseButton, stopButton])
        playStack.axis = .horizontal
        playStack.distribution = .fillEqually
        playStack.spacing = 10
        playStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [playStack, measureStack])
        mainStack.axis = .vertical
        mainStack.distribution = .fillEqually
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let playImage = UIImage(systemName: "play.fill")
        playPauseButton.setImage(playImage, for: .normal)
        stopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        previousButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
    }
}
