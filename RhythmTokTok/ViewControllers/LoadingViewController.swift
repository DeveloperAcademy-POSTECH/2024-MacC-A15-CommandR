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

    //UI
    private let titleLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let playMusicXMLButton = UIButton(type: .system)
    
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
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            currentTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            playMusicXMLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playMusicXMLButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        playMusicXMLButton.isEnabled = false
        playMusicXMLButton.addTarget(self, action: #selector(playMusicXML), for: .touchUpInside)
        
        // combine으로 계속 값 업데이트
        musicPlayer.$currentTime.sink { [weak self] time in
            self?.currentTimeLabel.text = "Current Time: \(time)"
        }.store(in: &cancellables)
    }
    
    @objc private func playMusicXML() {
        if isPlayingMusicXML {
            musicPlayer.pause()
        } else {
            guard let outputPathURL = wavFilePathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
//                musicPlayer.loadAudioFile(url: outputPathURL)
//                musicPlayer.play()
                playMIDIFile(midiURL: midiFilePathURL!)
            } else {
                ErrorHandler.handleError(errorMessage: "Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMusicXML.toggle()
    }
    
    private func generateMusicXMLAudio() {
        // MusicXML file 로드
        guard let xmlPath = Bundle.main.url(forResource: "MahlFaGe4Sample", withExtension: "musicxml") else {
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
            let bankURL = Bundle.main.url(forResource: "Scc1", withExtension: "sf2")! // 사운드 폰트 파일 경로
            
            midiPlayer = try AVMIDIPlayer(contentsOf: midiURL, soundBankURL: bankURL)
            midiPlayer?.prepareToPlay()
            //bpm
            midiPlayer?.rate = Float(2.5)

            midiPlayer?.play()
            
            print("MIDI file is playing.")
        } catch {
            print("Error [LoadingViewController]: Failed to play MIDI file: \(error.localizedDescription)")
        }
    }
}
