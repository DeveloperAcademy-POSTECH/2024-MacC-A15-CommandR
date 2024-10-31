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
        setupBindings()    }
    
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
        WatchManager.shared.$isWatchAppConnected
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
        WatchManager.shared.$playStatus
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
            let isLaunched = await WatchManager.shared.launchWatch()
            
            if isLaunched {
                let isWatchAppReachable = WatchManager.shared.isWatchAppConnected
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
    
    // MARK: Button 액션
    @objc private func backButtonTapped() {
        // 뒤로 가기 동작
        WatchManager.shared.sendScoreSelectionToWatch(scoreTitle: "", hapticSequence: [])
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func settingButtonTapped() {
        let settingViewController = SettingViewController()
        navigationItem.title = "설정"
        navigationItem.backButtonTitle = ""
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
            self.musicPlayer.playMIDI(delay: delay + 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - 3) {
                self.showLottieAnimation()
            }
            controlButtonView.stopButton.isHidden = false
            // 워치로 play 예약 메시지 전송
        }

        controlButtonView.playPauseButton.isPlaying.toggle() // 재생/일시정지 상태 변경
    }
    
    @objc private func stopButtonTapped() {
        sendStopStatusToWatch()
        musicPlayer.stopMIDI()
        controlButtonView.playPauseButton.isPlaying = false
        controlButtonView.stopButton.isHidden = true
        WatchManager.shared.playStatus = .stop
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
        let isLaunched = await WatchManager.shared.launchWatch()

        if isLaunched {
            let scoreTitle = currentScore.title
            WatchManager.shared.sendScoreSelectionToWatch(scoreTitle: scoreTitle, hapticSequence: hapticSequence)
        }
    }
    
    // 워치로 실행 예약 메시지 전송
    func sendPlayStatusToWatch(startTimeInterVal: TimeInterval) {
        WatchManager.shared.sendPlayStatusToWatch(status: .play, startTime: startTimeInterVal)
    }
    
    // 마디 점프 메시지 전송
    func sendJumpMeasureToWatch(hapticSequence: [Double], startTimeInterVal: TimeInterval) {
        let scoreTitle = currentScore.title

        WatchManager.shared.sendJumpMeasureToWatch(scoreTitle: scoreTitle, hapticSequence: hapticSequence, status: .play, startTime: startTimeInterVal)
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
