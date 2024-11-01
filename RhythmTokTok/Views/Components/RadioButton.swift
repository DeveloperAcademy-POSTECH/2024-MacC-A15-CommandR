//
//  RadioButton.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/31/24.
//
import UIKit

class RadioButton: UIButton {
    var isChecked: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.backgroundColor = .clear
    }

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
