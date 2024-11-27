import UIKit

class SettingView: UIView {
    // 커스텀 네비게이션 추가
    let customNavBar = CustomNavigationBar()
    
    // 스크롤 뷰 추가
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 섹션 추가
    let bpmSettingSection = BPMSettingSectionView()
    let soundKeySettingSection = SoundKeySettingSectionView()
    let soundSettingSection = SoundSettingSectionView()
    let hapticSettingSection = HapticSettingSectionView()
    
    // 설정 완료 화면 오버레이를 위한 뷰와 버튼 추가
    private let settingDoneOverlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        // 그림자 효과 추가
        overlay.layer.shadowColor = UIColor.black.cgColor
        overlay.layer.shadowOpacity = 0.3
        overlay.layer.shadowOffset = CGSize(width: 0, height: -2)
        overlay.layer.shadowRadius = 8
        return overlay
    }()
    
    private let settingDoneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .buttonPrimary
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        return button
    }()
    
    // 각 섹션의 이벤트를 전달하기 위한 클로저
    var onBPMButtonTapped: (() -> Void)?
    var onSoundKeyChanged: ((Double) -> Void)?
    var onSoundOptionSelected: ((String) -> Void)?
    var onHapticToggleChanged: ((Bool) -> Void)?
    var onSettingDoneButtonTapped: (() -> Void)?
    
// MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        // 각 Section에서 이벤트를 받아서 SettingView로 전달
        bpmSettingSection.onBPMButtonTapped = { [weak self] in
            self?.onBPMButtonTapped?()
        }
        soundSettingSection.onOptionSelected = { [weak self] selectedOption in
            self?.onSoundOptionSelected?(selectedOption)
        }
        hapticSettingSection.onToggleChanged = { [weak self] isOn in
            self?.onHapticToggleChanged?(isOn)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        
        // 각 Section에서 이벤트를 받아서 SettingView로 전달
        bpmSettingSection.onBPMButtonTapped = { [weak self] in
            self?.onBPMButtonTapped?()
        }
        soundSettingSection.onOptionSelected = { [weak self] selectedOption in
            self?.onSoundOptionSelected?(selectedOption)
        }
        hapticSettingSection.onToggleChanged = { [weak self] isOn in
            self?.onHapticToggleChanged?(isOn)
        }
    }
    
// MARK: - Setup Methods
    private func createDivider() -> UIView {
        let uiView = UIView()
        uiView.backgroundColor = .borderSecondary
        return uiView
    }
      
    private func setupUI() {
        backgroundColor = .white

        addScrollViewAndContentView()
        addSubviewsToContentView()
        setupOverlayView()
        setupConstraints()
    }

    private func addScrollViewAndContentView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func addSubviewsToContentView() {
        let divider0 = createDivider()
        let divider1 = createDivider()
        let divider2 = createDivider()
        let divider3 = createDivider()
        let bottomSpacerView = UIView()
        bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacerView.backgroundColor = .clear

        // 섹션과 Divider 추가
        [customNavBar, divider0, bpmSettingSection, divider1, soundKeySettingSection, divider2, soundSettingSection, divider3, hapticSettingSection, bottomSpacerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupOverlayView() {
        addSubview(settingDoneOverlayView)
        settingDoneOverlayView.addSubview(settingDoneButton)
        settingDoneButton.addTarget(self, action: #selector(settingDoneButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        let divider0 = contentView.subviews[1]
        let divider1 = contentView.subviews[3]
        let divider2 = contentView.subviews[5]
        let divider3 = contentView.subviews[7]
        let bottomSpacerView = contentView.subviews.last!

        NSLayoutConstraint.activate([
            // ScrollView Constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // ContentView Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // CustomNavBar Constraints
            customNavBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            customNavBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customNavBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            customNavBar.heightAnchor.constraint(equalToConstant: 50),

            // Divider and Section Constraints
            divider0.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 10),
            divider0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider0.heightAnchor.constraint(equalToConstant: 1),

            bpmSettingSection.topAnchor.constraint(equalTo: divider0.bottomAnchor, constant: 16),
            bpmSettingSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bpmSettingSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            divider1.topAnchor.constraint(equalTo: bpmSettingSection.bottomAnchor, constant: 16),
            divider1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider1.heightAnchor.constraint(equalToConstant: 1),

            soundKeySettingSection.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 16),
            soundKeySettingSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            soundKeySettingSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            divider2.topAnchor.constraint(equalTo: soundKeySettingSection.bottomAnchor, constant: 16),
            divider2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider2.heightAnchor.constraint(equalToConstant: 1),

            soundSettingSection.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 16),
            soundSettingSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            soundSettingSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            divider3.topAnchor.constraint(equalTo: soundSettingSection.bottomAnchor, constant: 16),
            divider3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider3.heightAnchor.constraint(equalToConstant: 1),

            hapticSettingSection.topAnchor.constraint(equalTo: divider3.bottomAnchor, constant: 16),
            hapticSettingSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hapticSettingSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Bottom Spacer View
            bottomSpacerView.topAnchor.constraint(equalTo: hapticSettingSection.bottomAnchor, constant: 16),
            bottomSpacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomSpacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomSpacerView.heightAnchor.constraint(equalToConstant: 130),
            bottomSpacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Overlay View Constraints
            settingDoneOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            settingDoneOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingDoneOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            settingDoneOverlayView.heightAnchor.constraint(equalToConstant: 130),

            settingDoneButton.topAnchor.constraint(equalTo: settingDoneOverlayView.topAnchor, constant: 15),
            settingDoneButton.centerXAnchor.constraint(equalTo: settingDoneOverlayView.centerXAnchor),
            settingDoneButton.widthAnchor.constraint(equalToConstant: 335),
            settingDoneButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

// MARK: - [설정 완료] 버튼
    @objc private func settingDoneButtonTapped() {
        print("설정 완료 버튼이 눌렸습니다.")
        onSettingDoneButtonTapped?() // 버튼 액션 시 클로저 호출
    }

}

// MARK: - [Class] 네비게이션 바
class CustomNavigationBar: UIView {
    let navTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        label.textAlignment = .center
        label.text = "설정"
        label.font = UIFont.customFont(forTextStyle: .subheadingMedium)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            navTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            navTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            navTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
    }
}
