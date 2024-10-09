//
//  SettingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
import UIKit

class SettingViewController: UIViewController {
    
    // MARK: - Properties
    let settingView = SettingView()
    
    // 현재 선택된 소리 설정 버튼
    var selectedSoundButton: UIButton?
    
    // 현재 선택된 진동 가이드 버튼
    var selectedVibrationButton: UIButton?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        setupActions()
        loadSettings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .fontSizeChanged, object: nil)
    }
    
    // MARK: - Setup Methods
    
    private func setupActions() {
        // 소리 설정 버튼들에 액션 추가
        settingView.soundNoteButton.addTarget(self, action: #selector(soundButtonTapped(_:)), for: .touchUpInside)
        settingView.soundMelodyButton.addTarget(self, action: #selector(soundButtonTapped(_:)), for: .touchUpInside)
        settingView.soundBeatButton.addTarget(self, action: #selector(soundButtonTapped(_:)), for: .touchUpInside)
        
        // 진동 가이드 설정 버튼들에 액션 추가
        settingView.vibrationOnButton.addTarget(self, action: #selector(vibrationButtonTapped(_:)), for: .touchUpInside)
        settingView.vibrationOffButton.addTarget(self, action: #selector(vibrationButtonTapped(_:)), for: .touchUpInside)
        
        // 글자 크기 설정 슬라이더에 액션 추가
        settingView.fontSizeSlider.addTarget(self, action: #selector(fontSizeSliderChanged(_:)), for: .valueChanged)
        settingView.fontSizeSlider.addTarget(self, action: #selector(fontSizeSliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    private func loadSettings() {
        // 소리 설정 로드 및 버튼 선택 상태 반영
        let soundSetting = Settings.shared.soundSetting
        switch soundSetting {
        case .note:
            selectButton(settingView.soundNoteButton)
        case .melody:
            selectButton(settingView.soundMelodyButton)
        case .beat:
            selectButton(settingView.soundBeatButton)
        }
        
        // 진동 가이드 설정 로드 및 버튼 선택 상태 반영
        let vibrationGuide = Settings.shared.watchVibrationGuide
        if vibrationGuide {
            selectButton(settingView.vibrationOnButton)
        } else {
            selectButton(settingView.vibrationOffButton)
        }
        
        // 글자 크기 설정 로드 및 슬라이더 위치 반영
        let fontSize = Settings.shared.fontSize
        settingView.fontSizeSlider.setValue(Float(fontSize), animated: false)
    }
    
    // MARK: - Action Methods
    
    @objc private func soundButtonTapped(_ sender: UIButton) {
        // 이전에 선택된 소리 설정 버튼의 스타일 초기화
        if let previousButton = selectedSoundButton {
            deselectButton(previousButton)
        }
        
        // 현재 선택된 버튼 스타일 변경
        selectButton(sender)
        
        // 설정 저장
        switch sender {
        case settingView.soundNoteButton:
            Settings.shared.soundSetting = .note
        case settingView.soundMelodyButton:
            Settings.shared.soundSetting = .melody
        case settingView.soundBeatButton:
            Settings.shared.soundSetting = .beat
        default:
            break
        }
        print("소리 설정 변경: \(Settings.shared.soundSetting.rawValue)")
        updateSoundSettings()
    }
    
    @objc private func vibrationButtonTapped(_ sender: UIButton) {
        // 이전에 선택된 진동 가이드 버튼의 스타일 초기화
        if let previousButton = selectedVibrationButton {
            deselectButton(previousButton)
        }
        
        // 현재 선택된 버튼 스타일 변경
        selectButton(sender)
        
        // 설정 저장
        switch sender {
        case settingView.vibrationOnButton:
            Settings.shared.watchVibrationGuide = true
        case settingView.vibrationOffButton:
            Settings.shared.watchVibrationGuide = false
        default:
            break
        }
        print("Watch 진동 가이드 설정: \(Settings.shared.watchVibrationGuide ? "켜기" : "끄기")")
        updateVibrationGuide()
    }
    
    @objc private func fontSizeSliderChanged(_ sender: UISlider) {
        // 슬라이더가 움직이는 동안 값을 변경하더라도 스냅은 하지 않음.
        let value = sender.value
        print("슬라이더 움직이는 중 값: \(value)")
    }
    
    @objc private func fontSizeSliderTouchEnded(_ sender: UISlider) {
        // 터치가 끝났을 때 가장 가까운 1, 2, 3, 4로 스냅
        let step: Float = 1.0
        let roundedValue = round(sender.value / step) * step
        sender.setValue(roundedValue, animated: true)
        
        // 설정 저장
        let selectedFontSize = Int(roundedValue)
        Settings.shared.fontSize = selectedFontSize
        print("글자 크기 설정: \(Settings.shared.fontSize)")
    }
    
    // MARK: - Helper Methods
    
    private func selectButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        
        // 해당 그룹에 따라 선택된 버튼 저장
        if button == settingView.soundNoteButton || button == settingView.soundMelodyButton || button == settingView.soundBeatButton {
            selectedSoundButton = button
        } else if button == settingView.vibrationOnButton || button == settingView.vibrationOffButton {
            selectedVibrationButton = button
        }
    }
    
    private func deselectButton(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    // MARK: - Update Methods
    
    private func updateSoundSettings() {
        switch Settings.shared.soundSetting {
        case .note:
            print("소리 설정: 계이름으로 듣기")
        case .melody:
            print("소리 설정: 멜로디로 듣기")
        case .beat:
            print("소리 설정: 박자만 듣기")
        }
    }
    
    private func updateVibrationGuide() {
        if Settings.shared.watchVibrationGuide {
            print("Watch 진동 가이드 활성화")
        } else {
            print("Watch 진동 가이드 비활성화")
        }
    }
}
