//
//  CoreDataHelper.swift
//  RhythmTokTok
//
//  Created by 백록담 on 11/7/24.
//
import UIKit
import CoreData

class CoreDataHelper {
    
    // MARK: - data가 있는지 확인하고 없는 경우 더미데이터를 넣는다
    static func checkAndInsertDummyData(_ context: NSManagedObjectContext) {
        // Fetch existing data to check if dummy data is needed
        let fetchRequest: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            print("count : \(count)")
            if count == 0 { // swiftlint:disable:this empty_count
                // 예시 사용
                if let filePaths = Bundle.main.urls(forResourcesWithExtension: "xml", subdirectory: "DummyScores") {
                    for fileURL in filePaths {
                        let fileName = fileURL.deletingPathExtension().lastPathComponent
                        print("File Name: \(fileName)")
                        insertDummyScoreEntity(context: context, title: fileName)
                    }
                } else {
                    print("File not found")
                }
            }
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    // 더미악보 정보 insert
    static func insertDummyScoreEntity(context: NSManagedObjectContext, title: String) {
        // 더미 데이터 생성 예제
        let newScore = ScoreEntity(context: context)
        newScore.bpm = 60
        newScore.createdAt = Date()
        newScore.id = UUID().uuidString
        newScore.title = title
        newScore.isHapticOn = true
        // 저장
        do {
            try context.save()
            print("Dummy data inserted successfully.")
        } catch {
            print("Failed to save dummy data: \(error)")
        }
    }
    
    // 폴더 내 파일 이름 가져오기
    static func getFileNames(in directoryName: String) -> [String]? {
        guard let resourceURL = Bundle.main.resourceURL else {
            print("리소스 URL을 가져올 수 없습니다.")
            return nil
        }
        
        // DummyScores 폴더의 URL 구성
        let folderURL = resourceURL.appendingPathComponent(directoryName)
        let fileManager = FileManager.default
        do {
            // 폴더 내 모든 파일의 URL 가져오기
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // 파일 이름만 추출하여 배열에 저장
            let fileNames = fileURLs.map { $0.lastPathComponent }
            return fileNames
        } catch {
            print("디렉토리 읽기 오류: \(error.localizedDescription)")
            return nil
        }
    }
}
