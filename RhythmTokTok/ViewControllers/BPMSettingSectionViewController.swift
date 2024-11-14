//
//  BPMSettingViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

// 모달이 닫혔을 때 어두운 배경을 제거하기
protocol BPMSettingDelegate: AnyObject {
    func removeOverlay()
}

class BPMSettingSectionViewController: UIViewController {
    var delegate: BPMSettingDelegate?
    var currentBPM: Int = 0
    var onBPMSelected: ((Int) -> Void)?

    private let titleLabel = UILabel()
    private let bpmTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layer.cornerRadius = 24 // 모달 뷰의 모서리 설정
        bpmTextField.becomeFirstResponder() // 키패드가 띄워지도록 자동 포커스
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.removeOverlay() // 모달이 닫힐 때 delegate 를 호출하여 부모뷰의 어두운 오버레이를 없앰
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bpmTextField.text = "\(currentBPM)"
        bpmTextField.addTarget(self, action: #selector(bpmTextFieldDidChange), for: .editingChanged)
        
        if let sheet = sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { context in
                return context.maximumDetentValue * 0.3 // 모달 높이 조정
            })
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setTitleLabelUI()
        setBPMTextFieldUI()
        setConfirmButtonUI()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bpmTextField])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            bpmTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            bpmTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bpmTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bpmTextField.widthAnchor.constraint(equalToConstant: 335),
            bpmTextField.heightAnchor.constraint(equalToConstant: 64),
            
            confirmButton.topAnchor.constraint(equalTo: bpmTextField.bottomAnchor, constant: 32),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
}

// 타이틀 관련 UI 설정 및 함수
extension BPMSettingSectionViewController {
    func setTitleLabelUI() {
        titleLabel.text = "빠르기 설정"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}

// 텍스트 필드 관련 UI 설정 및 함수
extension BPMSettingSectionViewController {
    func setBPMTextFieldUI() {
        bpmTextField.borderStyle = .none
        bpmTextField.layer.borderWidth = 2
        bpmTextField.layer.cornerRadius = 12
        bpmTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        bpmTextField.keyboardType = .numberPad
        bpmTextField.font = UIFont(name: "Pretendard-Medium", size: 36)
        bpmTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = UIColor(named: "lable_quaternary")
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        rightPaddingView.addSubview(clearButton)
        
        bpmTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
        bpmTextField.leftViewMode = .always
        
        bpmTextField.rightView = rightPaddingView
        bpmTextField.rightViewMode = .always
    }
    
    @objc private func bpmTextFieldDidChange() {
        if let text = bpmTextField.text, text.count > 3 {
            bpmTextField.text = String(text.prefix(3)) // 첫 3글자만 남김
        }
    }
    
    @objc private func clearTextField() {
        bpmTextField.text = ""
    }
}

// 설정 완료 버튼 관련 UI 설정 및 함수
extension BPMSettingSectionViewController {
    func setConfirmButtonUI() {
        confirmButton.setTitle("설정 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(named: "button_primary")
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func confirmButtonTapped() {
        self.view.endEditing(true)
        
        if let bpmText = bpmTextField.text, let bpmValue = Int(bpmText) {
            if bpmValue < 20 || bpmValue > 280 {
                let alert = UIAlertController(title: "오류", message: "20~280 사이의 BPM 값을 입력하세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.clearTextField()
                    self.bpmTextField.becomeFirstResponder() // 경고 표시 후 포커스 다시 줌
                }))
                self.present(alert, animated: true)
            } else {
                onBPMSelected?(bpmValue)
                dismiss(animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "오류", message: "BPM 값을 입력하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.clearTextField()
                self.bpmTextField.becomeFirstResponder()
            }))
            self.present(alert, animated: true)
        }
    }
}
