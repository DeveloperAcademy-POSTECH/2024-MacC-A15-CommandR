//
//  audioPreviewButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/25/24.
//

import UIKit
import WebKit

class AudioPreviewButton: UIView {
    private var webView: WKWebView!
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "미리듣기"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = UIColor(named: "label_secondary") ?? UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "button_secondary")
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "sound") // 기본 이미지
        return imageView
    }()
    
    var isPlaying = false {
        didSet {
            if isPlaying {
                showGIF()
            } else {
                hideGIF()
                showStaticImage()
            }
        }
    }
    
    var onAudioPreviewButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(button)
        addSubview(textLabel)
        addSubview(imageView)
        
        // 버튼 제약 조건
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // WebView 설정
        webView = WKWebView()
        webView.isUserInteractionEnabled = false // 사용자 상호작용 비활성화
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        addSubview(webView)
        
        // WebView 제약 조건
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 13),
            webView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: 24), // GIF 크기
            webView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // ImageView 제약 조건
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 13),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // 텍스트 레이블 제약 조건 (버튼 안에서 위치 조정)
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4)
        ])
        
        // 버튼 액션 설정
        button.addTarget(self, action: #selector(audioPreviewButtonTapped), for: .touchUpInside)
    }
    
    @objc private func audioPreviewButtonTapped() {
        onAudioPreviewButtonTapped?()
        isPlaying.toggle()
    }
    
    private func showGIF() {
        DispatchQueue.main.async {
            guard let gifPath = Bundle.main.path(forResource: "previewPlay", ofType: "gif") else { return }
            if let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
                self.webView.load(gifData, mimeType: "image/gif",
                                  characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: gifPath))
            }
            self.webView.isHidden = false
            self.imageView.isHidden = true // 기본 이미지 숨기기
        }
    }

    private func hideGIF() {
        DispatchQueue.main.async {
            self.webView.isHidden = true
        }
    }

    private func showStaticImage() {
        DispatchQueue.main.async {
            self.imageView.isHidden = false // 기본 이미지 표시
        }
    }
}
