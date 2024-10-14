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
    private var timers: [DispatchSourceTimer] = [] //햅틱 타임스케쥴러 관리 배열
    private var isHapticActive = false // 시작여부 관리
    private var currentBatchIndex = 0 // 현재 실행 중인 배치 인덱스
    var beatTimes: [Double] = []
    
    //햅틱 시작 전 haptic 셋팅 필요
    func starHaptic(beatTime: [Double]) {
        setBeatTime(beatTime: beatTime)
        startExtendedSession()
    }

    //MARK: WKExtendedRuntimeSession 로직
    //백그라운드에서 햅틱 적용을 위해 WKExtendedRuntimeSession 사용
    private func startExtendedSession() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }

    // WKExtendedRuntimeSessionDelegate methods
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended session started")
        if !isHapticActive {
            scheduleNextBatch(batchSize: 10)
            isHapticActive = true
        }
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended session will expire soon")
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?) {
        print("Extended session invalidated")
    }
    
    //MARK: Haptic 관리 로직
    func setBeatTime(beatTime: [Double]) {
        beatTimes = beatTime
    }
    
    //메트로놈 로직
    func startHapticWithTempo(tempo: Double) {
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
    
    // 햅틱과 타이머를 중지하는 함수
    func stopHaptic() {
        // 배열에 저장된 모든 타이머를 해제
        for timer in timers {
            timer.cancel()
        }
        timers.removeAll()  // 배열 비우기
        isHapticActive = false
    }
    // 하드코딩된 비트 타이밍에 따라 배치로 나누어 타이머 실행
    func startHapticWithHardCodedBeats(batchSize: Int) {
        stopHaptic()  // 이전 타이머가 있으면 정지
        currentBatchIndex = 0 // 배치 인덱스 초기화
        isHapticActive = true
        scheduleNextBatch(batchSize: batchSize) // 첫 번째 배치 실행
    }
    
    //timer가 밀리는 것 같아서 10개씩 나눠서 진행시켜봄
    func scheduleNextBatch(batchSize: Int) {
        let startIndex = currentBatchIndex * batchSize
        let endIndex = min(startIndex + batchSize, beatTimes.count)
        
        // 배치 내에서 타이머 실행
        var playtime = 0.0
        for i in startIndex..<endIndex {
            let beatTime = beatTimes[i]
            let interval = convertBeatTime(beatTime: beatTime)
            print("현재 타이머 실행 시간: \(playtime), 이전 타이머와의 간격: \(interval)초")

            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + playtime, leeway: .milliseconds(50))
            timer.setEventHandler {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.start)
                }
            }
            timer.resume()
            playtime += interval // 다음 플레이 타임으로 업데이트
            timers.append(timer)
        }

        // 다음 배치가 있는지 확인
        if endIndex < beatTimes.count {
            currentBatchIndex += 1
            let nextBatchDelay = playtime // 마지막 타이머까지의 시간
            let batchTimer = DispatchSource.makeTimerSource()
            batchTimer.schedule(deadline: .now() + nextBatchDelay, leeway: .milliseconds(50))
            batchTimer.setEventHandler {
                DispatchQueue.main.async {
                    print("나머지 실행: \(endIndex)부터")

                    self.scheduleNextBatch(batchSize: batchSize) // 다음 배치 실행
                }
            }
            batchTimer.resume()
            timers.append(batchTimer)
        } else {
            isHapticActive = false // 모든 배치가 완료된 경우
        }
    }
    
    func convertBeatTime(beatTime: Double) -> Double {
        let convertBeatTime = beatTime / (120 / 60)/*기준 BPM 60*/
        
        return convertBeatTime
    }
}
