//
//  BPMSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//

import UIKit

class BPMSettingViewController: UIViewController {
    var currentBPM: Int = 120
    var onBPMSelected: ((Int) -> Void)?
    
    // BPM 값을 입력받을 UITextField
    private let bpmTextField = UITextField()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true // 위로 스와이프하여 닫을 수 있는 그래버 표시
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bpmTextField.text = "\(currentBPM)"
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 제목 레이블
        let titleLabel = UILabel()
        titleLabel.text = "빠르기 설정"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // BPM 입력 필드
        bpmTextField.borderStyle = .roundedRect
        bpmTextField.keyboardType = .numberPad
        bpmTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // 확인 버튼
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("설정 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 스택 뷰로 구성 요소 배치
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bpmTextField, confirmButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // titleLabel 제약 조건
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // bpmTextField 제약 조건
            bpmTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bpmTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bpmTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bpmTextField.widthAnchor.constraint(equalToConstant: 335),
            bpmTextField.heightAnchor.constraint(equalToConstant: 64),
            
            confirmButton.topAnchor.constraint(equalTo: bpmTextField.bottomAnchor, constant: 16),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func confirmButtonTapped() {
        // 입력된 BPM 값을 가져옴
        guard let bpmText = bpmTextField.text, let bpmValue = Int(bpmText) else {
            // 입력값이 유효하지 않으면 경고 메시지 표시
            let alert = UIAlertController(title: "오류", message: "유효한 BPM 값을 입력하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        // BPM 값 전달 및 모달 닫기
        onBPMSelected?(bpmValue)
        dismiss(animated: true, completion: nil)
    }
}
