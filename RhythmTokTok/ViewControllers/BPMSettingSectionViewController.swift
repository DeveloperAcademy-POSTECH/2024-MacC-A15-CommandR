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
    
    // TODO: currentBPM 은 추후에 CoreData Entity 에서 현재 설정값 가져와야 함
    var currentBPM: Int = 120
    var onBPMSelected: ((Int) -> Void)?
    
    // BPM 값을 입력받을 UITextField
    private let bpmTextField = UITextField()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // 모달 뷰의 모서리 설정
        view.layer.cornerRadius = 24

        // 키패드가 띄워지도록 자동 포커스
        bpmTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.removeOverlay() // 모달이 닫힐 때 delegate 를 호출하여 어두운 오버레이를 없앰
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bpmTextField.text = "\(currentBPM)"
        if let sheet = sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(resolver: { context in
                return context.maximumDetentValue * 0.3
            })
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 빠르기 설정 라벨
        let titleLabel = UILabel()
        titleLabel.text = "빠르기 설정"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 텍스트 필드
        bpmTextField.borderStyle = .none
        bpmTextField.layer.borderWidth = 2
        bpmTextField.layer.cornerRadius = 12
        bpmTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        bpmTextField.keyboardType = .numberPad
        bpmTextField.font = UIFont(name: "Pretendard-Medium", size: 36)
        bpmTextField.translatesAutoresizingMaskIntoConstraints = false

        // 텍스트 필드 클리어 버튼
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = UIColor(named: "lable_quaternary")
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        // 오른쪽 여백을 포함한 클리어버튼의 컨테이너 뷰 생성 (예: 오른쪽 여백 포함 32)
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        rightPaddingView.addSubview(clearButton)
        
        // 텍스트필드 왼쪽 여백
        bpmTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
        bpmTextField.leftViewMode = .always
        
        // 텍스트필드 클리어버튼 + 오른쪽 여백
        bpmTextField.rightView = rightPaddingView
        bpmTextField.rightViewMode = .always

        // 설정 완료 버튼
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("설정 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(named: "button_primary")
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bpmTextField])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            // titleLabel 제약 조건
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // bpmTextField 제약 조건
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
            confirmButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor) // 키보드 바로 위에 배치

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
    
    @objc private func clearTextField() {
        bpmTextField.text = ""
    }
}
