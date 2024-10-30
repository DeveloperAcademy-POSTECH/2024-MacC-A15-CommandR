import UIKit

class HapticSettingSectionView: UIView {
    // 토글 상태를 전달하기 위한 클로저
    var onToggleChanged: ((Bool) -> Void)?
    // 토글 상태를 저장하는 프로퍼티
    private var isOn: Bool = true

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "진동 가이드 설정"
        label.font = UIFont(name: "Pretendard-Bold", size: 21)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "· Watch에서 진동 받기를 켜면, 악보가 재생될 때 손목에서 리듬에 맞춘 진동을 느낄 수 있어요."
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    let watchGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch에서 진동 가이드 받기"
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textColor = .gray
        return label
    }()

    let toggleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SwitchOn") // 이미지 이름을 실제 에셋 이름으로 변경
        imageView.isUserInteractionEnabled = true // 제스처 인식을 위해 필요
        imageView.contentMode = .scaleAspectFit // 추가된 부분
        return imageView
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupGesture()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        // 스택 뷰 생성
        let stackView = UIStackView(arrangedSubviews: [watchGuideLabel, toggleImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8 // 라벨과 이미지 뷰 사이의 간격

        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            // StackView Constraints
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 48),

            // DescriptionLabel Constraints
            descriptionLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func setupGesture() {
        // 이미지 뷰에 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleImageTapped))
        toggleImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @objc private func toggleImageTapped() {
        // 토글 상태 변경
        isOn.toggle()
        updateToggleImage()

        // 토글 상태를 클로저를 통해 전달
        onToggleChanged?(isOn)
    }

    private func updateToggleImage() {
        // 토글 상태에 따라 이미지 변경
        let imageName = isOn ? "SwitchOn" : "SwitchOff"
        toggleImageView.image = UIImage(named: imageName)
    }

    // 외부에서 토글 상태를 설정할 수 있는 메서드
    func setToggleState(isOn: Bool) {
        self.isOn = isOn
        updateToggleImage()
    }
}
