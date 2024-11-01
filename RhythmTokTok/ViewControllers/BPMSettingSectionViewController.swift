//
//  BPMSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class BPMSettingSectionViewController: UIViewController {
    // TODO: currentBPM 은 추후에 CoreData Entity 에서 현재 설정값 가져와야 함
    var currentBPM: Int = 120
    var onBPMSelected: ((Int) -> Void)?
    
    // BPM 값을 입력받을 UITextField
    private let bpmTextField = UITextField()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheet = sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { context in
                return context.maximumDetentValue * 0.77 // 화면 높이의 77%
            })
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bpmTextField.text = "\(currentBPM)"
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "빠르기 설정"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bpmTextField.borderStyle = .roundedRect
        bpmTextField.keyboardType = .numberPad
        bpmTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("설정 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bpmTextField, confirmButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // titleLabel 제약 조건
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // bpmTextField 제약 조건
            bpmTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            bpmTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bpmTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
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
