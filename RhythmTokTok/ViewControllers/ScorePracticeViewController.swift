//
//  ScorePracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//
import Combine
import UIKit
import AVFoundation

// TODO: 코드 길어서 분리해야됨
class ScorePracticeViewController: UIViewController, UIGestureRecognizerDelegate {
    private var cancellables = Set<AnyCancellable>()  // Combine에서 구독을 관리할 Set
    private var countDownLottieView: CountDownLottieView? // 로띠뷰
    var countdownTimer: Timer?
    var countdownTime: Int = 3 // 원하는 카운트다운 시간 (초 단위)
    private var jumpMeasureWorkItem: DispatchWorkItem?
    
    // 악보 관리용
    private var currentScore: Score // 현재 악보 score
    private var currentMeasure: Int = 0// 현재 진행중인 마디
    private var totalMeasure = 0
    private var totalHapticSequence: [Double] = []
    private var mediaManager = MediaManager()
    private let musicPlayer = MusicPlayer()
    private var midiFilePathURL: URL?
    private var metronomeMIDIFilePathURL: URL?
    private var isPlayingMIDIFile = false
    
    // View
    private let practicNavBar = PracticeNavigationBar()
    // 툴팁
    private let toolTipView: ToolTipView = {
        let toolTip = ToolTipView(status: .ready) // 초기 상태 설정
        return toolTip
    }()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "background_tertiary")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let progressBar = ProgressBarView()
    private let statusTags = StatusTagView(frame: .zero)
    private let scoreCardView = ScorePracticeScoreCardView()
    private let controlButtonView = ControlButtonView()
    
    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil) // Calls the designated initializer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: 값 초기화 함수 필요
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        countdownTime = 3
        Task { await createMIDIFile(score: currentScore) }
        scoreCardView.bpmLabel.updateSpeedText()
        checkUpdatePreviousButtonState()
        checkUpdateNextButtonState()

        self.statusTags.currentScore = currentScore
        statusTags.updateTag()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IOStoWatchConnectivityManager.shared.watchAppStatus = .ready
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        // 스와이프 제스처 초기화
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.removeTarget(self, action: #selector(backButtonTapped))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 스와이프 제스처 인식기 설정
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(backButtonTapped))
        configureUI()
        totalMeasure = mediaManager.getMainPartMeasureCount(score: currentScore)
        scoreCardView.setTotalMeasure(totalMeasure: totalMeasure)
        setupActions()
        setupBindings()
    }
    
    private func configureUI() {
        // 루트 뷰 설정
        let containerView = UIView()
        containerView.backgroundColor = .white
        self.view = containerView
        
        // 필요한 서브 뷰 추가 및 기본 설정
        [practicNavBar, divider, scoreCardView, progressBar, statusTags, controlButtonView].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        toolTipView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toolTipView) // ToolTipView 추가

        // 추가 UI 초기화 설정
        scoreCardView.titleLabel.text = currentScore.title
        progressBar.setProgress(0.0, animated: false)
        countDownLottieView = CountDownLottieView(view: self.view, animationName: "Countdown")
        
        // 제약 조건 추가
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 커스텀 네비게이션 바와 ScorePracticeView 레이아웃 설정
        NSLayoutConstraint.activate([
            // 커스텀 네비게이션 바 레이아웃 설정
            practicNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practicNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practicNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practicNavBar.heightAnchor.constraint(equalToConstant: 60),
            
            // 툴팁 뷰 레이아웃
            toolTipView.topAnchor.constraint(equalTo: practicNavBar.bottomAnchor, constant: 4),
            toolTipView.centerXAnchor.constraint(equalTo: practicNavBar.watchConnectImageView.centerXAnchor, constant: -90),
            toolTipView.widthAnchor.constraint(equalToConstant: 253), // 툴팁의 최대 너비 설정
            toolTipView.heightAnchor.constraint(equalToConstant: 88),

            // divider
            divider.topAnchor.constraint(equalTo: practicNavBar.bottomAnchor, constant: 0),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 좌우 패딩 없이 전체 너비
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            // 프로그래스바
            progressBar.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 0),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            // 멜로디, 진동 셋팅 테그
            statusTags.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 32),
            statusTags.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusTags.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusTags.heightAnchor.constraint(equalToConstant: 40),
            
            // ScorePracticeView 레이아웃 설정 (네비게이션 바 아래에 위치)
            scoreCardView.topAnchor.constraint(equalTo: statusTags.bottomAnchor, constant: 8),
            scoreCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 컨트롤러뷰
            controlButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlButtonView.topAnchor.constraint(equalTo: scoreCardView.bottomAnchor, constant: 102),
            controlButtonView.heightAnchor.constraint(equalToConstant: 248),
            controlButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        // 클릭 시 이벤트 설정
        practicNavBar.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        practicNavBar.settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        controlButtonView.playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlButtonView.resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        controlButtonView.previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        controlButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        IOStoWatchConnectivityManager.shared.$watchAppStatus
            .sink { [weak self] watchStatus in
                self?.handleWatchAppConnectionChange(watchStatus)
            }
            .store(in: &cancellables)
        
        // 현재 마디 파악을 위해 MIDI Player 진행 구간 구독하여 값 처리
        musicPlayer.$currentTime
            .sink { [weak self] currentTime in
                self?.updateCurrentMeasureLabel(currentTime: currentTime)
                self?.updateProgressBar(currentTime: currentTime)
            }
            .store(in: &cancellables)
        
        scoreCardView.textPublisher
            .sink { [weak self] current in
                self?.checkUpdatePreviousButtonState()
                self?.checkUpdateNextButtonState()
            }
            .store(in: &cancellables)
    
        // TODO: playerStatus ViewModel로 만들면 좋을 듯
        // WatchManager의 playStatus를 구독하여 UI 업데이트
        IOStoWatchConnectivityManager.shared.$playStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                self?.handlePlayStatusChange(newStatus)
            }
            .store(in: &cancellables)
        
        musicPlayer.$isEnd
            .sink { isEnd in
                if isEnd {
                    IOStoWatchConnectivityManager.shared.playStatus = .done
                }
            }
            .store(in: &cancellables)
        
        // 워치 컨트롤 요청 처리
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchPlayNotification),
                                               name: .watchPlayButtonTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchPauseNotification),
                                               name: .watchPauseButtonTapped, object: nil)
    }
    
    // MARK: UI 변경
    private func updateCurrentMeasureLabel(currentTime: TimeInterval) {
        let division = Double(currentScore.divisions)
        currentMeasure = mediaManager.getCurrentMeasureNumber(currentTime: Double(currentTime), division: division)
        
        scoreCardView.updateCurrentMeasureLabelText("\(currentMeasure)")
    }
    
    private func updateProgressBar(currentTime: TimeInterval) {
        let progress = currentTime / musicPlayer.getTotalDuration()
        
        progressBar.setProgress(CGFloat(progress), animated: false)
    }
    
    private func handleWatchAppConnectionChange(_ watchStatus: AppleWatchStatus) {
        DispatchQueue.main.async {
            if watchStatus == .connected {
                self.practicNavBar.setWatchImage(isConnected: true)
                self.toolTipView.setStatus(.connected)
            } else {
                self.practicNavBar.setWatchImage(isConnected: false)
                self.toolTipView.setStatus(watchStatus)
            }
        }
    }
    
    // 처음 마디에 위치할 때 이전마디 처음으로 버튼 비활성화
    private func checkUpdatePreviousButtonState() {
        if let startMeasureNumber = currentScore.parts.last?.measures[1]?[0].number {
            if scoreCardView.currentMeasureLabel.text == String(startMeasureNumber) || currentMeasure == 0 {
                controlButtonView.previousButton.isEnabled = false
                controlButtonView.resetButton.isEnabled = false
            } else {
                controlButtonView.previousButton.isEnabled = true
                controlButtonView.resetButton.isEnabled = true
            }
        } else {
            ErrorHandler.handleError(error: "Unexpectedly found nil while unwrapping an Optional value")
        }
    }
    
    private func checkUpdateNextButtonState() {
        if currentMeasure == totalMeasure {
            controlButtonView.nextButton.isEnabled = false
        } else {
            controlButtonView.nextButton.isEnabled = true
        }
    }
    
    // 시작 버튼 활성화 업데이트
    private func updatePlayPauseButton(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.controlButtonView.playPauseButton.isEnabled = isEnabled
        }
    }
    
    // 워치에서 버튼 눌렀을 때 notification을 받아서 아이폰 함수를 호출
    @objc private func handleWatchPlayNotification() {
        IOStoWatchConnectivityManager.shared.playStatus = .play
    }
    
    @objc private func handleWatchPauseNotification() {
        IOStoWatchConnectivityManager.shared.playStatus = .pause
    }
    
    // MARK: 네비게이션 버튼 액션
    @objc private func backButtonTapped() {
        // 뒤로 가기 동작
        musicPlayer.stopMIDI()
        IOStoWatchConnectivityManager.shared.playStatus = .ready
        IOStoWatchConnectivityManager.shared
            .sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                hapticSequence: [],
                                                status: .ready, startTime: 0)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func settingButtonTapped() {
        resetButtonTapped()
        let settingViewController = SettingViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    // MARK: 컨트롤러 버튼 액션
    @objc private func playButtonTapped() {
        print("현재 버튼 상태 \(IOStoWatchConnectivityManager.shared.playStatus)")
        if IOStoWatchConnectivityManager.shared.playStatus == .play {
            // 현재 재생 중이면 일시정지로 변경
            IOStoWatchConnectivityManager.shared.playStatus = .pause
        } else {
            // 재생 상태로 변경
            IOStoWatchConnectivityManager.shared.playStatus = .play
        }
    }
    
    @objc private func resetButtonTapped() {
        IOStoWatchConnectivityManager.shared.playStatus = .stop
    }
    
    @objc private func previousButtonTapped() {
        if currentMeasure != 0 {
            currentMeasure -= 1
        }
        
        IOStoWatchConnectivityManager.shared.playStatus = .jump
    }
    
    @objc private func nextButtonTapped() {
        if currentMeasure != totalMeasure {
            currentMeasure += 1
        }
        IOStoWatchConnectivityManager.shared.playStatus = .jump
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
                var hapticSequence: [Double]?
                
//                // MARK: 구간 선택 부분
//                if let startMeasureNumber, let endMeasureNumber {
//                    hapticSequence = try await mediaManager.getClipMeasureHapticSequence(part: score.parts.last!,
//                                                                                         divisions: score.divisions,
//                                                                                         startNumber: startMeasureNumber,
//                                                                                         endNumber: endMeasureNumber)
//                } else {
//                    hapticSequence = try await mediaManager.getHapticSequence(part: score.parts.last!,
//                                                                              divisions: score.divisions)
//                }
                hapticSequence = await mediaManager.getMetronomeHapticSequence()
                
                if let validHapticSequence = hapticSequence {
                    totalHapticSequence = validHapticSequence
                    // 워치로 곡 선택 메시지 전송
                    sendHapticSequenceToWatch(hapticSequence: validHapticSequence)
                    
                } else {
                    print("No valid haptic sequence found.")
                }
                // MIDI 파일 로드
                musicPlayer.loadMIDIFile(midiURL: midiFilePathURL)
                print("MIDI file successfully loaded and ready to play.")
            } else {
                ErrorHandler.handleError(error: "MIDI file URL is nil.")
            }
            
            // Metronome MIDI'
            metronomeMIDIFilePathURL = try await mediaManager.getMetronomeMIDIFile(parsedScore: score)
            
            if let metronomeMIDIFilePathURL {
                print("Metronome MIDI file created successfully: \(metronomeMIDIFilePathURL)")
                musicPlayer.loadMetronomeMIDIFile(midiURL: metronomeMIDIFilePathURL)
                updatePlayPauseButton(true)
            }
        
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
    
    // MARK: 워치 통신 부분
    // 워치로 곡 선택 메시지 전송, 비동기 처리
    func sendHapticSequenceToWatch(hapticSequence: [Double]) {
        Task {
            let isLaunched = await IOStoWatchConnectivityManager.shared.launchWatch()
            if isLaunched {
                let scoreTitle = currentScore.title
                IOStoWatchConnectivityManager.shared.sendScoreSelection(scoreTitle: scoreTitle,
                                                                        hapticSequence: hapticSequence)
            }
        }
    }
    
    // 워치로 실행 예약 메시지 전송
    func sendPlayStatusToWatch(startTimeInterVal: TimeInterval) {
        IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                hapticSequence: [],
                                                                                status: .play,
                                                                                startTime: startTimeInterVal)
    }
    
    func sendDoneStatusToWatch() {
        controlButtonView.playPauseButton.isPlaying = false
        IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                hapticSequence: totalHapticSequence,
                                                                                status: .done,
                                                                                startTime: 0)
    }
    
    // 마디 점프 메시지 전송
    func sendJumpMeasureToWatch(hapticSequence: [Double], startTimeInterVal: TimeInterval) {
        let scoreTitle = currentScore.title
        IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                hapticSequence: hapticSequence,
                                                                                status: .jump,
                                                                                startTime: startTimeInterVal)
    }
    
    // 워치로 일시정지 예약 메시지 전송
    func sendPauseStatusToWatch() {
        Task {
            let hapticSequence = try await mediaManager.getClipPauseHapticSequence(part: currentScore.parts.last!,
                                                                                   divisions: currentScore.divisions,
                                                                                   pauseTime: musicPlayer.currentTime)
            IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                    hapticSequence: hapticSequence,
                                                                                    status: .pause, startTime: 0)
        }
    }
    
    // 워치로 멈추고 처음으로 대기 메시지 전송
    func sendStopStatusToWatch() {
        IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                hapticSequence: totalHapticSequence,
                                                                                status: .stop, startTime: 0)
    }
    
    func handlePlayStatusChange(_ status: PlayStatus) {
        switch status {
        case .ready:
            controlButtonView.playPauseButton.isPlaying = false
        case .play:
            startMIDIPlayback()
        case .jump:
            jumpMeasure()
        case .pause:
            pauseMIDIPlayer()
        case .stop:
            resetMIDIPlayer()
        case .done:
            sendDoneStatusToWatch()
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
        let futureTime = Date().addingTimeInterval(4)
        sendPlayStatusToWatch(startTimeInterVal: futureTime.timeIntervalSince1970)
        
        // 카운트다운 3초 전에 카운트다운 애니메이션 시작
        countDownLottieView?.showBackground()
        let countDownTime = futureTime.addingTimeInterval(-3)
        let countDownTimer = Timer(fireAt: countDownTime, interval: 0, target: self, selector: #selector(startCountDownAnimation), userInfo: nil, repeats: false)
        RunLoop.main.add(countDownTimer, forMode: .common)
        
        // 예약된 시간에 MIDI 재생 시작
        let playTimer = Timer(fireAt: futureTime, interval: 0, target: self, selector: #selector(actionStart), userInfo: nil, repeats: false)
        RunLoop.main.add(playTimer, forMode: .common)
        
        // 타이머 설정
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdownTime > 0 {
                self.playSystemAlertSound() // 시스템 알림음 재생
                self.countdownTime -= 1
            } else {
                timer.invalidate() // 타이머 종료
                self.countDownLottieView?.stop()
                self.countdownTime = 3 // Lottie 애니메이션 중지
            }
        }
        
        controlButtonView.playPauseButton.isPlaying = true
    }
    
    @objc func startCountDownAnimation() {
        Logger.shared.log("Logger: 아이폰 카운트다운 시간")
        countDownLottieView?.play()
    }
    
    @objc func actionStart() {
        self.musicPlayer.playMIDI()
    }
    
    func playSystemAlertSound() {
        AudioServicesPlaySystemSound(1052) // 기본 제공 알림음 재생
    }
    
    func pauseMIDIPlayer() {
        // 재생 중일 때 일시정지
        musicPlayer.pauseMIDI()
        sendPauseStatusToWatch()
        controlButtonView.playPauseButton.isPlaying = false
    }
    
    func resetMIDIPlayer() {
        musicPlayer.stopMIDI()
        sendStopStatusToWatch()
        controlButtonView.playPauseButton.isPlaying = false
    }
    
    private func jumpMeasure() {
        // 이전 작업 취소
        jumpMeasureWorkItem?.cancel()
        // 새로운 DispatchWorkItem 생성
        jumpMeasureWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            Task {
                let startTime = self.mediaManager.getMeasureStartTime(currentMeasure: Int(self.currentMeasure),
                                                                      division: Double(self.currentScore.divisions))
                let hapticSequence = try await self.mediaManager.getClipMeasureHapticSequence(part: self.currentScore.parts.last!,
                                                                                              divisions: self.currentScore.divisions,
                                                                                              startNumber: self.currentMeasure,
                                                                                              endNumber: self.totalMeasure)
                self.musicPlayer.jumpMIDI(jumpPosition: startTime)
                self.sendJumpMeasureToWatch(hapticSequence: hapticSequence, startTimeInterVal: 0)
                print("점프 햅틱 갯수 : \(hapticSequence.count),")
                self.controlButtonView.playPauseButton.isPlaying = false
            }
        }
        
        // DispatchWorkItem 실행
        if let workItem = jumpMeasureWorkItem {
            DispatchQueue.main.async(execute: workItem)
        }
        
        // 라벨 업데이트는 바로 실행
        scoreCardView.updateCurrentMeasureLabelText("\(currentMeasure)")
    }
}
