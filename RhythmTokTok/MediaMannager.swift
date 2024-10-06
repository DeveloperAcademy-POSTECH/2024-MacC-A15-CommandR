//
//  MediaMannager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import AudioKit
import AVFoundation

struct MediaMannager {
    
    func getMediaFile(xmlData: Data) {
        Task {
            let parsedMeasures = await parseMusicXMLData(xmlData: xmlData)
        }
    }
    
    func parseMusicXMLData(xmlData: Data) async -> [Measure]{
        
        let parser = MusicXMLParser()
        let measures = await parser.parseMusicXML(from: xmlData)
        
        // 파싱이 완료된 후에 작업을 처리, 확인용 프린트
//        print("Parsed measures count: \(measures.count)")
//        for measure in measures {
//            for note in measure.notes {
//                print("Pitch: \(note.pitch), Duration: \(note.duration)")
//            }
//        }
//        
        return measures
    }
}
