//
//  MusicPracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeViewController: UIViewController {
    
    override func loadView() {
        self.view =  MusicPracticeView()  // CustomView로 뷰 설정
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let  musicPracticeView = self.view as?  MusicPracticeView {
            musicPracticeView.titleLabel.text = "MoonRiver" // TODO: 여기에 제목 연결
            musicPracticeView.pageLabel.text = "0/0장" // TODO: 여기에 페이지 내용 만들 함수 연결
        }
    }
}
