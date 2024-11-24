//
//  ServerManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//
import UIKit
import Combine

class ServerManager {
    static let shared = ServerManager()
    private init() {}
    @Published var isUploading: Bool = false
    private var uploadResponse: (Int, String) = (0, "")

    // 서버 IP 파일 분리
    private let serverBaseURL = Config.serverBaseURL
    
    // deviceID를 가져오는 메서드
    func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    // deviceToken 암호화 메서드
    private func encryptDeviceToken(_ deviceToken: Data) -> String {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        do {
            let encryptedToken = try AES256Cryption.encrypt(string: tokenString)
            return encryptedToken
        } catch {
            ErrorHandler.handleError(error: "Device Token 암호화 실패: \(error.localizedDescription)")
            return ""
        }
    }
    
    // URLRequest 생성 메서드 추가
    private func createServerRequest(
        endpoint: String,
        method: String,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(serverBaseURL)\(endpoint)")!)
        request.httpMethod = method
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        return request
        }
    
    
    func sendPDFuploadRequest(_ request : URLRequest) {
        // 서버 통신
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                ErrorHandler.handleError(error: "서버 요청 오류: \(error.localizedDescription)")
                self.setUploadResponse(0, "Request error: \(error.localizedDescription)")
                self.setIsUploading(isUploading: false)
                return
            }
            guard let data = data else {
                print("서버 응답 데이터 없음")
                self.setUploadResponse(0, "No response data")
                self.setIsUploading(isUploading: false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let code = json["code"] as? Int,
                   let message = json["message"] as? String {
                    self.setUploadResponse(code, message)
                    self.setIsUploading(isUploading: false)
                } else {
                    ErrorHandler.handleError(error: "잘못된 응답 형식: \(String(data: data, encoding: .utf8) ?? "Unknown")")
                    self.setUploadResponse(0, "Invalid response format")
                    self.setIsUploading(isUploading: false)
                }
            } catch {
                ErrorHandler.handleError(error: "JSON 파싱 오류: \(error.localizedDescription)")
                self.setUploadResponse(0, "JSON parsing error: \(error.localizedDescription)")
                self.setIsUploading(isUploading: false)
            }
        }
        task.resume()
    }
    
    // 1. PDF 업로드 기능
    func uploadPDF(deviceID: String, deviceToken: Data,
                   title: String, pdfFileURL: URL, page: Int) {
        
        setIsUploading(isUploading: true)
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // 암호화된 deviceToken
        let encryptedToken = encryptDeviceToken(deviceToken)
        
        // Multipart form-data 구성
        func addFormField(_ name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 필드 추가
        addFormField("device_id", value: deviceID)
        addFormField("device_token", value: encryptedToken) // 암호화된 deviceToken 전달
        addFormField("title", value: title)
        addFormField("page", value: "\(page)")
        
        // PDF 파일 추가
        do {
            let pdfData = try Data(contentsOf: pdfFileURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"pdf_file\"; filename=\"\(pdfFileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            body.append(pdfData)
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            ErrorHandler.handleError(error: "PDF 파일 읽기 실패: \(error.localizedDescription)")
            setUploadResponse(0, "Failed to load PDF file")
            setIsUploading(isUploading: false)
            return
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 요청 생성
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let request = createServerRequest(endpoint: "/api/score", method: "POST", headers: headers, body: body)
        
        // 요청 보냄
        sendPDFuploadRequest(request)
    }
    
        
    func setIsUploading(isUploading: Bool) {
        self.isUploading = isUploading
    }
    
    func setUploadResponse(_ code: Int, _ message : String) {
        uploadResponse = (code, message)
    }
    
    // 2. 음악 요청 조회 기능
    func fetchScores(deviceID: String, completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        
        let endpoint = "/api/scores?device_id=\(deviceID)"
        let request = createServerRequest(endpoint: endpoint, method: "GET")
        
        // MARK: - 디바이스 ID 확인
        print("deviceID --------: \(deviceID)")
        
        // 서버 통신
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 서버 오류 발생 시 빈배열 반환
                ErrorHandler.handleError(error: "Error: \(error.localizedDescription). Returning example data as fallback.")
                completion(1, "Success", [])
                return
            }
            
            guard let data = data else {
                return
            }
            
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
        let endpoint = "/api/score/\(scoreID)/status"
        let headers = ["Content-Type": "application/json"]
        
        let parameters: [String: Any] = [
            "device_id": deviceID,
            "status": newStatus
        ]
        
        // JSON 직렬화
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(0, "JSON serialization error")
            return
        }
        
        // 요청 생성
        let request = createServerRequest(endpoint: endpoint, method: "PUT", headers: headers, body: body)
        
        // 서버 통신
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
