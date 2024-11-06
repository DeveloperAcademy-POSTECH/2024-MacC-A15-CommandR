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
        config.image = icon?.withRenderingMode(.automatic) // 아이콘 설정
        config.imagePlacement = .top // 이미지와 텍스트 위치
        config.imagePadding = 8 // 이미지와 텍스트 사이 간격
        config.baseForegroundColor = foregoundColor // 텍스트 및 이미지 색상
        config.background.backgroundColor = backGroundColor // 배경색 설정
        config.background.strokeColor = strokeColor // 테두리 색상 설정
        config.background.strokeWidth = 1.5
        config.background.cornerRadius = 12
        
        if let customFont = UIFont(name: "Pretendard-Medium", size: 18) {
            var attributedTitle = AttributedString(title)
            attributedTitle.font = customFont
            config.attributedTitle = attributedTitle
        }
        
        self.configuration = config
        
        self.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            updatedConfig?.background.backgroundColor = button.isHighlighted ? pressedColor : backGroundColor
            button.configuration = updatedConfig
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
