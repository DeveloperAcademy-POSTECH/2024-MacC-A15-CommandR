import Foundation

class UserSettingData {
    
    static let shared = UserSettingData()
    
//    private var currentScore: ScoreSetting = ScoreSetting(title: currentScoreTitle, bpm: getBPM(), soundOption: getSoundOption(), isHapticOn: getIsHapticOn())
    
    private var currentScore: ScoreSetting = ScoreSetting(title: "", bpm: 0, soundOption: .voice, isHapticOn: false)
    var currentScoreTitle = ""
    
    // 악보별 세팅 데이터 구조 + 기본값 설정
    struct ScoreSetting: Codable {
        var title: String
        var bpm: Int
        var soundOption: SoundSetting
        var isHapticOn: Bool
    }
    
    private init() {
        print("UserSettingData init")
    }
    
    // 악보 Key 설정
    func setCurrentScoreTitle(_ scoreTitle: String) {
        currentScore.title = scoreTitle
        currentScoreTitle = currentScore.title
        print("currentScoreTitle: \(currentScoreTitle)")
        
        let allSettings = getAllSettings()
        if allSettings[scoreTitle] == nil {
            
            print("loadSetting: \(scoreTitle) not found")
            let newSetting = ScoreSetting(title: scoreTitle, bpm: 120, soundOption: .melody, isHapticOn: true) // 기본값 설정
            saveSetting(for: scoreTitle, setting: newSetting)
        }
    }

    // 악보별 BPM 설정
    func setBPM(bpm: Int) {
        var setting = loadSetting(for: currentScoreTitle)
        setting.bpm = min(max(bpm, 20), 208)
        saveSetting(for: currentScoreTitle, setting: setting)
    }
    
    func getBPM() -> Int {
        return loadSetting(for: currentScoreTitle).bpm
    }
    
    // 악보별 SoundOption 설정
    func setSoundOption(soundOption: SoundSetting) {
        var setting = loadSetting(for: currentScoreTitle)
        setting.soundOption = soundOption
        saveSetting(for: currentScoreTitle, setting: setting)
    }
    
    func getSoundOption() -> SoundSetting {
        return loadSetting(for: currentScoreTitle).soundOption
    }
    
    // 악보별 Haptic 설정
    func setIsHapticOn(isHapticOn: Bool) {
        var setting = loadSetting(for: currentScoreTitle)
        setting.isHapticOn = isHapticOn
        saveSetting(for: currentScoreTitle, setting: setting)
    }
    
    func getIsHapticOn() -> Bool {
        return loadSetting(for: currentScoreTitle).isHapticOn
    }
    
    // 악보별 세팅 저장 및 불러오기
    
    // 한번 다 불러서 타이틀에 맞는 객체 있으면 리턴
    private func loadSetting(for scoreTitle: String) -> ScoreSetting {
        let allSettings = getAllSettings()
        if let setting = allSettings[scoreTitle] {
//            print("loadSetting: \(scoreTitle)")
            return setting
        }
        print("loadSetting: \(scoreTitle) not found")
        return ScoreSetting(title: currentScoreTitle, bpm: 120, soundOption: .melody, isHapticOn: true) // 기본값 설정
    }
    
    // 한번 다 불러서 타이틀에 맞는 객체 있으면 업데이트
    private func saveSetting(for scoreTitle: String, setting: ScoreSetting) {
        var allSettings = getAllSettings()
        allSettings[scoreTitle] = setting
        saveAllSettings(allSettings)
    }
    
    // 실제로 저장하는 로직
    private func getAllSettings() -> [String: ScoreSetting] {
        if let data = UserDefaults.standard.data(forKey: currentScore.title),
           let settings = try? JSONDecoder().decode([String: ScoreSetting].self, from: data) {
            return settings
        }
        return [:] // 기본값: 빈 딕셔너리
    }
    
    private func saveAllSettings(_ settings: [String: ScoreSetting]) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: currentScore.title)
        }
    }
    
}
