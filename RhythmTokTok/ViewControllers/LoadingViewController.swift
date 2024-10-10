//
//  LoadingViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import Combine
import UIKit
import AVFAudio

class LoadingViewController: UIViewController {
    private let musicPlayer = MusicPlayer()
    private var isPlayingMusicXML = false
    private var wavFilePathURL: URL?
    private var midiFilePathURL: URL?
    private var cancellables = Set<AnyCancellable>()
    private var midiPlayer: AVMIDIPlayer? // MIDI 재생 플레이어
    private var lastPosition: TimeInterval = 0
    private var isPlayingMIDIFile = false
    private var currentBPM = 120 // bpm 조절 설정

    //UI
    private let titleLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let playMusicXMLButton = UIButton(type: .system)
    private let playMIDIFileButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        generateMusicXMLAudio()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        titleLabel.text = "MusicXML Player"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        currentTimeLabel.text = "Current Time: 0.0"
        currentTimeLabel.font = UIFont.systemFont(ofSize: 18)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentTimeLabel)
        
        playMusicXMLButton.setTitle("Play MusicXML", for: .normal)
        playMusicXMLButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        playMusicXMLButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playMusicXMLButton)
        
        playMIDIFileButton.setTitle("Play MIDI", for: .normal)
        playMIDIFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        playMIDIFileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playMIDIFileButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            currentTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            playMusicXMLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playMusicXMLButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 20),
            
            playMIDIFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playMIDIFileButton.topAnchor.constraint(equalTo: playMusicXMLButton.bottomAnchor, constant: 40)
        ])
    }
    
    private func setupActions() {
        playMusicXMLButton.isEnabled = false
        playMusicXMLButton.addTarget(self, action: #selector(playMusicXML), for: .touchUpInside)
        
        playMIDIFileButton.addTarget(self, action: #selector(playMIDIFIle), for: .touchUpInside)
        
        // combine으로 계속 값 업데이트
        musicPlayer.$currentTime.sink { [weak self] time in
            self?.currentTimeLabel.text = "Current Time: \(time)"
        }.store(in: &cancellables)
    }
    
    @objc private func playMusicXML() {
        if isPlayingMusicXML {
            musicPlayer.pause()
        } else {
            guard let outputPathURL = midiFilePathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
                musicPlayer.loadAudioFile(url: outputPathURL)
                musicPlayer.play()
            } else {
                ErrorHandler.handleError(errorMessage: "Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMusicXML.toggle()
    }
    
    @objc private func playMIDIFIle() {
        if isPlayingMIDIFile {
            pauseMIDI()
        } else {
            guard let outputPathURL = wavFilePathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
                playMIDIFile(midiURL: midiFilePathURL!)
            } else {
                print("Error [LoadingViewController]: Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMIDIFile.toggle()
    }
    
    private func generateMusicXMLAudio() {
        // MusicXML file 로드
        guard let xmlPath = Bundle.main.url(forResource: "moon", withExtension: "xml") else {
            print("Error [LoadingViewController]: Failed to find MusicXML file in bundle.")
            return
        }

        Task {
            do {
                let xmlData = try Data(contentsOf: xmlPath)
                print("Successfully loaded MusicXML data.")
                // 미디어 파일 만들기
                let mediaManager = MediaManager()
                wavFilePathURL = try await mediaManager.getMediaFile(xmlData: xmlData)
                midiFilePathURL = try await mediaManager.getMIDIFile(xmlData: xmlData)
                print("Completed. Media file path: \(wavFilePathURL?.path ?? "No file created")")
                playMusicXMLButton.isEnabled = true
            } catch {
                ErrorHandler.handleError(error: error)
            }
        }
    }
    
    private func playMIDIFile(midiURL: URL) {
        do {
            let bankURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2")! // 사운드 폰트 파일 경로
            
            midiPlayer = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: bankURL)
            midiPlayer?.prepareToPlay()
            
            // BPM 조정
            midiPlayer?.rate = Float(2.5)
            
            // 이전에 일시 정지된 위치에서 재개
            midiPlayer?.currentPosition = lastPosition
            midiPlayer?.play()
            
            print("MIDI file is playing.")
        } catch {
            print("Error [LoadingViewController]: Failed to play MIDI file: \(error.localizedDescription)")
        }
    }

    // 일시 정지
    private func pauseMIDI() {
        guard let midiPlayer = midiPlayer else { return }
        
        // 현재 재생 시간을 저장
        lastPosition = midiPlayer.currentPosition
        midiPlayer.stop()
        
        print("MIDI playback paused at \(lastPosition) seconds.")
    }

    // 재개
    private func resumeMIDI() {
        guard let midiPlayer = midiPlayer else { return }
        
        // 저장된 위치에서 다시 재생
        midiPlayer.currentPosition = lastPosition
        midiPlayer.play()
        
        print("MIDI playback resumed from \(lastPosition) seconds.")
    }
}
