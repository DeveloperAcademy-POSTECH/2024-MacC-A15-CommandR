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

class MeasureViewModel: ObservableObject {
    @Published var selectedMeasures: (Int, Int) = (-2, -2)
}

class MusicPracticeViewController: UIViewController {
    private var viewModel = MeasureViewModel()  // 선택구간 ObservableObject 생성
    private var cancellables = Set<AnyCancellable>()  // Combine에서 구독을 관리할 Set
    private var animationView: LottieAnimationView? // 로띠뷰

    var currentScore: Score // 현재 악보 score
    var totalMeasure = 0
    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var mediaManager = MediaManager()
    let practicNavBar = PracticeNavigationBar()
    let musicPracticeTitleView = MusicPracticeTitleView()
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 선의 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bpmButton = BPMButton()
    let currentMeasureLabel = UILabel()
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
    // SwiftUI 뷰를 UIHostingController로 감싸기
    private var hostingController: UIHostingController<ScoreView>?
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
        totalMeasure = mediaManager.getMainPartMeasureCount(score: currentScore)
        Task {
            await createMIDIFile(score: currentScore)
        }
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()    }
    
    private func setupUI() {
        musicPracticeTitleView.titleLabel.text = currentScore.title
        bpmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bpmButton)
        // 현재 진행 중인 마디 표시 라벨
        currentMeasureLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentMeasureLabel)

        hostingController = UIHostingController(rootView: ScoreView(viewModel: viewModel, currentScore: currentScore))
        // hostingController의 뷰를 추가하기
        if let hostingView = hostingController?.view {
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingView)
        }

        // 버튼을 뷰에 추가
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playPauseButton)
        // resume 버튼 추가
        view.addSubview(stopButton)
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
            musicPracticeTitleView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            musicPracticeTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            musicPracticeTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            musicPracticeTitleView.heightAnchor.constraint(equalToConstant: 38),
            
            // BPM 버튼
            bpmButton.topAnchor.constraint(equalTo: musicPracticeTitleView.bottomAnchor, constant: 20),
            bpmButton.heightAnchor.constraint(equalToConstant: 48),
            bpmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // 현재 진행 중인 마디 라벨
            currentMeasureLabel.topAnchor.constraint(equalTo: musicPracticeTitleView.bottomAnchor, constant: 20),
            currentMeasureLabel.heightAnchor.constraint(equalToConstant: 48),
            currentMeasureLabel.leadingAnchor.constraint(equalTo: bpmButton.trailingAnchor, constant: 60),

            // ScoreView
            hostingController!.view.topAnchor.constraint(equalTo: bpmButton.bottomAnchor, constant: 20),
            hostingController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hostingController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hostingController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20),
                
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
        practicNavBar.settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
//        bpmButton.addTarget(self, action: #selector(presentBPMModal), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        // ViewModel의 상태 변화를 구독하여 특정 함수 호출
        viewModel.$selectedMeasures
            .sink { [weak self] selectedMeasures in
                self?.handleMeasuresChange(selectedMeasures)
            }
            .store(in: &cancellables)  // 메모리에서 자동 해제될 수 있도록 구독을 저장
        
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
        let currentMeasure = mediaManager.getCurrentMeasureNumber(currentTime: currentTime, division: division)
        
        currentMeasureLabel.text = "\(currentMeasure)/\(totalMeasure)마디"
    }
    
    // 상태 변화에 따라 호출되는 함수
    private func handleMeasuresChange(_ selectedMeasures: (Int, Int)) {
        var startMeasureNumber = selectedMeasures.0
        var endMeasureNumber = selectedMeasures.1
        
        // TODO: 더 좋은 방법 구상하기, 처음 시작시 무시
        if viewModel.selectedMeasures == (-2, -2) {
            return
        }
        
        if let part = currentScore.parts.last,
           let firstMeasure = part.measures.min(by: { $0.key < $1.key })?.value.first {
            if firstMeasure.number != 0 {
                startMeasureNumber += 1
                endMeasureNumber += 1
            }
        }
        if selectedMeasures == (-1, -1) {
            Task {
                await createMIDIFile(score: currentScore)
            }
        } else {
            // 구간 미디파일 생성
            Task {
                await createMIDIFile(score: currentScore,
                                     startMeasureNumber: startMeasureNumber, endMeasureNumber: endMeasureNumber)
            }
        }
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
            // MIDI 재생
            // TODO: 딜레이 조절해야됨
            self.musicPlayer.playMIDI(delay: delay + 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay - 3) {
                self.showLottieAnimation()
            }
            stopButton.isHidden = false
            // 워치로 play 예약 메시지 전송
        }
