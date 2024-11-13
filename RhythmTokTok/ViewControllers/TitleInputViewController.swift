import UIKit

class TitleInputViewController: UIViewController, TitleInputViewDelegate, UITextFieldDelegate {
    var titleInputView: TitleInputView!
    var accessoryButton: UIButton!
    var fileURL: URL?
    private let maxCharacterLimit = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupAccessoryButton()
        titleInputView.textField.delegate = self
    }

    private func setupUI() {
        // TitleInputView 생성하고 subview로 넣기
        titleInputView = TitleInputView()
        titleInputView.delegate = self // Set delegate
        titleInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleInputView)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            titleInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupAccessoryButton() {
        // 키보드에 붙은 accessoryButton 생성
        accessoryButton = UIButton(type: .system)
        accessoryButton.setTitle("입력 완료", for: .normal)
        accessoryButton.setTitleColor(.white, for: .normal)
        accessoryButton.backgroundColor = UIColor(named: "button_inactive")
        accessoryButton.isEnabled = false
        accessoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.addTarget(self, action: #selector(accessoryButtonTapped), for: .touchUpInside)

        // 키보드에 붙을 버튼의 컨테이너 뷰 생성
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        accessoryView.backgroundColor = .clear
        accessoryView.addSubview(accessoryButton)

        // accessoryButton이 가로 세로 너비 설정, 높이 설정
        NSLayoutConstraint.activate([
            accessoryButton.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor),
            accessoryButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor),
            accessoryButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
            accessoryButton.heightAnchor.constraint(equalToConstant: 64)
        ])

        // 텍스트 필드에 액세서리 뷰를 설정
        titleInputView.textField.inputAccessoryView = accessoryView
    }

    @objc private func accessoryButtonTapped() {
        // 키보드에 붙은 버튼이 터치되었을 때의 액션
        titleInputView.textField.resignFirstResponder() // 키보드 dismiss
    }

    // MARK: - TitleInputViewDelegate
    func updateAccessoryButtonState(isEnabled: Bool) {
        accessoryButton.isEnabled = isEnabled
        accessoryButton.backgroundColor = isEnabled ? UIColor(named: "button_primary") : UIColor(named: "button_inactive")
    }
    
    func didTapCompleteButton(with filename: String) {
        let pdfConfirmationViewController = PDFConvertRequestConfirmationViewController()
        pdfConfirmationViewController.fileURL = fileURL
        pdfConfirmationViewController.filename = filename
        
        navigationController?.pushViewController(pdfConfirmationViewController, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            // Update the border color when the text field is touched
            titleInputView.textField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
        }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Optionally reset the border color when editing ends
        updateBorderColor()
        titleInputView.textField.layer.borderColor = UIColor(named: "border_primary")?.cgColor
    }
    
    func updateBorderColor() {
        if let text = titleInputView.textField.text, text.isEmpty {
            // TextField가 비어 있을 때 버튼 비활성화
            titleInputView.completeButton.isEnabled = false
            titleInputView.completeButton.backgroundColor = UIColor(named: "button_inactive")
            titleInputView.textField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
            titleInputView.subtitleLabel.textColor = UIColor(named: "lable_tertiary")
            updateAccessoryButtonState(isEnabled: false) // Update accessory button
        } else if let text = titleInputView.textField.text, text.count > maxCharacterLimit {
            // 글자 수 제한 초과 시 버튼 비활성화 및 텍스트필드 색 변경
            titleInputView.textField.layer.borderColor = UIColor(named: "button_danger")?.cgColor
            titleInputView.subtitleLabel.textColor = UIColor(named: "button_danger")
            titleInputView.completeButton.isEnabled = false
            titleInputView.completeButton.backgroundColor = UIColor(named: "button_inactive")
            updateAccessoryButtonState(isEnabled: false) // Update accessory button
        } else {
            // 조건이 맞을 시 버튼 활성화
            titleInputView.textField.layer.borderColor = UIColor(named: "button_primary")?.cgColor
            titleInputView.subtitleLabel.textColor = UIColor(named: "lable_tertiary")
            titleInputView.completeButton.isEnabled = true
            titleInputView.completeButton.backgroundColor = UIColor(named: "button_primary")
            updateAccessoryButtonState(isEnabled: true) // Update accessory button
        }
    }
}
