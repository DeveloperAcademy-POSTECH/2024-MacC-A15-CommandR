import UIKit
import CoreData
import SwiftUICore

class SettingViewController: UIViewController {
    var currentScore: Score
    
    var dimmedBackgroundView: UIView?
    let settingView = SettingView()
    
    // Core Data 컨텍스트
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Score CRUD
    let scoreService = ScoreService()
    
    // 미리듣기 플레이어
    private var musicPlayer = MusicPlayer()
    
    // MARK: - init
    init(currentScore: Score) {
        self.currentScore = currentScore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰 생명주기
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings() // 초기값 로드하여 SettingView에 반영
        
        // [BPM 버튼] 탭 시 BPM 설정 모달창을 띄우는 액션 설정
        settingView.onBPMButtonTapped = { [weak self] in
            self?.presentBPMSettingModal()
        }
        
        // [미리듣기 버튼] 탭 시 미리듣기 액션 설정
        settingView.soundKeySettingSection.audioPreviewButton.onAudioPreviewButtonTapped = { [weak self] in
            self?.playPreviewScore()
        }
        
        // [설정 완료 버튼] 탭 시 액션 설정
        settingView.onSettingDoneButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            // SettingView의 값들을 currentScore에 반영
            self.currentScore.bpm = self.settingView.bpmSettingSection.bpm
            self.currentScore.soundOption = SoundSetting(rawValue: self.settingView.soundSettingSection.selectedOption) ?? .melodyBeat
            self.currentScore.soundKeyOption = self.settingView.soundKeySettingSection.currentSoundKey
            self.currentScore.hapticOption = self.settingView.hapticSettingSection.isToggleOn
            
            // currentScore에 반영된 값을 Core Data에 저장
            self.saveChangesToCoreData()
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - [Ext] Data 관련
extension SettingViewController {
    // 초기 세팅
    private func loadInitialSettings() {
        // 초기값을 SettingView에 반영
        settingView.bpmSettingSection.bpm = currentScore.bpm
        settingView.soundSettingSection.setSelectedOption(currentScore.soundOption.rawValue)
        settingView.soundKeySettingSection.currentSoundKey = currentScore.soundKeyOption
        settingView.hapticSettingSection.setToggleState(isOn: currentScore.hapticOption)
    }
    
    // 수정 사항 저장
    private func saveChangesToCoreData() {
        scoreService.updateScore(withId: currentScore.id) { scoreEntity in
            scoreEntity.bpm = Int64(currentScore.bpm)
            scoreEntity.soundOption = currentScore.soundOption.rawValue
            scoreEntity.soundKeyOption = currentScore.soundKeyOption
            scoreEntity.isHapticOn = currentScore.hapticOption
        }
    }
}

// MARK: - [Ext] BPM 설정 모달 관련
extension SettingViewController: BPMSettingDelegate {
    private func presentBPMSettingModal() {
        // BPM 세팅 올라올 때 어두운 오버레이 뷰 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            dimmedBackgroundView = UIView(frame: view.bounds)
            dimmedBackgroundView?.backgroundColor = UIColor(named: "modal")
            dimmedBackgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dimmedBackgroundView!)
        }
        
        let bpmSettingVC = BPMSettingSectionViewController()
        
        bpmSettingVC.modalPresentationStyle = .pageSheet
        bpmSettingVC.delegate = self
        bpmSettingVC.currentBPM = settingView.bpmSettingSection.bpm // 현재 BPM 값 전달
        bpmSettingVC.onBPMSelected = { [weak self] selectedBPM in
            self?.settingView.bpmSettingSection.bpm = selectedBPM
        }
        present(bpmSettingVC, animated: true, completion: nil)
    }
    
    func removeOverlay() {
        dimmedBackgroundView?.removeFromSuperview()
    }
}

// MARK: - [Ext] 키 조절 미리 듣기 관련
extension SettingViewController {
    private func playPreviewScore() {
        Task {
            let mediaManager = MediaManager()
            let midiFilePathURL = try await mediaManager.getPartPreviewMIDIFile(part: currentScore.parts.last!,
                                                                         divisions: currentScore.divisions,
                                                                         isChordEnabled: false)
            // MIDI 파일 로드
            musicPlayer.loadMIDIFile(midiURL: midiFilePathURL)
            musicPlayer.playPreviewMIDI()
        }
    }
}
