//
//  SoundSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//

import UIKit

class SoundSettingSectionViewController: UIViewController, RadioButtonPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 델리게이트 메서드 구현
    func radioButtonPicker(_ picker: RadioButtonPicker, didSelectOptionWithValue value: String) {
        print("선택된 값: \(value)")
        // 여기서 선택된 값에 따라 필요한 동작을 수행합니다.
    }
}
