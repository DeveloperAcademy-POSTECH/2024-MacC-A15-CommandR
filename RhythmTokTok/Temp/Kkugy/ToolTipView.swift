//
//  ToolTipView.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/11/24.
//

import UIKit

class ToolTipView: UIView {
    private let containerView = UIView() // 라운드 박스 뷰
    private let arrowView = UIView() // 화살표 뷰
    private let textLabel = UILabel() // 텍스트 레이블
    private var arrowSize: CGSize = CGSize(width: 16, height: 8)
    private let closeButton = UIButton(type: .system) // 클로즈 버튼
    private var status: AppleWatchStatus {
        didSet {
            configureForStatus() // 상태가 변경될 때마다 텍스트 업데이트
        }
    }
    
    init(status: AppleWatchStatus) {
        self.status = status
        super.init(frame: .zero)
        setupViews()
        configureForStatus()
        drawArrow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        // 라운드 박스 설정
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        containerView.layer.shadowOpacity = 0.2 // 그림자 투명도 (0.0 ~ 1.0)
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4) // 그림자 오프셋
        containerView.layer.shadowRadius = 8 // 그림자의 블러 반경
        containerView.layer.masksToBounds = false // 그림자가 컨테이너 밖으로 보이게 설정
        containerView.backgroundColor = .gray950
        addSubview(containerView)
        
        // 텍스트 레이블 설정
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        setLabelText(with: "none") // 기본 텍스트로 호출
        containerView.addSubview(textLabel)
        
        // 화살표 뷰 설정
        arrowView.backgroundColor = .clear
        addSubview(arrowView)
        
        // 클로즈 버튼 설정
        if let closeImage = UIImage(named: "close") {
            closeButton.setImage(closeImage, for: .normal)
        }
        closeButton.tintColor = .gray300 // 이미지 색상 설정
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        containerView.addSubview(closeButton)

        // 오토레이아웃 설정
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // containerView 레이아웃 설정 (라운드 박스)
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: arrowSize.height),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 텍스트 레이블 레이아웃 설정
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // 클로즈 버튼 레이아웃 설정
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            // 화살표 뷰 레이아웃 설정 (라운드 박스 상단에 위치)
            arrowView.centerXAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -36), // 화살표 위치 조정
            arrowView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: arrowSize.width),
            arrowView.heightAnchor.constraint(equalToConstant: arrowSize.height)
        ])
    }
    
    private func configureForStatus() {
        switch status {
        case .ready, .connected:
            self.isHidden = true
            return
        case .backgroundInactive:
            textLabel.text = "워치를 쳐다봐 주세요.\n워치를 깨우면 앱이 켜져요."
            textLabel.textColor = .white
            self.isHidden = false
            
        case .disconnected:
            textLabel.text = "연결이 끊어졌습니다.\n처음부터 다시 시작해 주세요."
            textLabel.textColor = .white
            self.isHidden = false
            
        case .lowBattery:
            textLabel.text = "메트로놈 진동을 느끼려면,\n워치에서 앱을 켜주세요."
            textLabel.textColor = .white
            self.isHidden = false
            
        case .notInstalled:
            textLabel.text = "워치 앱이 필요해요.\n설치 후 연결할 수 있어요."
            textLabel.textColor = .white
            self.isHidden = false

        }
    }
    
    func setStatus(_ newStatus: AppleWatchStatus) {
        self.status = newStatus
    }
    
    private func drawArrow() {
        // 화살표 레이어 생성
        let arrowLayer = CAShapeLayer()
        let arrowPath = UIBezierPath()
        
        // 화살표 모양 정의
        arrowPath.move(to: CGPoint(x: 0, y: arrowSize.height))
        arrowPath.addLine(to: CGPoint(x: arrowSize.width / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height))
        arrowPath.close()
        
        // 화살표 색상과 모양 설정
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = containerView.backgroundColor?.cgColor
        arrowView.layer.addSublayer(arrowLayer)
    }
    
    private func setLabelText(with text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 24 - textLabel.font.lineHeight // 24px line-height 설정
        paragraphStyle.alignment = .left

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont(name: "Pretendard-Medium", size: 16)!,
                .paragraphStyle: paragraphStyle,
                .kern: -0.096 // letter-spacing 설정
            ]
        )
        textLabel.attributedText = attributedText
    }
    
    // 클로즈 버튼 액션
    @objc private func didTapClose() {
        self.isHidden = true
    }
}
