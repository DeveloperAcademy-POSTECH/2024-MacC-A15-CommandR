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
    private var pickerView: UIPickerView!
    private let musicPlayer = MusicPlayer()
    private var isPlayingMusicXML = false
    private var wavFilePathURL: URL?
    private var midiFilePathURL: URL?
    private var cancellables = Set<AnyCancellable>()
    private var isPlayingMIDIFile = false
    private var currentBPM = 100 // bpm 조절 설정
    private var currenrScore: Score? // 현재 악보 score
    private var selectedPart: Part? // 픽커에서 선택된 파트
    
    // UI
    private let titleLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let playMusicXMLButton = UIButton(type: .system)
    private let playMIDIFileButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIPickerView 설정
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pickerView)
        
        // UIPickerView 레이아웃 설정
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
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
        guard let outputPathURL = midiFilePathURL else {
            ErrorHandler.handleError(errorMessage: "MIDI file URL is nil.")
            return
        }
        
        // MIDI 파일이 존재하는지 확인
        if !FileManager.default.fileExists(atPath: outputPathURL.path) {
            ErrorHandler.handleError(errorMessage: "MIDI file not found at path \(outputPathURL.path)")
            return
        }
        
        // MIDI 파일 재생 여부에 따른 처리
        if isPlayingMIDIFile {
            musicPlayer.pauseMIDI() // 일시정지
        } else {
            print("Playing MIDI file from start...")
            musicPlayer.playMIDI() // 처음부터 재생
        }
        
        // 재생 상태 토글
        isPlayingMIDIFile.toggle()
    }
    
    private func updateScore(score: Score) {
        currenrScore = score
        pickerView.reloadAllComponents() // 데이터를 받아오면 Picker 업데이트
    }
    
    private func generateMusicXMLAudio() {
        // MusicXML 파일 로드
        guard let xmlPath = Bundle.main.url(forResource: "moon", withExtension: "xml") else {
            ErrorHandler.handleError(errorMessage: "Failed to find MusicXML file in bundle.")
            return
        }
        
        Task {
            do {
                let xmlData = try Data(contentsOf: xmlPath)
                print("Successfully loaded MusicXML data.")
                let parser = MusicXMLParser()
                let score = await parser.parseMusicXML(from: xmlData)

                updateScore(score: score)
                await createMIDIFile(score: score)
                
            } catch {
                ErrorHandler.handleError(error: error)
            }
        }
    }
    
    func createMIDIFile(score: Score) async {
        let mediaManager = MediaManager()
        
        do {
            // 버튼 값 초기화
            playMIDIFileButton.isEnabled = false
            // MIDI 파일을 동기적으로 생성
            midiFilePathURL = try await mediaManager.getMIDIFile(parsedScore: score)
            
            // MIDI 파일 URL 확인 및 파일 로드
            if let midiFilePathURL = midiFilePathURL {
                print("MIDI file created successfully: \(midiFilePathURL)")
                // MIDI 파일 로드
                musicPlayer.loadMIDIFile(midiURL: midiFilePathURL)
                playMIDIFileButton.isEnabled = true
                print("MIDI file successfully loaded and ready to play.")
            } else {
                ErrorHandler.handleError(errorMessage: "MIDI file URL is nil.")
            }
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
}

extension LoadingViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    // UIPickerViewDataSource 프로토콜
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // UIPickerView의 열 수
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let currenrScore else { return 0 }
        
        return currenrScore.parts.count + 1// parts의 갯수만큼 행을 설정
    }
    
    // UIPickerViewDelegate 프로토콜
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let currenrScore else { return "" }
        
        if row == 0 { return "전체" }
        return currenrScore.parts[row - 1].id // 각 파트의 이름을 보여줌
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 선택된 파트에 대한 처리
        guard let currenrScore else { return }
        
        if row == 0 {
            print("All Parts selected")
            // "All Parts" 선택 시 처리할 로직
        } else {
            selectedPart = currenrScore.parts[row - 1]
            print("Selected part: \(selectedPart?.id ?? "인식실패")")
        }
    }
}
