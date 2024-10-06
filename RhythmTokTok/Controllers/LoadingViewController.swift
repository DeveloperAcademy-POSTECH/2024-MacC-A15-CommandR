//
//  LoadingViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import Combine
import UIKit

class LoadingViewController: UIViewController {
    private let musicPlayer = MusicPlayer()
    private var isPlayingMusicXML = false
    private var outputPathURL: URL?
    private var cancellables = Set<AnyCancellable>()
    
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
            guard let outputPathURL = outputPathURL else { return }
            if FileManager.default.fileExists(atPath: outputPathURL.path) {
                musicPlayer.loadAudioFile(url: outputPathURL)
                musicPlayer.play()
            } else {
                print("Error: Audio file not found at path \(outputPathURL.path)")
            }
        }
        isPlayingMusicXML.toggle()
    }
    
    private func generateMusicXMLAudio() {
        // MusicXML file 로드
        guard let xmlPath = Bundle.main.url(forResource: "MahlFaGe4Sample", withExtension: "musicxml") else {
            print("Error: Failed to find MusicXML file in bundle.")
            return
        }

        Task {
            do {
                let xmlData = try Data(contentsOf: xmlPath)
                print("Successfully loaded MusicXML data.")
                // 미디어 파일 만들기
                let mediaMannager = MediaMannager()
                outputPathURL = try await mediaMannager.getMediaFile(xmlData: xmlData)
                print("Completed. Media file path: \(outputPathURL?.path ?? "No file created")")
                playMusicXMLButton.isEnabled = true
                
            } catch {
                print("Error loading MusicXML data: \(error.localizedDescription)")
            }
        }
    }
}
