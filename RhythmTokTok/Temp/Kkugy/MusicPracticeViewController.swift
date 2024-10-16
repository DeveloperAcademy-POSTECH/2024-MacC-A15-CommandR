//
//  MusicPracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeViewController: UIViewController {
    let practicNavBar = PracticeNavigationBar()
    let musicPracticeTitleView = MusicPracticeTitleView()
    let tableView = UITableView()
    // TODO: 여기에 줄 진행 정도 비율 계산 로직 연결 필요
    let progressData: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 0.4]
    // Divider 역할을 할 선
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let playPauseButton = PlayPauseButton(frame: CGRect(x: 0, y: 0, width: 160, height: 80))
    let stopButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = UIImage(systemName: "stop.fill", withConfiguration: configuration)
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray08
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    // 악보 관리용
    private var midiFilePathURL: URL?
    private var isPlayingMIDIFile = false
    private let musicPlayer = MusicPlayer()
    // TODO: 나중에 여기로 score값 연결
    var currenrScore: Score? // 현재 악보 score

    override func loadView() {
        // 루트 뷰를 설정할 컨테이너 뷰 생성
        let containerView = UIView()
        containerView.backgroundColor = .white
        // 커스텀 네비게이션 바 추가
        containerView.addSubview(practicNavBar)
        practicNavBar.translatesAutoresizingMaskIntoConstraints = false
        // MusicPracticeView 추가
        containerView.addSubview(musicPracticeTitleView)
        musicPracticeTitleView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(divider) // divider

        // 루트 뷰 설정
        self.view = containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateMusicXMLAudio()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        // 테이블 뷰 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProgressButtonTableViewCell.self, forCellReuseIdentifier: "ProgressButtonCell")
        view.addSubview(tableView)
        tableView.separatorStyle = .none // 구분선 없애기
        // TODO: 여기에 제목 연결
        musicPracticeTitleView.titleLabel.text = "MoonRiver"
        // TODO: 여기에 페이지 내용 만들 함수 연결
        musicPracticeTitleView.pageLabel.text = "0/0장"
        
        // 버튼을 뷰에 추가
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playPauseButton)
        // resume 버튼 추가
        view.addSubview(stopButton)
    }
    
    private func setupConstraints() {
        // 커스텀 네비게이션 바와 MusicPracticeView 레이아웃 설정
        NSLayoutConstraint.activate([
            // 커스텀 네비게이션 바 레이아웃 설정
            practicNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practicNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practicNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practicNavBar.heightAnchor.constraint(equalToConstant: 60),
            
            // MusicPracticeView 레이아웃 설정 (네비게이션 바 아래에 위치)
            musicPracticeTitleView.topAnchor.constraint(equalTo: practicNavBar.bottomAnchor, constant: 10),
            musicPracticeTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            musicPracticeTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            musicPracticeTitleView.heightAnchor.constraint(equalToConstant: 30),

            // divider
            divider.topAnchor.constraint(equalTo: musicPracticeTitleView.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 좌우 패딩 없이 전체 너비
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            // 테이블뷰
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: divider.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 플레이버튼
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20),
            playPauseButton.heightAnchor.constraint(equalToConstant: 80),
            playPauseButton.widthAnchor.constraint(equalToConstant: 160),
            
            // 정지버튼
            stopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20),
            stopButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),
            stopButton.heightAnchor.constraint(equalToConstant: 80),
            stopButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupActions() {
        // 클릭 시 이벤트 설정
        playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Button 액션
    @objc private func playButtonTapped() {
        guard let outputPathURL = midiFilePathURL else {
            ErrorHandler.handleError(error: "MIDI file URL is nil.")
            return
        }
        
        // MIDI 파일이 존재하는지 확인
        if !FileManager.default.fileExists(atPath: outputPathURL.path) {
            ErrorHandler.handleError(error: "MIDI file not found at path \(outputPathURL.path)")
            return
        }
        // MIDI 파일 재생 여부에 따른 처리
        if playPauseButton.isPlaying {
            // 재생 중일 때 일시정지
            sendPauseStatusToWatch()
            // MIDI 일시정지
            musicPlayer.pauseMIDI()
        } else {
            // 현재 시간으로부터 4초 후, 평균 워치지연시간 0.14
            let futureTime = Date().addingTimeInterval(4).timeIntervalSince1970
            // 워치로 play 예약 메시지 전송
            sendPlayStatusToWatch(startTimeInterVal: futureTime)
            
            let delay = futureTime - Date().timeIntervalSince1970
            // 예약 시간에 재생
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // MIDI 재생
                self.musicPlayer.playMIDI()
            }
            stopButton.isHidden = false
        }
        playPauseButton.isPlaying.toggle() // 재생/일시정지 상태 변경
    }
    
    @objc private func stopButtonTapped() {
        sendStopStatusToWatch()
        musicPlayer.stopMIDI()
        playPauseButton.isPlaying = false
        stopButton.isHidden = true
    }

    // MARK: MIDI 파일, 햅틱 시퀀스 관리
    // 테스트를 위해 임시 변환 여기서 실행
    private func generateMusicXMLAudio() {
        // MusicXML 파일 로드
        guard let xmlPath = Bundle.main.url(forResource: "moon", withExtension: "xml") else {
            ErrorHandler.handleError(error: "Failed to find MusicXML file in bundle.")
            return
        }
        // 시작 버튼 비활성화
        playPauseButton.isEnabled = false
        
        Task {
            do {
                let xmlData = try Data(contentsOf: xmlPath)
                print("Successfully loaded MusicXML data.")
                let parser = MusicXMLParser()
                let score = await parser.parseMusicXML(from: xmlData)

                currenrScore = score
                await createMIDIFile(score: score)
                
            } catch {
                ErrorHandler.handleError(error: error)
            }
        }
    }
    
    private func createMIDIFile(score: Score) async {
        let mediaManager = MediaManager()
        
        do {
            // MIDI File URL 초기화
            midiFilePathURL = nil
            // TODO: 사용할 파트 어떻게 정할지 구상 필요
            midiFilePathURL = try await mediaManager.getPartMIDIFile(part: score.parts.last!,
                                                                         divisions: score.divisions,
                                                                     isChordEnabled: false)
            // MIDI 파일 URL 확인 및 파일 로드
            if let midiFilePathURL = midiFilePathURL {
                print("MIDI file created successfully: \(midiFilePathURL)")
                // 햅틱 시퀀스 관리
                let hapticSequence = try await mediaManager.getHapticSequence(part: score.parts.last!,
                                  divisions: score.divisions)
                // 워치로 곡 선택 메시지 전송
                sendHapticSequenceToWatch(hapticSequence: hapticSequence)
                // MIDI 파일 로드
                musicPlayer.loadMIDIFile(midiURL: midiFilePathURL)
                playPauseButton.isEnabled = true
                print("MIDI file successfully loaded and ready to play.")
            } else {
                ErrorHandler.handleError(error: "MIDI file URL is nil.")
            }
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
    
    // MARK: 워치 통신 부분
    // 워치로 곡 선택 메시지 전송
    func sendHapticSequenceToWatch(hapticSequence: [Double]) {
        // 임시 송 타이틀
        // TODO: score안의 타이틀 값 연결해줘야됨
        let songTitle = "Moon River - Kkugy"
        
        WatchManager.shared.sendSongSelectionToWatch(songTitle: songTitle, hapticSequence: hapticSequence)
    }
    
    // 워치로 실행 예약 메시지 전송
    func sendPlayStatusToWatch(startTimeInterVal: TimeInterval) {
        WatchManager.shared.sendPlayStatusToWatch(status: "play", startTime: startTimeInterVal)
    }
    
    // 워치로 일시정지 예약 메시지 전송
    func sendPauseStatusToWatch() {
        WatchManager.shared.sendPlayStatusToWatch(status: "pause", startTime: 0)
    }
    
    // 워치로 멈추고 처음으로 대기 메시지 전송
    func sendStopStatusToWatch() {
        WatchManager.shared.sendPlayStatusToWatch(status: "stop", startTime: 0)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MusicPracticeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressButtonCell", for: indexPath) as! ProgressButtonTableViewCell
        let progress = progressData[indexPath.row]
        cell.configure(progress: progress)
        // TODO: 장 줄 네임 연결
        cell.setTitle(buttonName: "\(indexPath.row)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Progress button at row \(indexPath.row) clicked")
        // TODO: 여기에 버튼 클릭 시 해당 줄부터 연주되게 만들기
    }
}
