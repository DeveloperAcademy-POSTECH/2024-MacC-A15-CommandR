//
//  Fonts.swift
//  RhythmTokTok
//
//  Created by Lyosha's MacBook   on 11/18/24.
//

import Foundation
import UIKit

let fontDict: [UIFont.TextStyle: UIFont] = [
//    .largeTitle: UIFont(name: "Merriweather-Regular", size: 34)!,
//    .title1: UIFont(name: "Merriweather-Regular", size: 28)!,
    .title2: UIFont(name: "Pretendard-Bold", size: 24)!,
//    .title3: UIFont(name: "Merriweather-Regular", size: 20)!,
//    .headline: UIFont(name: "Merriweather-Bold", size: 17)!,
//    .body: UIFont(name: "Merriweather-Regular", size: 17)!,
//    .callout: UIFont(name: "Merriweather-Regular", size: 16)!,
//    .subheadline: UIFont(name: "Merriweather-Regular", size: 15)!,
//    .footnote: UIFont(name: "Merriweather-Regular", size: 13)!,
//    .caption1: UIFont(name: "Merriweather-Regular", size: 12)!,
//    .caption2: UIFont(name: "Merriweather-Regular", size: 11)!
]

extension UIFont {
    class func customFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        if let customFont = fontDict[style] {
            let metrics = UIFontMetrics(forTextStyle: style)
            let scaledFont = metrics.scaledFont(for: customFont)
            return scaledFont
        } else {
            return UIFont.preferredFont(forTextStyle: style)
        }
    }
}
