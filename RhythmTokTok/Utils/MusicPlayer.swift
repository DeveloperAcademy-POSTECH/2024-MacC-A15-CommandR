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
    private var midiPlayer: AVMIDIPlayer? // MIDI 재생 플레이어
    private var timer: Timer?
    private var lastPosition: TimeInterval = 0
    var musicSequence: MusicSequence?


    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            ErrorHandler.handleError(error: error)
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
    
    ///MARK: - MIDI 파일 관리
    func loadMIDIFile(midiURL: URL?) {
//        do {
//            let bankURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2")! // 사운드 폰트 파일 경로
//            
//            guard let midiURL else { return }
//            midiPlayer = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: bankURL)
//            midiPlayer?.prepareToPlay()
//        } catch {
//            ErrorHandler.handleError(errorMessage: "Failed to set MIDI file: \(error.localizedDescription)")
//        }
        // MusicSequence 생성
        NewMusicSequence(&musicSequence)
        
        guard let midiURL else { return }
        if let musicSequence = musicSequence {
            // MIDI 파일을 시퀀스로 로드
            let status = MusicSequenceFileLoad(musicSequence, midiURL as CFURL, .midiType, MusicSequenceLoadFlags())
            
            if status == noErr {
                print("MIDI file successfully loaded into MusicSequence.")
            } else {
                print("Error loading MIDI file: \(status)")
            }
        }
        
        // AVMIDIPlayer 초기화
        do {
            let bankURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2")! // 사운드 폰트 파일 경로

            midiPlayer = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: bankURL)
            midiPlayer?.prepareToPlay()
        } catch {
            print("Error initializing AVMIDIPlayer: \(error.localizedDescription)")
        }
    }
    
    // 템포 변경을 위한 메서드
    func setMIDITempo(_ bpm: Double) {
        guard let musicSequence = musicSequence else { return }
        
        var tempoTrack: MusicTrack?
        
        // 시퀀스의 템포 트랙 가져오기
        MusicSequenceGetTempoTrack(musicSequence, &tempoTrack)
        
        if let tempoTrack = tempoTrack {
            // 템포 이벤트 추가 (시간 0부터 템포를 변경)
            let secondsPerQuarterNote = 60.0 / bpm
            let startTime: MusicTimeStamp = 0
            let endTime: MusicTimeStamp = 1_000_000 // 매우 큰 값으로 트랙의 끝까지 커버
            
            MusicTrackClear(tempoTrack, startTime, endTime)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, secondsPerQuarterNote)
        }
    }
    
    // MIDI 파일 실행
    func playMIDI() {
        // BPM 조정
//        midiPlayer?.rate = Float(2)
        if let midiPlayer = midiPlayer {
//            setMIDITempo(120)
            // 이전에 일시 정지된 위치에서 재개
            midiPlayer.rate = 1.0
            midiPlayer.currentPosition = lastPosition
            // 재생 시작
            midiPlayer.play {
                print("MIDI playback completed.")
            }
            print("MIDI file is playing at BPM.")
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
