//
//  MeasureControllerButton.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/30/24.
//
import UIKit

class MeasureControllerButton: UIButton {
    
    init(icon: UIImage?, title: String, backGroundColor: UIColor, foregoundColor: UIColor, strokeColor: UIColor = .clear, pressedColor: UIColor) {
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.plain()
        config.image = icon?
            .withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .top // 이미지와 텍스트 위치
        config.imagePadding = 8 // 이미지와 텍스트 사이 간격
        config.baseForegroundColor = foregoundColor // 텍스트 및 이미지 색상
        config.background.backgroundColor = backGroundColor // 배경색 설정
        config.background.strokeColor = strokeColor // 테두리 색상 설정
        config.background.strokeWidth = 1.5
        config.background.cornerRadius = 12
        
        let customFont = UIFont.customFont(forTextStyle: .button1Medium)
        var attributedTitle = AttributedString(title)
        attributedTitle.font = customFont
        attributedTitle.foregroundColor = foregoundColor
        config.attributedTitle = attributedTitle
        
        self.configuration = config
        
        self.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
             
             // 텍스트 색상 및 배경색 업데이트
             var updatedAttributedTitle = AttributedString(title)
             updatedAttributedTitle.font = customFont
             
             if !button.isEnabled {
                 updatedAttributedTitle.foregroundColor = .placeholder // 비활성화 상태 텍스트 색상
             } else if button.isHighlighted {
                 updatedAttributedTitle.foregroundColor = foregoundColor // 강조 상태 텍스트 색상
                 updatedConfig?.background.backgroundColor = pressedColor // 강조 상태 배경색
             } else {
                 updatedAttributedTitle.foregroundColor = foregoundColor // 기본 텍스트 색상
                 updatedConfig?.background.backgroundColor = backGroundColor // 기본 배경색
             }
             
             updatedConfig?.attributedTitle = updatedAttributedTitle
             button.configuration = updatedConfig
         }
        
        // 버튼 텍스트가 벗어나지 않도록 설정
        self.titleLabel?.lineBreakMode = .byWordWrapping // 줄바꿈 허용
        self.titleLabel?.numberOfLines = 0 // 줄 수 무제한
        
        // 버튼의 크기를 텍스트와 이미지에 맞추도록 설정
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
