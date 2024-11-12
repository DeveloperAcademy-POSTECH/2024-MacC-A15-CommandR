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
            if count == 0 {
                // 예시 사용
                if let directoryPath = Bundle.main.resourcePath {
                    let dummyScoresPath = "\(directoryPath)/DummyScores"
                    if let fileNames = getFileNames(in: dummyScoresPath) {
                        print("Files in DummyScores:", fileNames)
                        
                        for fileName in fileNames {
                            // TODO: - Note 데이터 넣어야 함
                            // Score - Part [Measure]
                            insertDummyScoreEntity(context: context, title: fileName)
                        }
                    }
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
    
    // 특정디렉토리에 있는 파일명 전부 가져오기
    static func getFileNames(in directoryPath: String) -> [String]? {
        let fileManager = FileManager.default
        var fileNames = [String]()
        
        do {
            // 지정된 디렉토리의 모든 파일 목록을 가져옴
            let items = try fileManager.contentsOfDirectory(atPath: directoryPath)
            
            // 각 파일의 이름을 배열에 추가
            for item in items {
                let itemPath = directoryPath + "/" + item
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory), !isDirectory.boolValue {
                    fileNames.append(item) // 파일명만 추가
                }
            }
            
            return fileNames
        } catch {
            print("디렉토리 읽기 오류: \(error)")
            return nil
        }
    }
}
