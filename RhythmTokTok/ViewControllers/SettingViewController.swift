//
//  SettingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
import UIKit
import WatchConnectivity

class SettingViewController: UIViewController {
    
    let settingView = SettingView()
    
    // 현재 선택된 소리 설정 버튼
    var selectedSoundButton: UIButton?
    
    // 현재 선택된 진동 가이드 버튼
    var selectedHapticButton: UIButton?
    
    // 소리 설정 버튼들
    var soundButtons: [UIButton] {
        return settingView.soundButtons
    }
    
    // 진동 가이드 설정 버튼들
    var hapticButtons: [UIButton] {
        return settingView.hapticButtons
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
        for button in soundButtons + hapticButtons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        for button in settingView.fontSizeButtons {
            button.addTarget(self, action: #selector(fontSizeButtonTapped(_:)), for: .touchUpInside)
        }
        // BPM 슬라이더 값 변경 시 액션 추가
        settingView.bpmSlider.addTarget(self, action: #selector(bpmSliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func loadSettings() {
        let soundSetting = UserSettingData.shared.soundSetting
        switch soundSetting {
        case .voice:
            selectButton(settingView.soundButtons[0])
        case .melody:
            selectButton(settingView.soundButtons[1])
        case .beat:
            selectButton(settingView.soundButtons[2])
        case .mute:
            selectButton(settingView.soundButtons[3])
        }
        
        let hapticGuide = UserSettingData.shared.isHapticGuideOn
        if hapticGuide {
            selectButton(settingView.hapticButtons[hapticGuide ? 0 : 1])
        }
        
        let fontSize = UserSettingData.shared.fontSize
        selectFontSizeButton(tag: fontSize)
        
        // 저장된 BPM 값 로드
        let currentBPM = UserSettingData.shared.bpm
        settingView.bpmSlider.value = Float(currentBPM)
        settingView.currentBPMLabel.text = "현재 BPM: \(currentBPM)"
    }
    
    @objc private func bpmSliderValueChanged(_ sender: UISlider) {
        let bpmValue = Int(sender.value)
        // BPM 값을 업데이트하고 라벨 갱신
        UserSettingData.shared.bpm = bpmValue
        settingView.currentBPMLabel.text = "현재 BPM: \(bpmValue)"
        print("BPM 설정 변경: \(bpmValue)")
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if soundButtons.contains(sender) {
            // 이전에 선택된 버튼 해제
            if let previousButton = selectedSoundButton {
                deselectButton(previousButton)
            }
            selectButton(sender)
            
            // 소리 설정 업데이트
            if let index = soundButtons.firstIndex(of: sender) {
                switch index {
                case 0:
                    UserSettingData.shared.soundSetting = .voice
                case 1:
                    UserSettingData.shared.soundSetting = .melody
                case 2:
                    UserSettingData.shared.soundSetting = .beat
                case 3:
                    UserSettingData.shared.soundSetting = .mute
                default:
                    break
                }
            }
            print("소리 설정 변경: \(UserSettingData.shared.soundSetting.rawValue)")
        } else if hapticButtons.contains(sender) {
            // 이전에 선택된 버튼 해제
            if let previousButton = selectedHapticButton {
                deselectButton(previousButton)
            }
            selectButton(sender)
            
            // 진동 설정 업데이트
            if let index = hapticButtons.firstIndex(of: sender) {
                switch index {
                case 0:
                    UserSettingData.shared.isHapticGuideOn = true
                case 1:
                    UserSettingData.shared.isHapticGuideOn = false
                default:
                    break
                }
                // 설정 변경 시 워치로 설정 전송
                sendHapticGuideSettingToWatch()
            }
            print("Watch 진동 가이드 설정: \(UserSettingData.shared.isHapticGuideOn ? "켜기" : "끄기")")
        }
    }
    private func sendHapticGuideSettingToWatch() {
        let message: [String: Any] = [
            "watchHapticGuide": UserSettingData.shared.isHapticGuideOn
        ]
        do {
            try WCSession.default.updateApplicationContext(message)
            print("햅틱 가이드 설정을 워치로 전송함: \(message)")
        } catch {
            ErrorHandler.handleError(error: "워치로 햅틱 가이드 설정 전송 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    
    @objc private func fontSizeButtonTapped(_ sender: UIButton) {
        let selectedFontSize = sender.tag
        UserSettingData.shared.fontSize = selectedFontSize
        selectFontSizeButton(tag: selectedFontSize)
        print("글자 크기 설정: \(selectedFontSize)")
    }
    
    private func selectButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        
        // 그룹별 선택된 버튼 저장
        if soundButtons.contains(button) {
            selectedSoundButton = button
        } else if hapticButtons.contains(button) {
            selectedHapticButton = button
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
