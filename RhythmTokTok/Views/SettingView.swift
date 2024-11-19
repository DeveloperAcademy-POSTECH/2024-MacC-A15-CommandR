import UIKit

class SettingView: UIView {
    // 커스텀 네비게이션 추가
    let customNavBar = CustomNavigationBar()
    
    // 섹션 추가
    let bpmSettingSection = BPMSettingSectionView()
    let soundSettingSection = SoundSettingSectionView()
    let hapticSettingSection = HapticSettingSectionView()
    
    // 설정 완료 화면 오버레이를 위한 뷰와 버튼 추가
    private let settingDoneOverlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        // 그림자 효과 추가
        overlay.layer.shadowColor = UIColor.black.cgColor
        overlay.layer.shadowOpacity = 0.3 // 그림자 투명도 설정
        overlay.layer.shadowOffset = CGSize(width: 0, height: -2) // 그림자 방향 설정 (위쪽으로 약간)
        overlay.layer.shadowRadius = 8 // 그림자 퍼짐 정도 설정
        
        return overlay
    }()
    
    private let settingDoneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("설정 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.backgroundColor = .buttonPrimary
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 각 섹션의 이벤트를 전달하기 위한 클로저
    var onBPMButtonTapped: (() -> Void)?
    var onSoundOptionSelected: ((String) -> Void)?
    var onHapticToggleChanged: ((Bool) -> Void)?
    var onSettingDoneButtonTapped: (() -> Void)?
    
// MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        // bpmSettingSection에서 이벤트를 받아서 SettingView로 전달
        bpmSettingSection.onBPMButtonTapped = { [weak self] in
            self?.onBPMButtonTapped?()
        }
        // soundSettingSection에서 이벤트를 받아서 SettingView로 전달
        soundSettingSection.onOptionSelected = { [weak self] selectedOption in
            self?.onSoundOptionSelected?(selectedOption)
        }
        // hapticGuideSection에서 이벤트를 받아서 SettingView로 전달
        hapticSettingSection.onToggleChanged = { [weak self] isOn in
            self?.onHapticToggleChanged?(isOn)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        
        // bpmSettingSection에서 이벤트를 받아서 SettingView로 전달
        bpmSettingSection.onBPMButtonTapped = { [weak self] in
            self?.onBPMButtonTapped?()
        }
        // soundSettingSection에서 이벤트를 받아서 SettingView로 전달
        soundSettingSection.onOptionSelected = { [weak self] selectedOption in
            self?.onSoundOptionSelected?(selectedOption)
        }
        // hapticGuideSection에서 이벤트를 받아서 SettingView로 전달
        hapticSettingSection.onToggleChanged = { [weak self] isOn in
            self?.onHapticToggleChanged?(isOn)
        }
    }
    
// MARK: - Setup Methods
    private func createDivider() -> UIView {
        let uiView = UIView()
        uiView.backgroundColor = .lightGray
        return uiView
    }
        
    private func setupUI() {
        backgroundColor = .white
        
        let divider0 = createDivider()
        let divider1 = createDivider()
        let divider2 = createDivider()
        
        // 각 뷰의 translatesAutoresizingMaskIntoConstraints 설정
        [customNavBar, divider0, bpmSettingSection, divider1, soundSettingSection, divider2, hapticSettingSection, settingDoneOverlayView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        settingDoneOverlayView.addSubview(settingDoneButton)
        settingDoneButton.addTarget(self, action: #selector(settingDoneButtonTapped), for: .touchUpInside)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            customNavBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            customNavBar.heightAnchor.constraint(equalToConstant: 50),
            
            divider0.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 10),
            divider0.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider0.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider0.heightAnchor.constraint(equalToConstant: 1),
            
            bpmSettingSection.topAnchor.constraint(equalTo: divider0.bottomAnchor, constant: 16),
            bpmSettingSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bpmSettingSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            divider1.topAnchor.constraint(equalTo: bpmSettingSection.bottomAnchor, constant: 16),
            divider1.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider1.heightAnchor.constraint(equalToConstant: 1),
            
            soundSettingSection.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 16),
            soundSettingSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            soundSettingSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            divider2.topAnchor.constraint(equalTo: soundSettingSection.bottomAnchor, constant: 16),
            divider2.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider2.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider2.heightAnchor.constraint(equalToConstant: 1),
            
            hapticSettingSection.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 16),
            hapticSettingSection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            hapticSettingSection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            hapticSettingSection.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

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
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
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
