//
//  HapticScheduleManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/14/24.
//

import Combine
import UserNotifications
import WatchConnectivity
import WatchKit

class HapticScheduleManager: NSObject, ObservableObject {
    @Published var isHapticActive: Bool = false
    @Published var hapticType: WKHapticType = .start // 선택된 햅틱 타입

    private var timers: [DispatchSourceTimer] = [] // 햅틱 타임스케쥴러 관리 배열
    private var currentBatchIndex = 0 // 현재 실행 중인 배치 인덱스
//    private var hapticType: WKHapticType = .start
    private var beatTimes: [Double] = []
    private var startTimeInterval: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    func setupHapticActivationListener() {
        self.$isHapticActive
            .sink { [weak self] isStarted in
                if isStarted {
                    guard let self = self else {
                        return
                    }
                    
                    let scheduledTime = Date(timeIntervalSince1970: startTimeInterval)
                                        
                    // Timer를 사용하여 예약된 시간에 실행
                    let timer = Timer(fireAt: scheduledTime, interval: 0, target: self, selector: #selector(self.triggerHaptic), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                }
            }
            .store(in: &cancellables)
    }
    
    func cancelHapticSubscriptions() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        print("All haptic subscriptions canceled")
    }
    
    // 타이머가 호출할 메서드
    @objc private func triggerHaptic() {
        startHapticWithBeats(batchSize: 100)
    }
        
    // MARK: Haptic 관리 로직
    // 리듬 햅틱 시작
    func startHaptic(beatTime: [Double], startTimeInterval: TimeInterval) {
        setBeatTime(beatTime: beatTime)
        self.startTimeInterval = startTimeInterval
        self.isHapticActive = true
    }
    
    // 햅틱 타입 설정
    func setHapticType(type: WKHapticType) {
        hapticType = type
    }
    
    private func setBeatTime(beatTime: [Double]) {
        beatTimes = beatTime
    }
    
    // 메트로놈 로직
    private func startHapticWithTempo(tempo: Double) {
        stopHaptic()  // 이전 타이머가 있으면 정지

        // 햅틱 주기 계산 (60초를 BPM으로 나눔)
        let interval = 60.0 / tempo
        
        // DispatchSourceTimer를 사용하여 주기적으로 햅틱을 울림
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(50))
        timer.setEventHandler {
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(self.hapticType) // 선택된 햅틱 타입 적용
            }
        }
        timer.resume()
        timers.append(timer)
    }
    
    // 타이밍에 따라 햅틱 시퀀스 배치로 나누어 타이머 실행
    private func startHapticWithBeats(batchSize: Int) {
        stopHaptic()  // 이전 타이머가 있으면 정지
        currentBatchIndex = 0 // 배치 인덱스 초기화
        scheduleNextBatch(batchSize: batchSize) // 첫 번째 배치 실행
    }
    
    func scheduleNextBatch(batchSize: Int) {
        let currentBatch = Array(beatTimes.prefix(batchSize))  // 현재 배치만큼 가져옴
        
        for beatTime in currentBatch {
//            print("타이머 설정 시간: \(beatTime)초")

            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + beatTime, leeway: .milliseconds(1))
            timer.setEventHandler {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(self.hapticType)  // 선택된 햅틱 타입 적용
                }
            }
            timer.resume()
            timers.append(timer)
        }

        // 배열에서 이미 처리한 배치를 제거
        beatTimes = Array(beatTimes.dropFirst(batchSize))
        // 다음 배치가 있는지 확인
        if !beatTimes.isEmpty {
            let nextBatchDelay = currentBatch.last ?? 0  // 마지막 타이머까지의 시간
            // 남아있는 beatTimes 배열에서 nextBatchDelay 값을 빼줌
            beatTimes = beatTimes.map { $0 - nextBatchDelay }

            let batchTimer = DispatchSource.makeTimerSource()
            batchTimer.schedule(deadline: .now() + nextBatchDelay, leeway: .milliseconds(1))
            batchTimer.setEventHandler {
                DispatchQueue.main.async {
                    self.scheduleNextBatch(batchSize: batchSize) // 재귀로 다음 배치 실행
                }
            }
            batchTimer.resume()
            timers.append(batchTimer)
        } else {
            self.isHapticActive = false // 모든 배치가 완료된 경우
        }
    }
    
    // 햅틱과 타이머를 중지하는 함수
    func stopHaptic() {
        // 배열에 저장된 모든 타이머를 해제
        for timer in timers {
            timer.cancel()
        }
        timers.removeAll()  // 배열 비우기
        self.isHapticActive = false
    }
}