//        playPauseButton.isPlaying.toggle() // 재생/일시정지 상태 변경
        if WatchManager.shared.playStatus == .play {
            // 현재 재생 중이면 일시정지로 변경
            WatchManager.shared.playStatus = .pause
        } else {
            // 재생 상태로 변경
            WatchManager.shared.playStatus = .play
        }
    }
    
    @objc private func stopButtonTapped() {
        sendStopStatusToWatch()
        musicPlayer.stopMIDI()
        playPauseButton.isPlaying = false
        stopButton.isHidden = true
        WatchManager.shared.playStatus = .stop
    }
    
    @objc private func presentBPMModal() {
        let setBPMViewController = SetBPMViewController()
        present(setBPMViewController, animated: true, completion: nil)
    }
    
    // 시작 버튼 활성화 업데이트
    private func updatePlayPauseButton(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.playPauseButton.isEnabled = isEnabled
        }
    }
    
    // 임시 픽커 업데이트
    private func updateScore(score: Score) {
        currentScore = score
        pickerView.reloadAllComponents() // 데이터를 받아오면 Picker 업데이트
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
      
      // 워치로 일시정지 예약 메시지 전송
      func sendPauseStatusToWatch() {
          WatchManager.shared.sendPlayStatusToWatch(status: .pause, startTime: nil)
      }
      
      // 워치로 멈추고 처음으로 대기 메시지 전송
      func sendStopStatusToWatch() {
          WatchManager.shared.sendPlayStatusToWatch(status: .stop, startTime: nil)
      }
  }

// MARK: - Play Status Handling Extension

extension MusicPracticeViewController {
    func handlePlayStatusChange(_ status: PlayStatus) {
        switch status {
        case .ready:
            // 준비 상태: 재생 버튼만 표시
            playPauseButton.isHidden = false
            playPauseButton.isPlaying = false
            stopButton.isHidden = true
        case .play:
            // 재생 상태: 일시정지 버튼 표시
            playPauseButton.isHidden = false
            playPauseButton.isPlaying = true
            stopButton.isHidden = false
            // MIDI 재생 시작
            startMIDIPlayback()
        case .pause:
            // 일시정지 상태: 재생 버튼 표시
            playPauseButton.isHidden = false
            playPauseButton.isPlaying = false
            stopButton.isHidden = false
            // MIDI 일시정지
            musicPlayer.pauseMIDI()
        case .stop:
            // 정지 상태: 재생 버튼만 표시
            playPauseButton.isHidden = false
            playPauseButton.isPlaying = false
            stopButton.isHidden = true
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


//extension MusicPracticeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//    // UIPickerViewDataSource 프로토콜
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 2 // UIPickerView의 열 수
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        let totalMeasuresCount = currentScore.parts.last?.measures.values.reduce(0) { total, measuresArray in
//            total + measuresArray.count
//        } ?? 0
//        
//        return totalMeasuresCount
//    }
//    
//    // UIPickerViewDelegate 프로토콜
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        // parts.last의 모든 키와 마디 넘버를 추출한 배열을 만들기
//        let measureDetails = currentScore.parts.last?.measures.flatMap { (lineNumber, measures) in
//            measures.map { measure in
//                (lineNumber: lineNumber, measureNumber: measure.number)
//            }
//        }.sorted(by: { $0.measureNumber < $1.measureNumber }) ?? []
//        
//        // 해당 행(row)에 해당하는 마디 넘버와 키 반환
//        if row < measureDetails.count {
//            let detail = measureDetails[row]
//            return "줄 \(detail.lineNumber): 마디 \(detail.measureNumber)"  // lineNumber와 measureNumber 함께 표시
//        } else {
//            return ""
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // parts.last의 모든 lineNumber와 마디 넘버를 추출한 배열을 만듦
//        let measureDetails = currentScore.parts.last?.measures.flatMap { (lineNumber, measures) in
//            measures.map { measure in
//                (lineNumber: lineNumber, measureNumber: measure.number)
//            }
//        }.sorted(by: { $0.measureNumber < $1.measureNumber }) ?? []
//        
//        // 첫 번째 열(0): lineNumber, 두 번째 열(1): measureNumber
//        switch component {
//        case 0:
//            // 첫 번째 열에서 선택된 row (lineNumber 처리)
//            if row < measureDetails.count {
//                startMeasureNumber = measureDetails[row].measureNumber
//                print("Selected StartMeasure: \(startMeasureNumber)")
//            }
//        case 1:
//            // 두 번째 열에서 선택된 row (measureNumber 처리)
//            if row < measureDetails.count {
//                endMeasureNumber = measureDetails[row].measureNumber
//                print("Selected EndMeasure: \(endMeasureNumber)")
//                // 구간 미디파일 생성
//                Task {
//                    if startMeasureNumber < endMeasureNumber {
//                        await createMIDIFile(score: currentScore, startMeasureNumber: startMeasureNumber, endMeasureNumber: endMeasureNumber)
//                    }
//                }
//            }
//        default:
//            break
//        }
//    }
//}
