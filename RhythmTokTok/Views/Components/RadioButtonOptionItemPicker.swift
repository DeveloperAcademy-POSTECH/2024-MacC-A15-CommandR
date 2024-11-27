//
//  RadioButtonOptionItemPicker.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 11/1/24.
//
import UIKit

class RadioButtonOptionItemPicker: UIView {
    private var options: [RadioButtonOptionItem] = []
    private var selectedOption: RadioButtonOptionItem?
    weak var delegate: RadioButtonOptionItemPickerDelegate?
    
    init(options: [(title: String, value: String)], selectedValue: String? = nil) {
        super.init(frame: .zero)
        setupOptions(options, selectedValue: selectedValue)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupOptions(_ optionData: [(title: String, value: String)], selectedValue: String?) {
        var previousOption: RadioButtonOptionItem?

        for data in optionData {
            let option = RadioButtonOptionItem(title: data.title, value: data.value)
            option.translatesAutoresizingMaskIntoConstraints = false
//            option.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:))))
            
            // 클릭 이벤트 클로저 설정
            option.onTapped = { [weak self] in
                self?.optionTapped(option)
            }
            
            addSubview(option)
            options.append(option)
            
            // 초기 선택 상태 설정
            if let selectedValue = selectedValue, data.value == selectedValue {
                option.isChecked = true
                selectedOption = option
                print("selectedValue \(selectedValue)")
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

    private func optionTapped(_ tappedOption: RadioButtonOptionItem) {
            // 기존 선택 해제
            if let previouslySelected = selectedOption, previouslySelected != tappedOption {
                previouslySelected.isChecked = false
            }

            // 새로운 옵션 선택
            tappedOption.isChecked = true
            selectedOption = tappedOption

            // 델리게이트 메서드 호출
            delegate?.radioButtonPicker(self, didSelectOptionWithValue: tappedOption.optionValue)
        }

    // 선택된 값을 설정하는 메서드 추가
    func setSelectedValue(_ value: String) {
        if let option = options.first(where: { $0.optionValue == value }) {
            // 기존 선택 해제
            selectedOption?.isChecked = false
            // 새로운 선택 설정
            option.isChecked = true
            selectedOption = option
        }
    }
}

protocol RadioButtonOptionItemPickerDelegate: AnyObject {
    func radioButtonPicker(_ picker: RadioButtonOptionItemPicker, didSelectOptionWithValue value: String)
}
