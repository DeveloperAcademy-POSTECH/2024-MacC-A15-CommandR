//
//  BPMSettingView.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/30/24.
//
import UIKit

class SoundSettingSectionView: UIView, RadioButtonPickerDelegate {
    // 선택된 옵션을 전달하기 위한 클로저
    var onOptionSelected: ((String) -> Void)?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "소리 설정"
        label.font = UIFont(name: "Pretendard-Bold", size: 21)
        return label
    }()
    
    let pickerOptions = [
        (title: "멜로디로 듣기", value: "melody"),
        (title: "박자만 듣기", value: "beat"),
        (title: "소리 끄기", value: "mute")
    ]
    
    lazy var radioButtonPicker: RadioButtonPicker = {
        let picker = RadioButtonPicker(options: pickerOptions)
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(radioButtonPicker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            // RadioButtonPicker Constraints
            radioButtonPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            radioButtonPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            radioButtonPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            radioButtonPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - RadioButtonPickerDelegate
    func radioButtonPicker(_ picker: RadioButtonPicker, didSelectOptionWithValue value: String) {
        print("선택된 소리 옵션: \(value)")
        // 선택된 값을 클로저를 통해 전달
        onOptionSelected?(value)
    }
}

protocol SoundSettingSectionDelegate: AnyObject {
    func radioButtonPicker(_ picker: RadioButtonPicker, didSelectOptionWithValue value: String)
}

class RadioButton: UIButton {
    // 선택 여부를 나타내는 프로퍼티
    var isChecked: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    // 버튼 설정
    private func setupButton() {
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.backgroundColor = .clear
    }

    // 버튼 외형 업데이트
    private func updateAppearance() {
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureAppearance()
    }

    private func configureAppearance() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderWidth = 2

        if isChecked {
            // 선택된 상태: 파란색 테두리와 내부 원
            self.layer.borderColor = UIColor.blue.cgColor
            addInnerCircle(color: UIColor.blue)
        } else {
            // 선택되지 않은 상태: 회색 테두리
            self.layer.borderColor = UIColor.gray.cgColor
            removeInnerCircle()
        }
    }

    private func addInnerCircle(color: UIColor) {
        if self.viewWithTag(100) == nil {
            let innerCircle = UIView(frame: CGRect(x: 4, y: 4, width: self.bounds.width - 8, height: self.bounds.height - 8))
            innerCircle.backgroundColor = color
            innerCircle.layer.cornerRadius = innerCircle.bounds.height / 2
            innerCircle.isUserInteractionEnabled = false
            innerCircle.tag = 100
            self.addSubview(innerCircle)
        }
    }

    private func removeInnerCircle() {
        if let innerCircle = self.viewWithTag(100) {
            innerCircle.removeFromSuperview()
        }
    }

    // 버튼 탭 액션
    @objc private func buttonTapped() {
        // 외부에서 선택 상태를 관리하므로 여기서는 상태를 변경하지 않습니다.
    }
}

class RadioButtonOption: UIView {
    let radioButton = RadioButton()
    let titleLabel = UILabel()
    
    // 항목 식별자 또는 값
    let optionValue: String
    
    init(title: String, value: String) {
        self.optionValue = value
        super.init(frame: .zero)
        setupView(title: title)
    }
    
    required init?(coder: NSCoder) {
        self.optionValue = ""
        super.init(coder: coder)
        setupView(title: "")
    }
    
    private func setupView(title: String) {
        // 라디오 버튼 설정
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.isChecked = false
        
        // 타이틀 라벨 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        // 뷰에 추가
        addSubview(radioButton)
        addSubview(titleLabel)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

class RadioButtonPicker: UIView {
    private var options: [RadioButtonOption] = []
    private var selectedOption: RadioButtonOption?
    weak var delegate: RadioButtonPickerDelegate?

    init(options: [(title: String, value: String)], selectedValue: String? = nil) {
        super.init(frame: .zero)
        setupOptions(options, selectedValue: selectedValue)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupOptions(_ optionData: [(title: String, value: String)], selectedValue: String?) {
        var previousOption: RadioButtonOption?

        for data in optionData {
            let option = RadioButtonOption(title: data.title, value: data.value)
            option.translatesAutoresizingMaskIntoConstraints = false
            option.radioButton.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            addSubview(option)
            options.append(option)

            // 초기 선택 상태 설정
            if let selectedValue = selectedValue, data.value == selectedValue {
                option.radioButton.isChecked = true
                selectedOption = option
            }

            // 제약 조건 설정
            NSLayoutConstraint.activate([
                option.leadingAnchor.constraint(equalTo: leadingAnchor),
                option.trailingAnchor.constraint(equalTo: trailingAnchor),
                option.heightAnchor.constraint(equalToConstant: 44)
            ])

            if let previous = previousOption {
                option.topAnchor.constraint(equalTo: previous.bottomAnchor).isActive = true
            } else {
                option.topAnchor.constraint(equalTo: topAnchor).isActive = true
            }

            previousOption = option
        }

        // 마지막 옵션의 bottomAnchor 설정
        if let lastOption = options.last {
            lastOption.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    @objc private func optionSelected(_ sender: RadioButton) {
        guard let selectedOption = options.first(where: { $0.radioButton == sender }) else { return }

        // 기존 선택 해제
        self.selectedOption?.radioButton.isChecked = false

        // 새로운 선택 설정
        selectedOption.radioButton.isChecked = true
        self.selectedOption = selectedOption

        // 델리게이트 메서드 호출
        delegate?.radioButtonPicker(self, didSelectOptionWithValue: selectedOption.optionValue)
    }

    // 선택된 값을 설정하는 메서드 추가
    func setSelectedValue(_ value: String) {
        if let option = options.first(where: { $0.optionValue == value }) {
            // 기존 선택 해제
            selectedOption?.radioButton.isChecked = false
            // 새로운 선택 설정
            option.radioButton.isChecked = true
            selectedOption = option
        }
    }
}

protocol RadioButtonPickerDelegate: AnyObject {
    func radioButtonPicker(_ picker: RadioButtonPicker, didSelectOptionWithValue value: String)
}

