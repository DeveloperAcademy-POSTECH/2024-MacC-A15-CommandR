//
//  Fonts.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/18/24.
//

import Foundation
import UIKit
enum CustomFontStyle: String {
    case displayMedium
    case titleBold
    case heading1Bold
    case heading1Medium
    case heading1Regular
    case heading2Bold
    case heading2Medium
    case heading2Regular
    case subheadingBold
    case subheadingMedium
    case subheadingRegular
    case body1Bold
    case body1Medium
    case body1Regular
    case body2Bold
    case body2Medium
    case body2Regular
    case captionMedium
    case captionRegular
    case button1Medium
    case button2Medium
    case watchDisplayMedium
    case watchSubheadingMedium
    case watchBodyMedium
}

let customFontDict: [CustomFontStyle: UIFont] = [
    .displayMedium: UIFont(name: "Pretendard-Medium", size: 36)!,
    .titleBold: UIFont(name: "Pretendard-Bold", size: 28)!,
    .heading1Bold: UIFont(name: "Pretendard-Bold", size: 24)!,
    .heading1Medium: UIFont(name: "Pretendard-Medium", size: 24)!,
    .heading1Regular: UIFont(name: "Pretendard-Regular", size: 24)!,
    .heading2Bold: UIFont(name: "Pretendard-Bold", size: 21)!,
    .heading2Medium: UIFont(name: "Pretendard-Medium", size: 21)!,
    .heading2Regular: UIFont(name: "Pretendard-Regular", size: 21)!,
    .subheadingBold: UIFont(name: "Pretendard-Bold", size: 18)!,
    .subheadingMedium: UIFont(name: "Pretendard-Medium", size: 18)!,
    .subheadingRegular: UIFont(name: "Pretendard-Regular", size: 18)!,
    .body1Bold: UIFont(name: "Pretendard-Bold", size: 18)!,
    .body1Medium: UIFont(name: "Pretendard-Medium", size: 18)!,
    .body1Regular: UIFont(name: "Pretendard-Regular", size: 18)!,
    .body2Bold: UIFont(name: "Pretendard-Bold", size: 16)!,
    .body2Medium: UIFont(name: "Pretendard-Medium", size: 16)!,
    .body2Regular: UIFont(name: "Pretendard-Regular", size: 16)!,
    .captionMedium: UIFont(name: "Pretendard-Medium", size: 14)!,
    .captionRegular: UIFont(name: "Pretendard-Regular", size: 14)!,
    .button1Medium: UIFont(name: "Pretendard-Medium", size: 18)!,
    .button2Medium: UIFont(name: "Pretendard-Medium", size: 16)!,
    .watchDisplayMedium: UIFont(name: "Pretendard-Medium", size: 64)!,
    .watchSubheadingMedium: UIFont(name: "Pretendard-Medium", size: 16)!,
    .watchBodyMedium: UIFont(name: "Pretendard-Medium", size: 16)!,
]

let textStyleDict: [CustomFontStyle: UIFont.TextStyle] = [
    .displayMedium: .largeTitle,
    .titleBold: .title1,
    .heading1Bold: .title2,
    .heading1Medium: .title2,
    .heading1Regular: .title2,
    .heading2Bold: .title3,
    .heading2Medium: .title3,
    .heading2Regular: .title3,
    .subheadingBold: .headline,
    .subheadingMedium: .headline,
    .subheadingRegular: .headline,
    .body1Bold: .body,
    .body1Medium: .body,
    .body1Regular: .body,
    .body2Bold: .callout,
    .body2Medium: .callout,
    .body2Regular: .callout,
    .captionMedium: .caption1,
    .captionRegular: .caption1,
    .button1Medium: .body,
    .button2Medium: .subheadline,
    .watchDisplayMedium: .largeTitle,
    .watchSubheadingMedium: .headline,
    .watchBodyMedium: .body,
]

extension UIFont {
    class func customFont(forTextStyle style: CustomFontStyle) -> UIFont {
        if let customFont = customFontDict[style] {
            let metrics = UIFontMetrics(forTextStyle: textStyleDict[style, default: .body])
            let scaledFont = metrics.scaledFont(for: customFont)
            return scaledFont
        } else {
            return UIFont.preferredFont(forTextStyle: .body)
        }
    }
}
