import UIKit
import CoreData

class SettingViewController: UIViewController {
    let settingView = SettingView()
    
    // Core Data 컨텍스트
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 타이틀 설정
        self.title = "설정"
        
        // SettingView에서 이벤트를 받아서 처리
        settingView.onBPMButtonTapped = { [weak self] in
            self?.presentBPMSettingModal()
        }
        
        settingView.onSoundOptionSelected = { [weak self] selectedOption in
            guard let self = self else { return }
            // Core Data에 선택된 옵션 저장
            self.saveSoundOptionToCoreData(option: selectedOption)
        }
        
        settingView.onHapticToggleChanged = { [weak self] isOn in
            guard let self = self else { return }
            // Core Data에 토글 상태 저장
            self.saveHapticGuideStateToCoreData(isOn: isOn)
        }
        
        // Core Data에서 저장된 값을 가져와 초기 상태 설정
        if let savedOption = fetchSavedSoundOption() {
            settingView.soundSettingSection.radioButtonPicker.setSelectedValue(savedOption)
        }
        
        if let isHapticGuideOn = fetchSavedHapticGuideState() {
            settingView.hapticSettingSection.setToggleState(isOn: isHapticGuideOn)
        }
    }
    
    private func presentBPMSettingModal() {
        let bpmSettingVC = BPMSettingSectionViewController()
        bpmSettingVC.modalPresentationStyle = .pageSheet
        bpmSettingVC.currentBPM = settingView.bpmSettingSection.bpm // 현재 BPM 값 전달
        bpmSettingVC.onBPMSelected = { [weak self] selectedBPM in
            self?.settingView.bpmSettingSection.bpm = selectedBPM
            // Core Data에 BPM 값 저장
            self?.saveBPMToCoreData(bpm: selectedBPM)
        }
        present(bpmSettingVC, animated: true, completion: nil)
    }
    
    // BPM 값을 Core Data에 저장하는 메서드
    private func saveBPMToCoreData(bpm: Int) {
        // Score 엔티티 객체 가져오기 또는 생성
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            let scoreEntity: ScoreEntity
            if let existingScore = results.first {
                // 기존 객체가 있으면 업데이트
                scoreEntity = existingScore
            } else {
                // 새로운 객체 생성
                scoreEntity = ScoreEntity(context: context)
            }
            scoreEntity.bpm = Int64(bpm) // bpm 값을 저장
            
            // 변경 사항 저장
            try context.save()
            print("BPM 값이 Core Data에 저장되었습니다.")
            print("scoreEntity: \(scoreEntity)")
        } catch {
            ErrorHandler.handleError(error: "Core Data 저장 중 에러 발생: \(error)")
        }
    }
    // Core Data에 소리 옵션 저장하는 메서드
    private func saveSoundOptionToCoreData(option: String) {
        // Score 엔티티 객체 가져오기 또는 생성
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            let scoreEntity: ScoreEntity
            if let existingScore = results.first {
                // 기존 객체가 있으면 업데이트
                scoreEntity = existingScore
            } else {
                // 새로운 객체 생성
                scoreEntity = ScoreEntity(context: context)
            }
            scoreEntity.soundOption = option // soundOption 속성에 저장
            
            // 변경 사항 저장
            try context.save()
            print("소리 옵션이 Core Data에 저장되었습니다.")
            print("scoreEntity: \(scoreEntity)")
        } catch {
            ErrorHandler.handleError(error: "Core Data 저장 중 에러 발생: \(error)")
        }
    }
    
    // Core Data에서 저장된 소리 옵션 가져오기
    private func fetchSavedSoundOption() -> String? {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            if let existingScore = results.first {
                return existingScore.soundOption
            }
        } catch {
            ErrorHandler.handleError(error: "Core Data 저장 중 에러 발생: \(error)")
        }
        return nil
    }
    
    // Core Data에 진동 가이드 토글 상태 저장하는 메서드
    private func saveHapticGuideStateToCoreData(isOn: Bool) {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            let scoreEntity: ScoreEntity
            if let existingScore = results.first {
                scoreEntity = existingScore
            } else {
                scoreEntity = ScoreEntity(context: context)
            }
            scoreEntity.isHapticOn = isOn // hapticGuideOn 속성에 저장
            
            try context.save()
            print("진동 가이드 토글 상태가 Core Data에 저장되었습니다.")
            print("scoreEntity: \(scoreEntity)")
        } catch {
            ErrorHandler.handleError(error: "Core Data 저장 중 에러 발생: \(error)")
        }
    }
    
    // Core Data에서 저장된 진동 가이드 토글 상태 가져오기
    private func fetchSavedHapticGuideState() -> Bool? {
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            if let existingScore = results.first {
                return existingScore.isHapticOn
            }
        } catch {
            ErrorHandler.handleError(error: "Core Data 저장 중 에러 발생: \(error)")
        }
        return nil
    }
    
}
