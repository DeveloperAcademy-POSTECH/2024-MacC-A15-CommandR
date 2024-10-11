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

        playMIDIFileButton.isEnabled = false
        playMIDIFileButton.addTarget(self, action: #selector(playMIDIFile), for: .touchUpInside)
        
        // combine으로 계속 값 업데이트
        musicPlayer.$currentTime.sink { [weak self] time in
            self?.currentTimeLabel.text = "Current Time: \(time)"
        }.store(in: &cancellables)
    }
    
    @objc private func playMusicXML() {
        if isPlayingMusicXML {
            musicPlayer.pauseWav()
        } else {
            guard let outputPathURL = midiFilePathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
                musicPlayer.loadAudioFile(url: outputPathURL)
                musicPlayer.playWav()
            } else {
                ErrorHandler.handleError(errorMessage: "Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMusicXML.toggle()
    }
    
    @objc private func playMIDIFile() {
        if isPlayingMIDIFile {
            musicPlayer.resumeMIDI()
        } else {
            guard let outputPathURL = midiFilePathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
                musicPlayer.playMIDI()
            } else {
                ErrorHandler.handleError(errorMessage: "Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMIDIFile.toggle()
    }
    
    private func generateMusicXMLAudio() {
        // MusicXML 파일 로드
        guard let xmlPath = Bundle.main.url(forResource: "MahlFaGe4Sample", withExtension: "musicxml") else {
            ErrorHandler.handleError(errorMessage: "Failed to find MusicXML file in bundle.")
            return
        }

        Task {
            do {
                let xmlData = try Data(contentsOf: xmlPath)
                print("Successfully loaded MusicXML data.")
                
                // MediaManager 인스턴스 생성
                let mediaManager = MediaManager()
                
                // WAV 파일 및 MIDI 파일을 각각 동기적으로 생성
                wavFilePathURL = try await mediaManager.getMediaFile(xmlData: xmlData)
                if let wavFilePathURL = wavFilePathURL {
                    playMusicXMLButton.isEnabled = true
                    print("WAV file created successfully: \(wavFilePathURL)")
                } else {
                    ErrorHandler.handleError(errorMessage: "wav file URL is nil.")
                }

                midiFilePathURL = try await mediaManager.getMIDIFile(xmlData: xmlData)
                if let midiFilePathURL = midiFilePathURL {
                    musicPlayer.setMIDIFile(midiURL: midiFilePathURL)
                    playMIDIFileButton.isEnabled = true
                    print("MIDI file created successfully: \(midiFilePathURL)")
                } else {
                    ErrorHandler.handleError(errorMessage: " MIDI file URL is nil.")
                }

            } catch {
                ErrorHandler.handleError(error: error)
            }
        }
    }
}
