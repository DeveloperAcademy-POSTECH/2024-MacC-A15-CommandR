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
    var maxCharacterLimit: Int = 20
    var onTitleChanged: ((String) -> Void)?

    private let titleTextField = UITextField()
    private let subtitleLabel = UILabel()
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
        setSubtitleLabelUI()
        setConfirmButtonUI()
        
        view.addSubview(titleTextField)
        view.addSubview(subtitleLabel)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 8),

            titleTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
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
    
    func setSubtitleLabelUI() {
        subtitleLabel.text = ""
        subtitleLabel.textColor = UIColor(named: "lable_tertiary")
        subtitleLabel.font = UIFont.customFont(forTextStyle: .body2Regular)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Update the border color when the text field is touched
        titleTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Optionally reset the border color when editing ends
        updateBorderColor()
        titleTextField.layer.borderColor = UIColor(named: "border_primary")?.cgColor
    }
    
    func didClearTextField() {
        titleTextField.text = ""
        updateBorderColor()
        titleTextField.becomeFirstResponder()
        textFieldDidBeginEditing(titleTextField)
    }
    
    func updateBorderColor() {
        guard let text = titleTextField.text else { return }
        
        if text.isEmpty {
            // TextField가 비어 있을 때 버튼 비활성화
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor(named: "button_inactive")
            titleTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        } else if text.count > maxCharacterLimit {
            // 글자 수 제한 초과 시 버튼 비활성화 및 텍스트필드 색 변경
            titleTextField.layer.borderColor = UIColor(named: "button_danger")?.cgColor
            subtitleLabel.textColor = UIColor(named: "button_danger")
            subtitleLabel.text = "제목은 최대 \(maxCharacterLimit)글자까지 쓸 수 있어요"
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor(named: "button_inactive")
        } else if isTitleTaken(text, currentTitle) {
            // 제목이 중복될 때 버튼 비활성화 및 텍스트필드 색 변경
            titleTextField.layer.borderColor = UIColor(named: "button_danger")?.cgColor
            subtitleLabel.textColor = UIColor(named: "button_danger")
            subtitleLabel.text = "이미 있는 제목이에요"
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor(named: "button_inactive")
        } else {
            // 조건이 맞을 시 버튼 활성화
            titleTextField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
            subtitleLabel.textColor = UIColor(named: "lable_tertiary")
            subtitleLabel.text = ""
            confirmButton.isEnabled = true
            confirmButton.backgroundColor = UIColor(named: "button_primary")
        }
    }
    
    private func isTitleTaken(_ title: String, _ currentTitle: String) -> Bool {
        var result: Bool = true

        // UserDefaults에서 takenTitle 배열 가져오기
        let takenTitles = UserDefaults.standard.stringArray(forKey: "takenTitle") ?? []
        
        // 적고있는 제목이 현재 제목이랑 같거나 -> result = false
        // 적고있는 제목이 다른 기존 제목이랑 다른건 됨 -> result = false
        if title == currentTitle || !takenTitles.contains(title) {
            result = false
        }
        
        return result
    }
}
