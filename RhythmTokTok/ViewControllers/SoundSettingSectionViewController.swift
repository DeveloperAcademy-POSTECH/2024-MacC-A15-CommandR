//
//  SoundSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class SoundSettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSoundSettingSectionView()
    }

    private func setupSoundSettingSectionView() {
        let soundSettingView = SoundSettingSectionView()
        soundSettingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(soundSettingView)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            soundSettingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            soundSettingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            soundSettingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            soundSettingView.heightAnchor.constraint(equalToConstant: 200) // 필요에 따라 높이 조절
        ])

        // 선택된 옵션 처리
        soundSettingView.onOptionSelected = { selectedValue in
            print("사용자가 선택한 소리 옵션: \(selectedValue)")
            // 여기서 추가적인 로직을 구현할 수 있습니다.
        }
    }
}
