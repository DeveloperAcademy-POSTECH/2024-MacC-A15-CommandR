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

    // 서버 IP 가져오는 것
    private let serverBaseURL = Config.serverBaseURL
    
    // deviceID를 가져오는 메서드
    func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    // 1. PDF 업로드 기능
    func uploadPDF(deviceID: String, title: String, pdfFileURL: URL, page: Int, completion: @escaping (Int, String) -> Void) {
        let url = URL(string: "\(serverBaseURL)/api/score")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // device_id 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"device_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(deviceID)\r\n".data(using: .utf8)!)

        // title 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)

        // page 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"page\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(page)\r\n".data(using: .utf8)!)

        // pdf_file 추가
        do {
            let pdfData = try Data(contentsOf: pdfFileURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"pdf_file\"; filename=\"\(pdfFileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            body.append(pdfData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            print("PDF 파일 읽기 실패: \(error.localizedDescription)")
            completion(0, "Failed to load PDF file")
            return
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("서버 요청 오류: \(error.localizedDescription)")
                completion(0, "Request error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("서버 응답 데이터 없음")
                completion(0, "No response data")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let code = json["code"] as? Int,
                   let message = json["message"] as? String {
                    completion(code, message)
                } else {
                    print("잘못된 응답 형식: \(String(data: data, encoding: .utf8) ?? "Unknown")")
                    completion(0, "Invalid response format")
                }
            } catch {
                print("JSON 파싱 오류: \(error.localizedDescription)")
                completion(0, "JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    // 2. 음악 요청 조회 기능
    func fetchScores(deviceID: String, completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        let url = URL(string: "\(serverBaseURL)/api/scores?device_id=\(deviceID)")!
        print("deviceID: \(deviceID)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 서버 오류 발생 시 빈배열 반환
                print("Error: \(error.localizedDescription). Returning example data as fallback.")
                completion(1, "Success", [])
                return
            }
            
            guard let data = data else {
                // TODO: 여기에 빈 값일 때 화면전환해주기
                // 데이터 없음 - 빈 배열 반환
                print("No data received from server. Displaying empty screen.")
                completion(1, "Success", [])
                
                return
            }
            print("\(data)")
            
            // 서버 응답 파싱
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["code"] as? Int,
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
    
    // 3. 음악 요청 상태 변경 기능
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
                   let status = json["code"] as? Int,
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
