//
//  SetBPMViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/16/24.
//

import UIKit

// 임시 BPM뷰
class SetBPMViewController: UIViewController {
    
    private let bpmLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 BPM: 100"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bpmSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 60
        slider.maximumValue = 180
        slider.value = 100
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let setButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BPM 설정", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentBPM: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(bpmLabel)
        view.addSubview(bpmSlider)
        view.addSubview(setButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // BPM 라벨 제약 조건
            bpmLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bpmLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // 슬라이더 제약 조건
            bpmSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bpmSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bpmSlider.topAnchor.constraint(equalTo: bpmLabel.bottomAnchor, constant: 20),
            
            // 설정 버튼 제약 조건
            setButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setButton.topAnchor.constraint(equalTo: bpmSlider.bottomAnchor, constant: 40),
            setButton.widthAnchor.constraint(equalToConstant: 150),
            setButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
