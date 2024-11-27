//
//  ServerManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//
import UIKit
import Combine
import Network

class ServerManager {
    static let shared = ServerManager()
    
    // 네트워크 상태 모니터링
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    @Published var isUploading: Bool = false
    private var uploadResponse: (Int, String) = (0, "")
    
    // 서버 IP 파일 분리
    private let serverBaseURL = Config.serverBaseURL
    
    // deviceID를 가져오는 메서드
    func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    // 1. PDF 업로드 기능
    func uploadPDF(deviceID: String, deviceToken: Data,
                   title: String, pdfFileURL: URL, page: Int, completion: @escaping (Int, String, [[String: Any]]? ) -> Void) {
        
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
            setUploadResponse(-2, "Failed to load PDF file")
            setIsUploading(isUploading: false)
            return
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 요청 생성
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let request = createServerRequest(endpoint: "/api/score", method: "POST", headers: headers, body: body)
        
        // 요청 보냄
        sendRequest(request: request, hasResponseData: false) { resultCode, message, data in
            completion(resultCode, message, data)
        }
    }
    
    // 2. 음악 요청 조회 기능
    func fetchScores(deviceID: String, completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        
        let endpoint = "/api/scores?device_id=\(deviceID)"
        let request = createServerRequest(endpoint: endpoint, method: "GET")
        
        // MARK: - 디바이스 ID 확인
        print("deviceID --------: \(deviceID)")
        
        // 서버 통신
        sendRequest(request: request, hasResponseData: true) { resultCode, message, data in
            completion(resultCode, message, data)
        }
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
            completion(-2, "JSON 직렬화 에러")
            return
        }
        
        // 요청 생성
        let request = createServerRequest(endpoint: endpoint, method: "PUT", headers: headers, body: body)
        
        // 서버 통신
        sendRequest(request: request, hasResponseData: false) { resultCode, message, data in
            completion(resultCode, message)
        }
    }
    
    private func setIsUploading(isUploading: Bool) {
        self.isUploading = isUploading
    }
    
    private func setUploadResponse(_ code: Int, _ message : String) {
        uploadResponse = (code, message)
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
    
    // HTTP 요청 공통함수
    private func sendRequest(request: URLRequest,
                             hasResponseData: Bool,
                             completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        // 서버 통신
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard self.checkNetworkError() != -1 else {
                completion(-1, "네트워크가 연결되지 않았습니다.", [])
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("data \(data)")
                print("response \(response)")
                print("error \(error)")
                completion(-2, "응답 코드가 잘못되었습니다.", [])
                return
            }
            
            if let error = error {
                ErrorHandler.handleError(error: error)
                completion(-2, "에러가 발생했습니다.", [])
                return
            }
            
            // response Data 값을 가질때만 실행
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let status = json["code"] as? Int,
                       let message = json["message"] as? String {
                        // 조건에 따라 scores 데이터 처리
                        let scores = hasResponseData ? (json["scores"] as? [[String: Any]]) ?? [] : []
                        completion(status, message, scores)
                    } else {
                        completion(-2, "JSON 형식이 아닙니다.", [])
                    }
                } catch {
                    self.setIsUploading(isUploading: false)
                    ErrorHandler.handleError(error: error)
                    completion(-2, "JSON 변환 에러", [])
                }
            }
        }
        // 종료되면 isUploading
        self.setIsUploading(isUploading: false)
        task.resume()
    }
    
    // 네트워크 상태 확인
    private func isNetworkAvailable() -> Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    private func checkNetworkError() -> Int {
        if !isNetworkAvailable() {
            return -1
        }
        return 0
    }
}
