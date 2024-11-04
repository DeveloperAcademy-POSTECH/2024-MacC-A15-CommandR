//
//  PracticeNavigationBar.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class PracticeNavigationBar: UIView {

    let leftButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let rightButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .lableSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let watchConnectImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "watchOff")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "settingButton"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        
        // 스택 뷰에 버튼들 추가
        leftButtonStackView.addArrangedSubview(backButton)
        rightButtonStackView.addArrangedSubview(watchConnectImageView)
        rightButtonStackView.addArrangedSubview(settingButton)
        
        addSubview(leftButtonStackView)
        addSubview(rightButtonStackView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // 왼쪽 버튼 스택
            leftButtonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            leftButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            leftButtonStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // 오른쪽 버튼 스택
            rightButtonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            rightButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            rightButtonStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // 버튼 크기 설정
            watchConnectImageView.widthAnchor.constraint(equalToConstant: 24),
            watchConnectImageView.heightAnchor.constraint(equalToConstant: 24),
            watchConnectImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            settingButton.widthAnchor.constraint(equalToConstant: 24),
            settingButton.heightAnchor.constraint(equalToConstant: 24),
            settingButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setWatchImage(isConnected: Bool) {
        DispatchQueue.main.async {
            if isConnected {
                self.watchConnectImageView.image = UIImage(named: "watchActive")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .green
            } else {
                self.watchConnectImageView.image = UIImage(named: "watchOff")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .red
            }
        }
    }
}
