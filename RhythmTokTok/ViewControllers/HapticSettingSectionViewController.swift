//
//  SoundSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class HapticSettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHapticSettingSectionView()
    }

    private func setupHapticSettingSectionView() {
        let hapticSettingView = HapticSettingSectionView()
        hapticSettingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hapticSettingView)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            hapticSettingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hapticSettingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hapticSettingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 필요에 따라 높이 조절
            hapticSettingView.heightAnchor.constraint(equalToConstant: 200)
        ])

        // 토글 상태 변경 시 처리
        hapticSettingView.onToggleChanged = { [weak self] isOn in
            print("진동 가이드 설정 상태: \(isOn)")
            // 추가적인 로직을 여기서 구현할 수 있습니다.
        }
    }
}
