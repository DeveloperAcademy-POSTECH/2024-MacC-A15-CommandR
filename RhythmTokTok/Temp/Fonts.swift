//
//  Fonts.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/18/24.
//

import Foundation
import UIKit
enum CustomFontStyle: String {
    case displayBold
    case displayMedium
    case heading1Bold
    case heading2Bold
    case heading2Medium
    case heading3Bold
    case heading3Medium
    case subheadingBold
    case subheadingMedium
    case subheadingRegular
    case body1Bold
    case body1Medium
    case body1Regular
    case body2Bold
    case body2Medium
    case body2Regular
    case captionBold
    case captionMedium
    case captionRegular
}


let customFontDict: [CustomFontStyle: UIFont] = [
    .displayBold: UIFont(name: "Pretendard-Bold", size: 36)!,
    .displayMedium: UIFont(name: "Pretendard-Medium", size: 36)!,
    .heading1Bold: UIFont(name: "Pretendard-Bold", size: 32)!,
    .heading2Bold: UIFont(name: "Pretendard-Bold", size: 24)!,
    .heading2Medium: UIFont(name: "Pretendard-Medium", size: 24)!,
    .heading3Bold: UIFont(name: "Pretendard-Bold", size: 21)!,
    .heading3Medium: UIFont(name: "Pretendard-Medium", size: 21)!,
    .subheadingBold: UIFont(name: "Pretendard-Bold", size: 18)!,
    .subheadingMedium: UIFont(name: "Pretendard-Medium", size: 18)!,
    .subheadingRegular: UIFont(name: "Pretendard-Regular", size: 18)!,
    .body1Bold: UIFont(name: "Pretendard-Bold", size: 16)!,
    .body1Medium: UIFont(name: "Pretendard-Medium", size: 16)!,
    .body1Regular: UIFont(name: "Pretendard-Regular", size: 16)!,
    .body2Bold: UIFont(name: "Pretendard-Bold", size: 14)!,
    .body2Medium: UIFont(name: "Pretendard-Medium", size: 14)!,
    .body2Regular: UIFont(name: "Pretendard-Regular", size: 14)!,
    .captionBold: UIFont(name: "Pretendard-Bold", size: 12)!,
    .captionMedium: UIFont(name: "Pretendard-Medium", size: 12)!,
    .captionRegular: UIFont(name: "Pretendard-Regular", size: 12)!,
]

let textStyleDict: [CustomFontStyle: UIFont.TextStyle] = [
    .displayBold: .largeTitle,
    .displayMedium: .largeTitle,
    .heading1Bold: .title1,
    .heading2Bold: .title2,
    .heading2Medium: .title2,
    .heading3Bold: .title3,
    .heading3Medium: .title3,
    .subheadingBold: .headline,
    .subheadingMedium: .headline,
    .subheadingRegular: .headline,
    .body1Bold: .body,
    .body1Medium: .body,
    .body1Regular: .body,
    .body2Bold: .callout,
    .body2Medium: .callout,
    .body2Regular: .callout,
    .captionBold: .caption1,
    .captionMedium: .caption1,
    .captionRegular: .caption1,
]

extension UIFont {
    class func customFont(forTextStyle style: CustomFontStyle) -> UIFont {
        if let customFont = customFontDict[style] {
            let metrics = UIFontMetrics(forTextStyle: textStyleDict[style, default: .body])
            let scaledFont = metrics.scaledFont(for: customFont)
            return scaledFont
        } else {
            return UIFont.preferredFont(forTextStyle: textStyleDict[style, default: .body])
        }
    }
}
