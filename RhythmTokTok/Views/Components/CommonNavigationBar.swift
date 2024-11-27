//
//  CommonNavigationBar.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/18/24.
//

import UIKit

enum NavigationBarButtonType {
    case none
    case watch
    case close
    case main
}

class CommonNavigationBar: UIView {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let rightButtonStackView = UIStackView()
    
    private let appTitleImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "apptitle")
        imageView.image = image
        imageView.tintColor = .error
        return imageView
    }()
    let requestHistoryButton: BadgeButton = {
        let button = BadgeButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = .lableSecondary
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "search"), for: .normal)
        button.tintColor = .lableSecondary
        return button
    }()
    
    let watchConnectImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "watchOff")?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .error
        return imageView
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("설정", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.tintColor = .blue500
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.tintColor = .lableSecondary
        return button
    }()
    
    var onBackButtonTapped: (() -> Void)?
    var onSettingButtonTapped: (() -> Void)?
    var onCloseButtonTapped: (() -> Void)?
    var onRequestHistoryButtonTapped: (() -> Void)?
    var onSearchButtonTapped: (() -> Void)?
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Remove observer to avoid memory leaks
    }
    
    // MARK: - Setup
    private func setupView() {
        // requestHistoryButton의 badge 상태 관리에 쓰일 "isBadgeOn"의 디폴트 값 설정
        UserDefaults.standard.register(defaults: ["isBadgeOn": false])
        
        backgroundColor = .backgroundPrimary
        
        // Back Button
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = .lableSecondary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addSubview(backButton)
        
        // Title Label
        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 18)
        titleLabel.textColor = .lablePrimary
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        // Right Button Stack View
        rightButtonStackView.axis = .horizontal
        rightButtonStackView.alignment = .center
        rightButtonStackView.spacing = 25
        addSubview(rightButtonStackView)
    }
    
    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Right Button Stack View
            rightButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rightButtonStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
    
    @objc private func settingButtonTapped() {
        onSettingButtonTapped?()
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    
    @objc private func requestButtonImageTapped() {
        onRequestHistoryButtonTapped?()
    }
    
    @objc private func searchButtonTapped() {
        onSearchButtonTapped?()
    }
    
    // MARK: - Public Methods
    func configure(title: String, buttonType: NavigationBarButtonType = .none) {
        titleLabel.text = title
        backButton.isHidden = false
        
        // 기존 버튼 제거
        rightButtonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 버튼 타입에 따른 구성
        switch buttonType {
        case .none:
            // 버튼 없음
            break
        case .watch:
            // 워치 상태 이미지 버튼 추가
            rightButtonStackView.addArrangedSubview(watchConnectImageView)
            NSLayoutConstraint.activate([
                watchConnectImageView.widthAnchor.constraint(equalToConstant: 24),
                watchConnectImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            // 설정 버튼 추가
            rightButtonStackView.addArrangedSubview(settingButton)
            settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        case .close:
            // 닫기 버튼 추가
            rightButtonStackView.addArrangedSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                closeButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        case .main:
            
            backButton.isHidden = true
            
            addSubview(appTitleImageView)
            appTitleImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                appTitleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                appTitleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                appTitleImageView.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            // 검색버튼
            rightButtonStackView.addArrangedSubview(searchButton)
            NSLayoutConstraint.activate([
                searchButton.widthAnchor.constraint(equalToConstant: 24),
                searchButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
            
            // 요청 리스트 버튼
            rightButtonStackView.addArrangedSubview(requestHistoryButton)
            NSLayoutConstraint.activate([
                requestHistoryButton.widthAnchor.constraint(equalToConstant: 24),
                requestHistoryButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            requestHistoryButton.addTarget(self, action: #selector(requestButtonImageTapped), for: .touchUpInside)
            
            updateRequestHistoryButton()
        }
    }
    
    @objc private func appDidBecomeActive() {
        updateRequestHistoryButton()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func updateRequestHistoryButton() {
        let isBadgeOn = UserDefaults.standard.bool(forKey: "isBadgeOn")
        if isBadgeOn {
            // 뱃지 보이기
            requestHistoryButton.showBadge(blink: false, text: "")
        } else {
            // 뱃지 숨기기
            requestHistoryButton.hideBadge()
        }
    }
    
    func setWatchImage(isConnected: Bool) {
        DispatchQueue.main.async {
            if isConnected {
                self.watchConnectImageView.image = UIImage(named: "watchActive")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .success
            } else {
                self.watchConnectImageView.image = UIImage(named: "watchOff")?
                    .withRenderingMode(.alwaysTemplate)
                self.watchConnectImageView.tintColor = .error
            }
        }
    }
}
