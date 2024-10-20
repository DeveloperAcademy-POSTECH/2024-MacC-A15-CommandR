//
//  MusicPracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//

import UIKit

class MusicPracticeViewController: UIViewController {
    var currentScore: Score // 현재 악보 score

    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let mediaManager = MediaManager()
    let practicNavBar = PracticeNavigationBar()
    let musicPracticeTitleView = MusicPracticeTitleView()
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bpmButton = BPMButton()
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
    private var pickerView: UIPickerView! // 임시 확인용 픽커
    private var startMeasureNumber: Int = 0
    private var endMeasureNumber: Int = 0

    // 악보 관리용
    private var midiFilePathURL: URL?
    private var isPlayingMIDIFile = false
    private let musicPlayer = MusicPlayer()

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동할 때 네비게이션 바를 다시 표시하도록 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        generateMusicXMLAudio()
        Task {
            await createMIDIFile(score: currentScore)
        }
        setupUI()
        setupConstraints()
        setupActions()
        updateWatchAppStatus()
    }
    
    private func setupUI() {
        musicPracticeTitleView.titleLabel.text = currentScore.title
        // TODO: 여기에 페이지 내용 만들 함수 연결
        musicPracticeTitleView.pageLabel.text = "0/0장"
        bpmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bpmButton)
        // 임시 픽커
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        
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
            
            // BPM 버튼
            bpmButton.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            bpmButton.heightAnchor.constraint(equalToConstant: 48),
            bpmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: bpmButton.bottomAnchor, constant: 20),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200),

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
        practicNavBar.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        bpmButton.addTarget(self, action: #selector(presentBPMModal), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
    }
    
    // 워치 앱 상태 업데이트 메서드
    @objc func updateWatchAppStatus() {
        Task {
            let isLaunched = await WatchManager.shared.launchWatch()

            if isLaunched {
                let isWatchAppReachable = WatchManager.shared.isWatchAppReachable
                DispatchQueue.main.async {
                    if isWatchAppReachable {
                        self.practicNavBar.setWatchImage(isConnected: true)
                    } else {
                        self.practicNavBar.setWatchImage(isConnected: false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    // 워치 런칭 실패 시 처리
                    ErrorHandler.handleError(error: "Failed to launch the Watch app.")
                    self.practicNavBar.setWatchImage(isConnected: false)
                }
            }
        }
    }
    
    // MARK: Button 액션
    @objc private func backButtonTapped() {
        // 뒤로 가기 동작
        WatchManager.shared.sendSongSelectionToWatch(songTitle: "", hapticSequence: [])
        navigationController?.popViewController(animated: true)
    }
    
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
            sendPlayStatusToWatch(startTimeInterVal: futureTime)
            let delay = futureTime - Date().timeIntervalSince1970
            // 예약 시간에 재생
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // MIDI 재생
            self.musicPlayer.playMIDI(delay: delay - 0.21)
//            }
            stopButton.isHidden = false
            // 워치로 play 예약 메시지 전송
        }
        playPauseButton.isPlaying.toggle() // 재생/일시정지 상태 변경
    }
    
    @objc private func stopButtonTapped() {
//        WatchManager.shared.launchWatch()
        sendStopStatusToWatch()
        musicPlayer.stopMIDI()
        playPauseButton.isPlaying = false
        stopButton.isHidden = true
    }
    
    @objc private func presentBPMModal() {
        let setBPMViewController = SetBPMViewController()
        present(setBPMViewController, animated: true, completion: nil)
    }
    
    // 임시 픽커 업데이트
    private func updateScore(score: Score) {
        currentScore = score
        pickerView.reloadAllComponents() // 데이터를 받아오면 Picker 업데이트
    }
    
    // MARK: MIDI 파일, 햅틱 시퀀스 관리
    // 테스트를 위해 임시 변환 여기서 실행
    private func generateMusicXMLAudio() {
        // MusicXML 파일 로드
        guard let xmlPath = Bundle.main.url(forResource: "mannam", withExtension: "xml") else {
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

                currentScore = score
                updateScore(score: score)
                await createMIDIFile(score: score)
                
            } catch {
                ErrorHandler.handleError(error: error)
            }
        }
    }
    
    private func createMIDIFile(score: Score, startMeasureNumber: Int? = nil, endMeasureNumber: Int? = nil) async {
        do {
            // MIDI File URL 초기화
            playPauseButton.isEnabled = false
            midiFilePathURL = nil
            if let startMeasureNumber, let endMeasureNumber {
                // 구단 MIDI 파일 생성
                midiFilePathURL = try await mediaManager.getClipMIDIFile(part: score.parts.last!,
                                                                         divisions: score.divisions,
                                                                         startNumber: startMeasureNumber,
                                                                         endNumber: endMeasureNumber)
            } else {
                // TODO: 사용할 파트 어떻게 정할지 구상 필요
                midiFilePathURL = try await mediaManager.getPartMIDIFile(part: score.parts.last!,
                                                                         divisions: score.divisions,
                                                                         isChordEnabled: false)
            }
            // MIDI 파일 URL 확인 및 파일 로드
            if let midiFilePathURL = midiFilePathURL {
                print("MIDI file created successfully: \(midiFilePathURL)")
                // 햅틱 시퀀스 관리
                var hapticSequence: [Double]? = nil
                
                if let startMeasureNumber, let endMeasureNumber {
                    hapticSequence = try await mediaManager.getClipHapticSequence(part: score.parts.last!,
                                                                                divisions: score.divisions,
                                                                                startNumber: startMeasureNumber,
                                                                                endNumber: endMeasureNumber)
                } else {
                    hapticSequence = try await mediaManager.getHapticSequence(part: score.parts.last!,
                                                                                      divisions: score.divisions)
                }
                if let validHapticSequence = hapticSequence {
                    // 워치로 곡 선택 메시지 전송
                    await sendHapticSequenceToWatch(hapticSequence: validHapticSequence)
                } else {
                    print("No valid haptic sequence found.")
                }
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
    func sendHapticSequenceToWatch(hapticSequence: [Double]) async {
        let isLaunched = await WatchManager.shared.launchWatch()

        if isLaunched {
            // 임시 송 타이틀
            let songTitle = currentScore.title
            WatchManager.shared.sendSongSelectionToWatch(songTitle: songTitle, hapticSequence: hapticSequence)
        }
    }
    
    // 워치로 실행 예약 메시지 전송
      func sendPlayStatusToWatch(startTimeInterVal: TimeInterval) {
          WatchManager.shared.sendPlayStatusToWatch(status: .play, startTime: startTimeInterVal)
      }
      
      // 워치로 일시정지 예약 메시지 전송
      func sendPauseStatusToWatch() {
          WatchManager.shared.sendPlayStatusToWatch(status: .pause, startTime: nil)
      }
      
      // 워치로 멈추고 처음으로 대기 메시지 전송
      func sendStopStatusToWatch() {
          WatchManager.shared.sendPlayStatusToWatch(status: .stop, startTime: nil)
      }
  }

extension MusicPracticeViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    // UIPickerViewDataSource 프로토콜
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // UIPickerView의 열 수
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let totalMeasuresCount = currentScore.parts.last?.measures.values.reduce(0) { total, measuresArray in
            total + measuresArray.count
        } ?? 0
        
        return totalMeasuresCount
    }
    
    // UIPickerViewDelegate 프로토콜
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // parts.last의 모든 키와 마디 넘버를 추출한 배열을 만들기
        let measureDetails = currentScore.parts.last?.measures.flatMap { (lineNumber, measures) in
            measures.map { measure in
                (lineNumber: lineNumber, measureNumber: measure.number)
            }
        }.sorted(by: { $0.measureNumber < $1.measureNumber }) ?? []
        
        // 해당 행(row)에 해당하는 마디 넘버와 키 반환
        if row < measureDetails.count {
            let detail = measureDetails[row]
            return "줄 \(detail.lineNumber): 마디 \(detail.measureNumber)"  // lineNumber와 measureNumber 함께 표시
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // parts.last의 모든 lineNumber와 마디 넘버를 추출한 배열을 만듦
        let measureDetails = currentScore.parts.last?.measures.flatMap { (lineNumber, measures) in
            measures.map { measure in
                (lineNumber: lineNumber, measureNumber: measure.number)
            }
        }.sorted(by: { $0.measureNumber < $1.measureNumber }) ?? []
        
        // 첫 번째 열(0): lineNumber, 두 번째 열(1): measureNumber
        switch component {
        case 0:
            // 첫 번째 열에서 선택된 row (lineNumber 처리)
            if row < measureDetails.count {
                startMeasureNumber = measureDetails[row].measureNumber
                print("Selected StartMeasure: \(startMeasureNumber)")
            }
        case 1:
            // 두 번째 열에서 선택된 row (measureNumber 처리)
            if row < measureDetails.count {
                endMeasureNumber = measureDetails[row].measureNumber
                print("Selected EndMeasure: \(endMeasureNumber)")
                // 구간 미디파일 생성
                Task {
                    if startMeasureNumber < endMeasureNumber {
                        await createMIDIFile(score: currentScore, startMeasureNumber: startMeasureNumber, endMeasureNumber: endMeasureNumber)
                    }
                }
            }
        default:
            break
        }
    }
}
