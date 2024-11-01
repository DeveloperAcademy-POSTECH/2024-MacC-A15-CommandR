//
//  MusicPlayer.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AVFoundation

// MusicPlayer: AVPlayer를 사용하여 오디오 파일을 재생 및 제어하는 클래스
class MusicPlayer: ObservableObject {
    @Published var currentTime: TimeInterval = 0
    @Published var isEnd: Bool = false
    
    private var player: AVAudioPlayer?
    private var midiPlayer: AVMIDIPlayer? // MIDI 재생 플레이어
    private var timer: Timer?
    private var lastPosition: TimeInterval = 0 // 일시정지용
    var musicSequence: MusicSequence?
    private var soundFont: String = "Piano"
    private var soundSettingObserver: Any?
    private var totalDuration = 0.0 // MIDI파일 총 시간
    
    // Store MIDI file URL separately
    private var midiFileURL: URL?
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            ErrorHandler.handleError(error: error)
        }
        
        // soundSetting의 변화를 감지하여 soundFont 변수를 업데이트함
        soundSettingObserver = NotificationCenter.default.addObserver(
            forName: .soundSettingDidChange,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateSoundFont()
        }
        
        updateSoundFont()
    }
    
    // soundFont 변수를 현재의 soundSetting값을 반영하여 업데이트하기
    private func updateSoundFont() {
        switch UserSettingData.shared.soundSetting {
        case .melody:
            soundFont = "Piano"
        case .beat:
            soundFont = "Drum Set JD Rockset 5"
        default:
            soundFont = "Piano"
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
            ErrorHandler.handleError(error: error)
        }
    }
    
    // wav 재생
    func playWav() {
        print("Playing audio...")
        player?.play()
        startTimer()
        print("Playing audio, duration: \(player?.duration ?? 0) seconds")
        print("Current time: \(player?.currentTime ?? 0 )")
    }
    
    // wav 일시정지
    func pauseWav() {
        print("Pausing audio...")
        player?.pause()
        stopTimer()
    }
    
    // 미디파일 총 시간
    func getTotalDuration() -> Double {
        return totalDuration
    }
    
    // MARK: - MIDI 파일 관리
    func loadMIDIFile(midiURL: URL?) {
        // 필요할 때 다시 꺼내 쓸 수 있도록 midiURL 저장
        self.midiFileURL = midiURL
        
        // MusicSequence 생성
        NewMusicSequence(&musicSequence)
        
        guard let midiURL else { return }
        if let musicSequence = musicSequence {
            // MIDI 파일을 시퀀스로 로드
            let status = MusicSequenceFileLoad(musicSequence, midiURL as CFURL, .midiType, MusicSequenceLoadFlags())
            
            if status == noErr {
                print("MIDI file successfully loaded into MusicSequence.")
            } else {
                ErrorHandler.handleError(error: "Error loading MIDI file: \(status)")
            }
        }
        
        // AVMIDIPlayer 초기화
        do {
            
            let bankURL = Bundle.main.url(forResource: soundFont, withExtension: "sf2")! // 사운드 폰트 파일 경로
            
            midiPlayer = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: bankURL)
            
            if let midiPlayer {
                midiPlayer.prepareToPlay()
                totalDuration = midiPlayer.duration
            }
  
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
    
    // MIDI 파일 실행
    func playMIDI(startTime: TimeInterval = 0, delay: TimeInterval) {
        if let midiPlayer = midiPlayer {
            print("MIDI 시작")
            stopTimer()
            if startTime == 0, lastPosition != 0 {
                // 이전에 일시 정지된 위치에서 재개
                midiPlayer.currentPosition = lastPosition
                lastPosition = 0
            } else {
                // 시작 틱 위치
                midiPlayer.currentPosition = startTime
            }
            isEnd = false
            // 재생 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                midiPlayer.play {
                    print("MIDI playback completed.")
                    self.isEnd = true
                }
                self.startTimer()
            }
        }
    }
    
    // MIDI 파일 일시 정지
    func pauseMIDI() {
        guard let midiPlayer = midiPlayer else { return }
        
        // 현재 재생 시간을 저장
        lastPosition = midiPlayer.currentPosition
        midiPlayer.stop()
        print("MIDI playback paused at \(lastPosition) seconds.")
    }
    
    // MIDI 파일 재개
    func resumeMIDI() {
        guard let midiPlayer = midiPlayer else { return }
        
        // 저장된 위치에서 다시 재생
        midiPlayer.currentPosition = lastPosition
        midiPlayer.play()
        print("MIDI playback resumed from \(lastPosition) seconds.")
    }
    
    // MIDI 파일 처음으로 셋팅
    func stopMIDI() {
        guard let midiPlayer = midiPlayer else { return }

        // 처음으로
        midiPlayer.stop()
        midiPlayer.currentPosition = 0
        stopTimer()
    }
    
    // 타이머 시작
    private func startTimer() {
        stopTimer() // 기존 타이머가 있으면 중지
        // MIDI Player 현재 위치 업데이트
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.midiPlayer?.currentPosition ?? 0.0
        }
    }
    
    // 타이머 중지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        if let observer = soundSettingObserver {
                   NotificationCenter.default.removeObserver(observer)
               }
        stopTimer()
    }
}
