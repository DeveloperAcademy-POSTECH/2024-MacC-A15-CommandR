//
//  MusicPlayer.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation

// MusicPlayer: AVPlayer를 사용하여 오디오 파일을 재생 및 제어하는 클래스
class MusicPlayer: ObservableObject {
    @Published var currentTime: TimeInterval = 0.0
    private var player: AVAudioPlayer?
    private var timer: Timer?

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error [MusicPlayer]: Failed to set AVAudioSession: \(error)")
        }
    }
    
    // 오디오 파일 로드
    func loadAudioFile(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 5.0
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            print("Audio player initialized successfully.")
        } catch {
            print("Error [MusicPlayer]: loading audio file: \(error)")
        }
    }
    
    // 재생
    func play() {
        print("Playing audio...")
        player?.play()
        startTimer()
        print("Playing audio, duration: \(player?.duration ?? 0) seconds")
        print("Current time: \(player?.currentTime ?? 0 )")
    }
    
    // 일시정지
    func pause() {
        print("Pausing audio...")
        player?.pause()
        stopTimer()
    }
    
    // 타이머 시작
    private func startTimer() {
        stopTimer() // 기존 타이머가 있으면 중지
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.player?.currentTime ?? 0
        }
    }
    
    // 타이머 중지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}
