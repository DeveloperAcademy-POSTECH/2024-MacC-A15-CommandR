//
//  HapticScheduleManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/14/24.
//

import UserNotifications
import WatchConnectivity
import WatchKit

class HapticScheduleManager: NSObject, WKExtendedRuntimeSessionDelegate {
    private var session: WKExtendedRuntimeSession?
    private var timers: [DispatchSourceTimer] = [] // 햅틱 타임스케쥴러 관리 배열
    private var isHapticActive = false // 시작여부 관리
    private var currentBatchIndex = 0 // 현재 실행 중인 배치 인덱스
    private var hapticType: WKHapticType = .start
    private var beatTimes: [Double] = []
    private var startTimeInterval: TimeInterval = 0

    // MARK: WKExtendedRuntimeSession 로직
    // 백그라운드에서 햅틱 적용을 위해 WKExtendedRuntimeSession 사용
    private func startExtendedSession() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }

    // WKExtendedRuntimeSessionDelegate methods
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended session started")
        if !isHapticActive {
            let currentTimestamp = Date().timeIntervalSince1970
            let delay = startTimeInterval - currentTimestamp
            // 햅틱 시작 예약
            print("delay 시간 : \(delay)")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.startHapticWithHardCodedBeats(batchSize: 20)
            }
        }
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended session will expire soon")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: (any Error)?) {
        print("Extended session invalidated")
    }
        
    // MARK: Haptic 관리 로직
    // 리듬 햅틱 시작
    func startHaptic(beatTime: [Double], startTimeInterval: TimeInterval) {
        isHapticActive = false // 시작여부 초기화
        setBeatTime(beatTime: beatTime)
        self.startTimeInterval = startTimeInterval
        startExtendedSession()
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
                WKInterfaceDevice.current().play(.start) // 선택된 햅틱 타입 적용
            }
        }
        timer.resume()
        timers.append(timer)
        
        isHapticActive = true
    }
    
    // 타이밍에 따라 햅틱 시퀀스 배치로 나누어 타이머 실행
    private func startHapticWithHardCodedBeats(batchSize: Int) {
        stopHaptic()  // 이전 타이머가 있으면 정지
        currentBatchIndex = 0 // 배치 인덱스 초기화
        isHapticActive = true
        scheduleNextBatch(batchSize: batchSize) // 첫 번째 배치 실행
    }
    
    func scheduleNextBatch(batchSize: Int) {
        let currentBatch = Array(beatTimes.prefix(batchSize))  // 현재 배치만큼 가져옴
        
        for beatTime in currentBatch {
            print("타이머 설정 시간: \(beatTime)초")

            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + beatTime, leeway: .milliseconds(1))
            timer.setEventHandler {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.start)  // 햅틱 실행
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
            isHapticActive = false // 모든 배치가 완료된 경우
        }
    }
    
    // 햅틱과 타이머를 중지하는 함수
    func stopHaptic() {
        // 배열에 저장된 모든 타이머를 해제
        for timer in timers {
            timer.cancel()
        }
        timers.removeAll()  // 배열 비우기
        isHapticActive = false
    }
}
