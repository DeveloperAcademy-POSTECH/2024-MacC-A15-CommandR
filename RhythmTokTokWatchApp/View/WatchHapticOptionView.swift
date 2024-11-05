//
//  WatchHapticOptionView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 11/5/24.
//

import SwiftUI
import WatchKit

//MARK: - 워치 햅틱 세기 테스트를 위한 테스트뷰
struct WatchHapticOptionView: View {
    @EnvironmentObject var connectivityManager: WatchtoiOSConnectivityManager
    @State private var selectedHapticType: WKHapticType = .start
    
    // 선택 가능한 모든 햅틱 타입을 나열 (유효한 타입만 포함)
    let hapticTypes: [WKHapticType] = [
        .start,
        .notification,
        .directionUp,
        .directionDown,
        .success,
        .stop,
        .failure,
        .retry,
        .click
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Haptic Type", selection: $selectedHapticType) {
                    ForEach(hapticTypes, id: \.self) { haptic in
                        Text(hapticDisplayName(for: haptic))
                            .tag(haptic)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .onChange(of: selectedHapticType) { newValue in
                    connectivityManager.hapticManager.setHapticType(type: newValue)
                    WKInterfaceDevice.current().play(newValue) // 선택 즉시 피드백 제공
                }
                .padding()
                
                Text("선택된 햅틱 타입: \(hapticDisplayName(for: selectedHapticType))")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Haptic Selection")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    // 햅틱 타입에 따른 표시 이름 반환
    func hapticDisplayName(for type: WKHapticType) -> String {
        switch type {
        case .start:
            return "Start"
        case .stop:
            return "Stop"
        case .click:
            return "Click"
        case .directionUp:
            return "Direction Up"
        case .directionDown:
            return "Direction Down"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .retry:
            return "Retry"
        case .notification:
            return "Notification"
        @unknown default:
            return "Unknown"
        }
    }
}
//
// struct HapticSelectionView_Previews: PreviewProvider {
//     static var previews: some View {
//         HapticSelectionView()
//             .environmentObject(WatchtoiOSConnectivityManager())
//     }
// }
