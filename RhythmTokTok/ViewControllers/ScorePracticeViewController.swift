//
//  ScorePracticeViewController.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/15/24.
//
import AVFoundation
import Combine
import CoreData
import SwiftUICore
import UIKit

// TODO: 코드 길어서 분리해야됨
class ScorePracticeViewController: UIViewController, UIGestureRecognizerDelegate {
    private var scoreService = ScoreService()
    private var cancellables = Set<AnyCancellable>()  // Combine에서 구독을 관리할 Set
    private var countDownLottieView: CountDownLottieView? // 로띠뷰
    private var jumpMeasureWorkItem: DispatchWorkItem?
    var countdownTimer: Timer?
    var countdownTime: Int = 3 // 원하는 카운트다운 시간 (초 단위)
    // Task 관리용
    private var checkWatchStatusTask: Task<Void, Never>? // Task를 저장할 프로퍼티
    
    // 악보 관리용
    private var currentScore: Score // 현재 악보 score
    private var previousScoreState: Score? // 변경 확인용
    private var currentMeasure: Int = 0// 현재 진행중인 마디
    private var totalMeasure = 0
    private var totalHapticSequence: [Double] = []
    private var mediaManager = MediaManager()
    private var musicPlayer = MusicPlayer()
    private var midiFilePathURL: URL?
    private var metronomeMIDIFilePathURL: URL?
    private var isPlayingMIDIFile = false
    
    // UI
    // 네비게이션바
    private let practiceNavBar = CommonNavigationBar()
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
    
