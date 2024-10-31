//
//  MusicPracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//
import Combine
import Lottie
import SwiftUI
import UIKit
import WatchConnectivity

class ScorePracticeViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()  // Combine에서 구독을 관리할 Set
    private var animationView: LottieAnimationView? // 로띠뷰
    
    var currentScore: Score // 현재 악보 score
    var currentMeasure: Int = 0// 현재 진행중인 마디
    var totalMeasure = 0
    
    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil) // Calls the designated initializer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var mediaManager = MediaManager()
    let practicNavBar = PracticeNavigationBar()
    let scorePracticeTitleView = ScorePracticeTitleView()
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bpmButton = BPMButton()
    let currentMeasureLabel = UILabel()
    private let controlButtonView = ControlButtonView()
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
        containerView.addSubview(scorePracticeTitleView)
        scorePracticeTitleView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(divider) // divider
        // 컨트롤러뷰 추가
        controlButtonView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controlButtonView)
        // 루트 뷰 설정
        self.view = containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        Task {
            await createMIDIFile(score: currentScore)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동할 때 네비게이션 바를 다시 표시하도록 설정
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalMeasure = mediaManager.getMainPartMeasureCount(score: currentScore)
        Task {
            await createMIDIFile(score: currentScore)
        }
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        updateWatchAppStatus()
        
        // MARK: - [1] 아이폰에서만 재생
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchPlayNotification), name: .watchPlayButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchPauseNotification), name: .watchPauseButtonTapped, object: nil)
        
    }
    
    private func setupUI() {
        scorePracticeTitleView.titleLabel.text = currentScore.title
        bpmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bpmButton)
        // 현재 진행 중인 마디 표시 라벨
        currentMeasureLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentMeasureLabel)
        
        setLottieView()
    }
    
    private func setupConstraints() {
        // 커스텀 네비게이션 바와 MusicPracticeView 레이아웃 설정
        NSLayoutConstraint.activate([
            // 커스텀 네비게이션 바 레이아웃 설정
            practicNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practicNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practicNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practicNavBar.heightAnchor.constraint(equalToConstant: 60),
            
            // divider
            divider.topAnchor.constraint(equalTo: practicNavBar.bottomAnchor, constant: 1),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 좌우 패딩 없이 전체 너비
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            // MusicPracticeView 레이아웃 설정 (네비게이션 바 아래에 위치)
            scorePracticeTitleView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            scorePracticeTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scorePracticeTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scorePracticeTitleView.heightAnchor.constraint(equalToConstant: 38),
            
            // BPM 버튼
            bpmButton.topAnchor.constraint(equalTo: scorePracticeTitleView.bottomAnchor, constant: 20),
            bpmButton.heightAnchor.constraint(equalToConstant: 48),
            bpmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // 현재 진행 중인 마디 라벨
            currentMeasureLabel.topAnchor.constraint(equalTo: scorePracticeTitleView.bottomAnchor, constant: 20),
            currentMeasureLabel.heightAnchor.constraint(equalToConstant: 48),
            currentMeasureLabel.leadingAnchor.constraint(equalTo: bpmButton.trailingAnchor, constant: 60),
            
            // 컨트롤러뷰
            controlButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlButtonView.heightAnchor.constraint(equalToConstant: 120),
            controlButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
    }
    
    private func setupActions() {
        // 클릭 시 이벤트 설정
        practicNavBar.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        practicNavBar.settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        //        bpmButton.addTarget(self, action: #selector(presentBPMModal), for: .touchUpInside)
        controlButtonView.playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlButtonView.stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        controlButtonView.previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        controlButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        IOStoWatchConnectivityManager.shared.$isWatchAppConnected
            .sink { [weak self] isConnected in
                self?.handleWatchAppConnectionChange(isConnected)
            }
            .store(in: &cancellables)
        
        // 현재 마디 파악을 위해 MIDI Player 진행 구간 구독하여 값 처리
        musicPlayer.$currentTime
            .sink { [weak self] currentTime in
                self?.updateCurrentMeasureLabel(currentTime: currentTime)
            }
            .store(in: &cancellables)
        
        // WatchManager의 playStatus를 구독하여 UI 업데이트
        IOStoWatchConnectivityManager.shared.$playStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                self?.handlePlayStatusChange(newStatus)
            }
            .store(in: &cancellables)
    }
    
    private func updateCurrentMeasureLabel(currentTime: TimeInterval) {
        let division = Double(currentScore.divisions)
        currentMeasure = mediaManager.getCurrentMeasureNumber(currentTime: Double(currentTime), division: division)
        
        currentMeasureLabel.text = "\(currentMeasure)/\(totalMeasure)마디"
    }
    
    private func handleWatchAppConnectionChange(_ isConnected: Bool) {
        if isConnected {
            // 연결되었을 때 처리
            self.practicNavBar.setWatchImage(isConnected: true)
        } else {
            // 연결되지 않았을 때 처리
            self.practicNavBar.setWatchImage(isConnected: false)
        }
    }
    
    // 워치 앱 상태 업데이트 메서드
    @objc func updateWatchAppStatus() {
        Task {
            let isLaunched = await IOStoWatchConnectivityManager.shared.launchWatch()
            
            if isLaunched {
                let isWatchAppReachable = IOStoWatchConnectivityManager.shared.isWatchAppConnected
                if isWatchAppReachable {
                    self.practicNavBar.setWatchImage(isConnected: true)
                } else {
                    self.practicNavBar.setWatchImage(isConnected: false)
                }
                
            } else {
                // 워치 런칭 실패 시 처리
                ErrorHandler.handleError(error: "Failed to launch the Watch app.")
                self.practicNavBar.setWatchImage(isConnected: false)
            }
        }
    }
    
    // 알림 수신 후 실행될 재생 및 일시정지 함수
    @objc func remotePlayButtonTapped(startTime: TimeInterval) {
        guard let outputPathURL = midiFilePathURL else {
            ErrorHandler.handleError(error: "MIDI file URL is nil.")
            return
        }
        
        // MIDI 파일이 존재하는지 확인
        if !FileManager.default.fileExists(atPath: outputPathURL.path) {
            ErrorHandler.handleError(error: "MIDI file not found at path \(outputPathURL.path)")
            return
        }
        
        // delay를 startTime을 기준으로 계산
        let currentTime = Date().timeIntervalSince1970
        let delay = startTime - currentTime
        if delay > 0 {
            // MIDI 파일 재생 예약
            musicPlayer.playMIDI(delay: delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - 3) {
                self.showLottieAnimation()
            }
            controlButtonView.stopButton.isHidden = false
        } else {
            ErrorHandler.handleError(error: "Start time already passed.")
        }
    }
    
    func remotePauseButtonTapped() {
        stopButtonTapped() // 즉시 일시정지
    }
    
    // MARK: 로띠뷰
    func setLottieView() {
        animationView = LottieAnimationView(name: "Countdown") // animationFile은 Lottie JSON 파일명
        guard let animationView = animationView else { return }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        // 애니메이션 재생 옵션 설정
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce // 반복 재생 설정
        animationView.animationSpeed = 1.0 // 재생 속도
        
        view.addSubview(animationView)
        animationView.isHidden = true
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    // 특정 조건에서 애니메이션을 재생
    func showLottieAnimation() {
        animationView?.isHidden = false
        animationView?.play { [weak self] (finished) in
            if finished {
                self?.hideLottieAnimation()
            }
        }
    }
    
    // 애니메이션이 완료되면 뷰 숨기기
    func hideLottieAnimation() {
        animationView?.isHidden = true
    }
    
    // MARK: - [1] 워치에서 버튼 눌렀을 때 notification을 받아서 아이폰 함수를 호출
    @objc private func handleWatchPlayNotification() {
        // 워치에서 play 알림 수신 시 playButtonTapped 호출
        playButtonTapped()
    }
    
    @objc private func handleWatchPauseNotification() {
        // 워치에서 pause 알림 수신 시 stopButtonTapped 호출
        stopButtonTapped()
    }
    
    //    //MARK: - [2] 워치에서 타이머 직접 수행
    //    // 워치에서 Play 알림을 수신했을 때 호출
    //    @objc private func handleWatchPlayNotification(_ notification: Notification) {
    //        if let startTime = notification.object as? TimeInterval {
    //            remotePlayButtonTapped(startTime: startTime)
    //        }
    //    }
    //
    //    // 워치에서 Pause 알림을 수신했을 때 호출
    //    @objc private func handleWatchPauseNotification() {
    //        remotePauseButtonTapped()
    //    }
    
    // MARK: Button 액션
    @objc private func backButtonTapped() {
        // 뒤로 가기 동작
        IOStoWatchConnectivityManager.shared.sendScoreSelectionToWatch(scoreTitle: "", hapticSequence: [])
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func settingButtonTapped() {
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
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
        if controlButtonView.playPauseButton.isPlaying {
            // 재생 중일 때 일시정지
            sendPauseStatusToWatch()
            // MIDI 일시정지
            musicPlayer.pauseMIDI()
        } else {
            // 현재 시간으로부터 4초 후, 평균 워치지연시간 0.14
            let futureTime = Date().addingTimeInterval(4).timeIntervalSince1970
            sendPlayStatusToWatch(startTimeInterVal: futureTime)
            let delay = futureTime - Date().timeIntervalSince1970
            // MIDI 재생
            // TODO: 딜레이 조절해야됨
            musicPlayer.playMIDI(delay: delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - 3) {
                self.showLottieAnimation()
            }
            controlButtonView.stopButton.isHidden = false
        }
        controlButtonView.playPauseButton.isPlaying.toggle()
    }
    
    @objc private func stopButtonTapped() {
        sendStopStatusToWatch()
        musicPlayer.stopMIDI()
        controlButtonView.playPauseButton.isPlaying = false
        controlButtonView.stopButton.isHidden = true
        IOStoWatchConnectivityManager.shared.playStatus = .stop
    }
    
    @objc private func previousButtonTapped() {
        if currentMeasure != 0 {
            currentMeasure -= 1
        }
        
        jumpMeasure()
    }
    
    @objc private func nextButtonTapped() {
        if currentMeasure != totalMeasure {
            currentMeasure += 1
        }
        jumpMeasure()
    }
    
    private func jumpMeasure() {
        let startTime = mediaManager.getMeasureStartTime(currentMeasure: Int(currentMeasure),
                                                         division: Double(currentScore.divisions))
        currentMeasureLabel.text = "\(currentMeasure)/\(totalMeasure)마디"
        Task {
            let hapticSequence = try await mediaManager.getClipHapticSequence(part: currentScore.parts.last!,
                                                                              divisions: currentScore.divisions,
                                                                              startNumber: currentMeasure,
                                                                              endNumber: totalMeasure)
            let futureTime = Date().addingTimeInterval(1).timeIntervalSince1970
            
            musicPlayer.playMIDI(startTime: startTime, delay: 1)
            sendJumpMeasureToWatch(hapticSequence: hapticSequence, startTimeInterVal: futureTime)
        }
    }
    
    @objc private func presentBPMModal() {
        let setBPMViewController = SetBPMViewController()
        present(setBPMViewController, animated: true, completion: nil)
    }
    
    // 시작 버튼 활성화 업데이트
    private func updatePlayPauseButton(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.controlButtonView.playPauseButton.isEnabled = isEnabled
        }
    }
    
    // MARK: MIDI 파일, 햅틱 시퀀스 관리
    private func createMIDIFile(score: Score, startMeasureNumber: Int? = nil, endMeasureNumber: Int? = nil) async {
        do {
            // MIDI File URL 초기화
            updatePlayPauseButton(false)
            midiFilePathURL = nil
            // TODO: 사용할 파트 어떻게 정할지 구상 필요
            mediaManager.setCurrentPart(part: score.parts.last!, division: Double(score.divisions))
            if let startMeasureNumber, let endMeasureNumber {
                // 구단 MIDI 파일 생성
                midiFilePathURL = try await mediaManager.getClipMIDIFile(part: score.parts.last!,
                                                                         divisions: score.divisions,
                                                                         startNumber: startMeasureNumber,
                                                                         endNumber: endMeasureNumber)
            } else {
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
                updatePlayPauseButton(true)
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
        let isLaunched = await IOStoWatchConnectivityManager.shared.launchWatch()
        
        if isLaunched {
            let scoreTitle = currentScore.title
            IOStoWatchConnectivityManager.shared.sendScoreSelectionToWatch(scoreTitle: scoreTitle, hapticSequence: hapticSequence)
        }
    }
    
    // 워치로 실행 예약 메시지 전송
    func sendPlayStatusToWatch(startTimeInterVal: TimeInterval) {
        IOStoWatchConnectivityManager.shared.sendPlayStatusToWatch(status: .play, startTime: startTimeInterVal)
    }
    
    // 마디 점프 메시지 전송
    func sendJumpMeasureToWatch(hapticSequence: [Double], startTimeInterVal: TimeInterval) {
        let scoreTitle = currentScore.title
        
        
        IOStoWatchConnectivityManager.shared.sendJumpMeasureToWatch(scoreTitle: scoreTitle, hapticSequence: hapticSequence, status: .play, startTime: startTimeInterVal)
    }
    
    // 워치로 일시정지 예약 메시지 전송
    func sendPauseStatusToWatch() {
        IOStoWatchConnectivityManager.shared.sendPlayStatusToWatch(status: .pause, startTime: nil)
    }
    
    // 워치로 멈추고 처음으로 대기 메시지 전송
    func sendStopStatusToWatch() {
        IOStoWatchConnectivityManager.shared.sendPlayStatusToWatch(status: .stop, startTime: nil)
    }
}

// MARK: - Play Status Handling Extension
extension ScorePracticeViewController {
    func handlePlayStatusChange(_ status: PlayStatus) {
        switch status {
        case .ready:
            // 준비 상태: 재생 버튼만 표시
            controlButtonView.playPauseButton.isHidden = false
            controlButtonView.playPauseButton.isPlaying = false
            controlButtonView.stopButton.isHidden = true
        case .play:
            // 재생 상태: 일시정지 버튼 표시
            controlButtonView.playPauseButton.isHidden = false
            controlButtonView.playPauseButton.isPlaying = true
            controlButtonView.stopButton.isHidden = false
            // MIDI 재생 시작
            startMIDIPlayback()
        case .pause:
            // 일시정지 상태: 재생 버튼 표시
            controlButtonView.playPauseButton.isHidden = false
            controlButtonView.playPauseButton.isPlaying = false
            controlButtonView.stopButton.isHidden = false
            // MIDI 일시정지
            musicPlayer.pauseMIDI()
        case .stop:
            // 정지 상태: 재생 버튼만 표시
            controlButtonView.playPauseButton.isHidden = false
            controlButtonView.playPauseButton.isPlaying = false
            controlButtonView.stopButton.isHidden = true
            // MIDI 재생 중지
            musicPlayer.stopMIDI()
        case .done:
            // 완료 상태: 필요에 따라 처리
            break
        }
    }
    
    func startMIDIPlayback() {
        guard let outputPathURL = midiFilePathURL else {
            ErrorHandler.handleError(error: "MIDI file URL is nil.")
            return
        }
        
        // MIDI 파일이 존재하는지 확인
        if !FileManager.default.fileExists(atPath: outputPathURL.path) {
            ErrorHandler.handleError(error: "MIDI file not found at path \(outputPathURL.path)")
            return
        }
        
        // 현재 시간으로부터 4초 후 재생 시작
        let futureTime = Date().addingTimeInterval(4).timeIntervalSince1970
        let delay = futureTime - Date().timeIntervalSince1970
        self.musicPlayer.playMIDI(delay: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay - 3) {
            self.showLottieAnimation()
        }
    }
}
