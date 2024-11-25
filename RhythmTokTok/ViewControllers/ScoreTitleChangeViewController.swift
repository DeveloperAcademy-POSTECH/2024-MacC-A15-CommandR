//
//  ScoreTitleChangeViewController.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 11/20/24.
//
import UIKit

// 모달이 닫혔을 때 어두운 배경을 제거하기
protocol ScoreTitleChangeDelegate: AnyObject {
    func removeOverlay()
}

class ScoreTitleChangeViewController: UIViewController {
    var delegate: ScoreTitleChangeDelegate?
    var currentTitle: String = ""
    var onTitleChanged: ((String) -> Void)?

    private let titleTextField = UITextField()
    private let confirmButton = UIButton(type: .system)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layer.cornerRadius = 24 // 모달 뷰의 모서리 설정
        titleTextField.becomeFirstResponder() // 키패드가 띄워지도록 자동 포커스
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.removeOverlay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        titleTextField.text = currentTitle.isEmpty ? "Untitled" : currentTitle
        confirmButton.addTarget(self, action: #selector(titleTextFieldDidChange), for: .editingChanged)
        
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

        setTitleTextFieldUI()
        setConfirmButtonUI()
        
        view.addSubview(titleTextField)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleTextField.widthAnchor.constraint(equalToConstant: 335),
            titleTextField.heightAnchor.constraint(equalToConstant: 64),
            
            confirmButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 32),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
}

// MARK: - 텍스트 필드 관련 UI 설정 및 함수
extension ScoreTitleChangeViewController {
    func setTitleTextFieldUI() {
        titleTextField.borderStyle = .none
        titleTextField.layer.borderWidth = 2
        titleTextField.layer.cornerRadius = 12
        titleTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        titleTextField.font = UIFont.customFont(forTextStyle: .body1Medium)
        titleTextField.adjustsFontForContentSizeCategory = true
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let clearButton = UIButton(type: .custom)
        if let clearButtonImage = UIImage(named: "cancle.fill")?.withRenderingMode(.alwaysTemplate) {
            clearButton.setImage(clearButtonImage, for: .normal)
            clearButton.tintColor = UIColor(named: "lable_quaternary") // Color Set 이름 사용
        }
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        rightPaddingView.addSubview(clearButton)
        
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
        titleTextField.leftViewMode = .always
        
        titleTextField.rightView = rightPaddingView
        titleTextField.rightViewMode = .always
        
        // 텍스트 크기에 따라 높이 조정
        titleTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleTextField.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    @objc private func titleTextFieldDidChange() {
        if let text = titleTextField.text, text.count > 3 {
            titleTextField.text = String(text.prefix(3)) // 첫 3글자만 남김
        }
    }
    
    @objc private func clearTextField() {
        titleTextField.text = ""
    }
}

// MARK: - 설정 완료 버튼 관련 UI 설정 및 함수
extension ScoreTitleChangeViewController {
    func setConfirmButtonUI() {
        confirmButton.setTitle("제목 수정 완료", for: .normal)
        confirmButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(named: "button_primary")
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func confirmButtonTapped() {
        self.view.endEditing(true)
        
        if let titleText = titleTextField.text {
            if titleText == "" {
                let alert = UIAlertController(title: "오류", message: "수정할 제목을 입력하세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.clearTextField()
                    self.titleTextField.becomeFirstResponder()
                }))
                self.present(alert, animated: true)
            } else if titleText.count > 20 {
                let alert = UIAlertController(title: "오류", message: "제목은 20자 이하로 입력하세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.clearTextField()
                    self.titleTextField.becomeFirstResponder()
                }))
                self.present(alert, animated: true)
            } else {
                onTitleChanged?(titleText)
                dismiss(animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "오류", message: "제목을 입력하세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.clearTextField()
                self.titleTextField.becomeFirstResponder()
            }))
            self.present(alert, animated: true)
        }
    }
}
