//
//  AppDelegate.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/5/24.
import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let scoreService = ScoreService()
    var deviceToken: Data? 
    
    // MARK: - 앱 실행시 더미 데이터 삽입
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Push Notification 권한 요청
        registerForPushNotifications()
        return true
    }
    
    // MARK: - Push Notification 권한 동의
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                ErrorHandler.handleError(error: "Push Notification 권한 거부: \(error?.localizedDescription ?? "Unknown error")")
                
            }
        }
    }
    
    func application(_ application: UIApplication,
         didReceiveRemoteNotification userInfo: [AnyHashable: Any],
         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Silent Push Notification processing
    if let silentNotification = userInfo["aps"] as? [String: AnyObject],
       silentNotification["content-available"] as? Int == 1 {
        // badge 관련 userDefault값 업데이트
        UserDefaults.standard.set(true, forKey: "isBadgeOn")
    }
        // 백그라운드 operation 종료
    completionHandler(.noData)
    }
    
    // MARK: - Remote Notification 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken // deviceToken 저장
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
        
        // Token 암호화 및 서버 전송
        do {
            let encryptedToken = try AES256Cryption.encrypt(string: tokenString)
            sendDeviceTokenToServer(encryptedToken)
        } catch {
            print("Device Token 암호화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Remote Notification 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ErrorHandler.handleError(error: "Remote Notification 등록 실패: \(error.localizedDescription)")
    }
    
    // MARK: - 서버로 Device Token 전송
    private func sendDeviceTokenToServer(_ encryptedToken: String) {
        // 서버로 전송하는 로직 추가
        print("암호화된 Device Token 서버로 전송: \(encryptedToken)")
        // TODO: ServerManager를 통해 서버에 전송 로직 구현
    }
    
    
    // Core Data 저장 함수
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // 에러 처리
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RhythmTokTok")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
