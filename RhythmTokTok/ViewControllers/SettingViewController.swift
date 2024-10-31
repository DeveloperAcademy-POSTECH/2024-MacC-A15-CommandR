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
        
        // SettingView에서 이벤트를 받아서 처리
        settingView.onBPMButtonTapped = { [weak self] in
            self?.presentBPMSettingModal()
        }
    }
    
    private func presentBPMSettingModal() {
        let bpmSettingVC = BPMSettingViewController()
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
}