    // MARK: - init
    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil) // Calls the designated initializer
        
        // musicPlayer에 soundOption을 전달
        musicPlayer.soundOption = currentScore.soundOption
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // 메모리 해제될 때 옵저버 제거
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }
    
    // MARK: - 뷰 생명주기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleScoreChange()
        configureMusicPlayer()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        Task { await createMIDIWithHaptic(score: currentScore) }
        setupScoreState()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IOStoWatchConnectivityManager.shared.watchAppStatus = .ready
        resetScore()
        resetSwipeGesture()
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 스와이프 제스처 인식기 설정
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(backButtonTapped))
        practiceNavBar.configure(title: "", buttonType: .watch)
        configureUI()
        totalMeasure = mediaManager.getMainPartMeasureCount(score: currentScore)
        scoreCardView.setTotalMeasure(totalMeasure: totalMeasure)
        setupActions()
    }
    
    private func handleScoreChange() {
        if let previousState = previousScoreState, previousState != currentScore {
            ToastAlert.show(message: "설정이 변경 되었어요.", in: self.view, iconName: "check.circle.color")
        }
        previousScoreState = currentScore.clone()
    }

    private func configureMusicPlayer() {
        musicPlayer.soundOption = currentScore.soundOption
    }

    private func setupScoreState() {
        countdownTime = 3
        mediaManager.currentScore = currentScore
        checkUpdatePreviousButtonState()
        checkUpdateNextButtonState()
        scoreCardView.bpmLabel.updateSpeedText(currentSpeed: currentScore.bpm)
        statusTags.currentScore = currentScore
        statusTags.updateTag()
    }
    
    private func resetSwipeGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.removeTarget(self, action: #selector(backButtonTapped))
    }
    
    private func setupSwipeGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(backButtonTapped))
    }

    private func setupPracticeView() {
        practiceNavBar.configure(title: "", buttonType: .watch)
        configureUI()
        totalMeasure = mediaManager.getMainPartMeasureCount(score: currentScore)
        scoreCardView.setTotalMeasure(totalMeasure: totalMeasure)
        setupActions()
        setupBindings()
    }
    
    // MARK: - View
    private func configureUI() {
        // 루트 뷰 설정
        let containerView = UIView()
        containerView.backgroundColor = .white
        self.view = containerView
        
        // 필요한 서브 뷰 추가 및 기본 설정
        [practiceNavBar, divider, scoreCardView, progressBar, statusTags, controlButtonView].forEach {
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
            practiceNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            practiceNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            practiceNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            practiceNavBar.heightAnchor.constraint(equalToConstant: 64),
            
            // 툴팁 뷰 레이아웃
            toolTipView.topAnchor.constraint(equalTo: practiceNavBar.bottomAnchor, constant: 4),
            toolTipView.centerXAnchor.constraint(equalTo: practiceNavBar.watchConnectImageView.centerXAnchor, constant: -90),
            toolTipView.widthAnchor.constraint(equalToConstant: 253), // 툴팁의 최대 너비 설정
            toolTipView.heightAnchor.constraint(equalToConstant: 88),

            // divider
            divider.topAnchor.constraint(equalTo: practiceNavBar.bottomAnchor, constant: 0),
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
    
    // MARK: 버튼 액션 관리
    private func setupActions() {
        practiceNavBar.onBackButtonTapped = { [weak self] in
            self?.backButtonTapped()
        }
        practiceNavBar.onSettingButtonTapped = { [weak self] in
            self?.settingButtonTapped()
        }
        controlButtonView.playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlButtonView.resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        controlButtonView.previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        controlButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: 프로퍼티 구독
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
                    DispatchQueue.main.async {
                        ToastAlert.show(message: "악보 연습을 마쳤어요! 최고인데요?", in: self.view, iconName: "congratulation")
                    }
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
                self.practiceNavBar.setWatchImage(isConnected: true)
                self.toolTipView.setStatus(.connected)
            } else {
                self.practiceNavBar.setWatchImage(isConnected: false)
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
        resetScore()
        self.navigationController?.popViewController(animated: true)
    }
    
    func resetScore() {
        musicPlayer.stopMIDI()
        IOStoWatchConnectivityManager.shared.playStatus = .ready
        // 초기화 로직
        IOStoWatchConnectivityManager.shared.sendScoreSelection(scoreTitle: "", hapticSequence: [])
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
        
        // MIDI 파일 재생시간 offset
        let midiOffset = -0.065
        actionStart(futureTime: futureTime.addingTimeInterval(midiOffset))
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
    
    @objc func actionStart(futureTime: Date) {
        self.musicPlayer.playMIDI(futureTime: futureTime)
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
                let startTime = self.mediaManager.getMeasureStartTime(currentMeasure: Int(self.currentMeasure), division: Double(self.currentScore.divisions))
                // 멜로디 마디 점프 햅틱 시퀀스 재산출
//                let hapticSequence = try await self.mediaManager.getClipMeasureHapticSequence(part: self.currentScore.parts.last!,
//                                                                                              divisions: self.currentScore.divisions,
//                                                                                              startNumber: self.currentMeasure,
//                                                                                              endNumber: self.totalMeasure)
                let hapticSequence = await self.mediaManager.getMetronomeHapticSequence()
                
                self.musicPlayer.jumpMIDI(jumpPosition: startTime)
                self.sendJumpMeasureToWatch(hapticSequence: hapticSequence, startTimeInterVal: 0)
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

// MARK: - [Ext] MIDI 파일, 햅틱 시퀀스 관리
extension ScorePracticeViewController {
    private func createMIDIWithHaptic(score: Score) async {
        do {
            // MIDI File URL 초기화
            updatePlayPauseButton(false)
            midiFilePathURL = nil
            // TODO: 사용할 파트 어떻게 정할지 구상 필요
            mediaManager.setCurrentPart(part: score.parts.last!, division: Double(score.divisions))
            midiFilePathURL = try await mediaManager.getPartMIDIFile(part: score.parts.last!,
                                                                     divisions: score.divisions,
                                                                     soundKey: currentScore.soundKeyOption,
                                                                     isChordEnabled: false)
            try await createHaptics(midiFilePathURL: midiFilePathURL, score: score)
            
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
    
    private func createHaptics(midiFilePathURL: URL?, score: Score) async throws {
        guard let midiFilePathURL = midiFilePathURL else {
            throw NSError(domain: "MIDIError", code: 404, userInfo: [NSLocalizedDescriptionKey: "MIDI file URL is nil."])
        }

        // 햅틱 시퀀스 생성
        let hapticSequence = await mediaManager.getMetronomeHapticSequence()
        totalHapticSequence = hapticSequence
        sendHapticSequenceToWatch(hapticSequence: hapticSequence)
        

        // MIDI 파일 로드
        musicPlayer.loadMIDIFile(midiURL: midiFilePathURL)

        // Metronome MIDI 파일 로드
        let metronomeMIDIFilePathURL = try await mediaManager.getMetronomeMIDIFile(parsedScore: score)
        musicPlayer.loadMetronomeMIDIFile(midiURL: metronomeMIDIFilePathURL)
        updatePlayPauseButton(true)
        
    }
}

// MARK: - [Ext] 컨트롤러 버튼 관련
extension ScorePracticeViewController {
    @objc private func playButtonTapped() {
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
}

// MARK: - [Ext] 워치 통신 관련
extension ScorePracticeViewController {
    // 워치로 곡 선택 메시지 전송, 비동기 처리
    func sendHapticSequenceToWatch(hapticSequence: [Double]) {
        checkWatchStatusTask?.cancel()
        
        checkWatchStatusTask = Task {
            let scoreTitle = self.currentScore.title
            IOStoWatchConnectivityManager.shared.sendScoreSelection(scoreTitle: scoreTitle,
                                                                    hapticSequence: hapticSequence)
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5초 대기
            if Task.isCancelled {
                return // Task가 취소되면 즉시 종료
            }
            if IOStoWatchConnectivityManager.shared.watchAppStatus != .connected {
                IOStoWatchConnectivityManager.shared.watchAppStatus = .lowBattery
                ErrorHandler.handleError(error: "Apple Watch가 꺼져 있거나 배터리가 부족할 수 있습니다. 배터리를 확인하거나 Watch가 켜져 있는지 확인해 주세요.")
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
        IOStoWatchConnectivityManager.shared.sendUpdateStatusWithHapticSequence(currentScore: currentScore,
                                                                                hapticSequence: hapticSequence,
                                                                                status: .jump,
                                                                                startTime: startTimeInterVal)
    }
    
    // 워치로 일시정지 예약 메시지 전송
    func sendPauseStatusToWatch() {
        Task {
            // 멜로디 일시정지 햅틱 시퀀스 재산출 코드
//            let hapticSequence = try await mediaManager.getClipPauseHapticSequence(part: currentScore.parts.last!,
//                                                                                   divisions: currentScore.divisions,
//                                                                                   pauseTime: musicPlayer.currentTime)
            let hapticSequence = await mediaManager.getClipPauseMetronomeHapticSequence(pauseTime: musicPlayer.currentTime)
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
}

// MARK: - [Ext] 설정뷰 연결 관련
extension ScorePracticeViewController {
    @objc private func settingButtonTapped() {
        resetButtonTapped() // 재생 상태 멈춤
        let settingViewController = SettingViewController(currentScore: currentScore)
        navigationController?.pushViewController(settingViewController, animated: true)
    }
}
