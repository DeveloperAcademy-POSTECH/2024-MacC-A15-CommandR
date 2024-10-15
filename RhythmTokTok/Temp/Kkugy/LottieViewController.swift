//
//  LottieViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/14/24.
//

import UIKit
import Lottie

class LottieViewController: UIViewController {
    
    var animationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경색 설정 (선택 사항)
        view.backgroundColor = .white
        
        // Lottie 애니메이션 뷰 설정
        animationView = LottieAnimationView(name: "change") // animationFile은 Lottie JSON 파일명
        
        guard let animationView = animationView else { return }
        
        // 애니메이션 뷰 크기 및 위치 설정
        animationView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        animationView.center = view.center
        
        // 애니메이션 재생 옵션 설정
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop // 반복 재생 설정
        animationView.animationSpeed = 1.0 // 재생 속도
        
        // 애니메이션 뷰를 메인 뷰에 추가
        view.addSubview(animationView)
        
        // 애니메이션 재생 시작
        animationView.play()
    }
}
