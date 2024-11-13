//
//  ServerManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//
import UIKit

class ServerManager {
    static let shared = ServerManager()
    private init() {}

    private let serverBaseURL = "http://211.188.50.151" // 서버 IP 주소로 변경 필요
    
    // deviceID를 가져오는 메서드
    private func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    // 1. PDF 업로드 기능
    func uploadPDF(deviceID: String, title: String, pdfFileURL: URL, page: Int, completion: @escaping (Int, String) -> Void) {
//        let deviceID = getDeviceUUID()
        let deviceID = "your_device_id"
        let url = URL(string: "\(serverBaseURL)/api/score")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 기기정보
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"device_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(deviceID)\r\n".data(using: .utf8)!)
        
        // 곡 제목
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)
        
        //  PDF 페이지 수
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"page\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(page)\r\n".data(using: .utf8)!)
        
        // PDF 파일
        let filename = pdfFileURL.lastPathComponent
        let mimeType = "application/pdf"
        do {
            let pdfData = try Data(contentsOf: pdfFileURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"pdf_file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(pdfData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            ErrorHandler.handleError(error: error)
            completion(0, "Failed to load PDF file")
            return
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                ErrorHandler.handleError(error: error)
                completion(0, "Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                let data: [[String: Any]] = [
                    ["id": "1", "title": "Sample Score 1", "status": 1, "message" : "OK"],
                    ["id": "2", "title": "Sample Score 2", "status": 2, "message" : "OK"],
                    ["id": "3", "title": "Sample Score 3", "status": 0, "message" : "OK"]
                ]
                completion(0, "No data received")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? Int,
                   let message = json["message"] as? String {
                    completion(status, message)
                } else {
                    completion(0, "Invalid response format")
                }
            } catch {
                ErrorHandler.handleError(error: error)
                completion(0, "JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    // 2. 악보 조회 기능
    func fetchScores(deviceID: String, completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        let url = URL(string: "\(serverBaseURL)/api/scores?device_id=\(deviceID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 서버 오류 발생 시 예시 데이터 반환
                print("Error: \(error.localizedDescription). Returning example data as fallback.")
                let exampleData: [[String: Any]] = [
                    ["id": "1", "title": "Sample Score 4", "status": 1],
                    ["id": "2", "title": "Sample Score 5", "status": 2],
                    ["id": "3", "title": "Sample Score 6", "status": 0]
                ]
                completion(1, "Success", exampleData)
                return
            }
            
            guard let data = data else {
                // 데이터 없음 - 빈 배열 반환
                print("No data received from server. Displaying empty screen.")
                completion(1, "Success", [])
                return
            }
            
            // 서버 응답 파싱
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? Int,
                   let message = json["message"] as? String,
                   let scores = json["scores"] as? [[String: Any]] {
                    completion(status, message, scores)
                } else {
                    completion(0, "Invalid response format", nil)
                }
            } catch {
                ErrorHandler.handleError(error: error)
                completion(0, "JSON parsing error: \(error.localizedDescription)", nil)
            }
        }
        task.resume()
    }
    
    // 3. 악보 상태 변경 기능
    func updateScoreStatus(deviceID: String, scoreID: String, newStatus: Int, completion: @escaping (Int, String) -> Void) {
        let url = URL(string: "\(serverBaseURL)/api/score/\(scoreID)/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "device_id": deviceID,
            "status": newStatus
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            ErrorHandler.handleError(error: error)
            completion(0, "JSON serialization error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                ErrorHandler.handleError(error: error)
                completion(0, "Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion(0, "No data received")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? Int,
                   let message = json["message"] as? String {
                    completion(status, message)
                } else {
                    completion(0, "Invalid response format")
                }
            } catch {
                ErrorHandler.handleError(error: error)
                completion(0, "JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
