//
//  SettingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
import UIKit

class SettingViewController: UIViewController {
    
    let settingView = SettingView()
    
    // 현재 선택된 소리 설정 버튼
    var selectedSoundButton: UIButton?
    
    // 현재 선택된 진동 가이드 버튼
    var selectedVibrationButton: UIButton?
    
    // 소리 설정 버튼들
    var soundButtons: [UIButton] {
        return [settingView.soundNoteButton, settingView.soundMelodyButton, settingView.soundBeatButton]
    }
    
    // 진동 가이드 설정 버튼들
    var vibrationButtons: [UIButton] {
        return [settingView.vibrationOnButton, settingView.vibrationOffButton]
    }
    
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        setupActions()
        loadSettings()
    }
    
    private func setupActions() {
        // 소리와 진동 버튼에 대한 액션 설정을 배열로 처리
        for button in soundButtons + vibrationButtons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        for button in settingView.fontSizeButtons {
            button.addTarget(self, action: #selector(fontSizeButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func loadSettings() {
        let soundSetting = Settings.shared.soundSetting
        switch soundSetting {
        case .note:
            selectButton(settingView.soundNoteButton)
        case .melody:
            selectButton(settingView.soundMelodyButton)
        case .beat:
            selectButton(settingView.soundBeatButton)
        }
        
        let vibrationGuide = Settings.shared.watchVibrationGuide
        if vibrationGuide {
            selectButton(settingView.vibrationOnButton)
        } else {
            selectButton(settingView.vibrationOffButton)
        }
        
        let fontSize = Settings.shared.fontSize
        selectFontSizeButton(tag: fontSize)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if soundButtons.contains(sender) {
            // 이전에 선택된 버튼 해제
            if let previousButton = selectedSoundButton {
                deselectButton(previousButton)
            }
            selectButton(sender)
            
            // 소리 설정 업데이트
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
        } else if vibrationButtons.contains(sender) {
            // 이전에 선택된 버튼 해제
            if let previousButton = selectedVibrationButton {
                deselectButton(previousButton)
            }
            selectButton(sender)
            
            // 진동 설정 업데이트
            switch sender {
            case settingView.vibrationOnButton:
                Settings.shared.watchVibrationGuide = true
            case settingView.vibrationOffButton:
                Settings.shared.watchVibrationGuide = false
            default:
                break
            }
            print("Watch 진동 가이드 설정: \(Settings.shared.watchVibrationGuide ? "켜기" : "끄기")")
        }
    }
    
    @objc private func fontSizeButtonTapped(_ sender: UIButton) {
        let selectedFontSize = sender.tag
        Settings.shared.fontSize = selectedFontSize
        selectFontSizeButton(tag: selectedFontSize)
        print("글자 크기 설정: \(selectedFontSize)")
    }
    
    private func selectButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        
        // 그룹별 선택된 버튼 저장
        if soundButtons.contains(button) {
            selectedSoundButton = button
        } else if vibrationButtons.contains(button) {
            selectedVibrationButton = button
        }
    }
    
    private func deselectButton(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func selectFontSizeButton(tag: Int) {
        for button in settingView.fontSizeButtons {
            if button.tag == tag {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.systemBlue, for: .normal)
            }
        }
    }
}