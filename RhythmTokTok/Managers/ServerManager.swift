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
    @Published var hasError: Bool = false // 에러상태 추가
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
        sendRequest(request: request, hasResponseData: false) { [weak self] resultCode, message, data in
            self?.setIsUploading(isUploading: false)
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
    
    // HTTP 상태 코드에 따른 서버 오류 메시지 반환
    private func serverErrorMessage(statusCode: Int, responseData: Data?) -> String {
        // 서버가 JSON으로 보낸 message가 있으면 우선 사용
        if let data = responseData,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String, !message.isEmpty {
            return message
        }
        switch statusCode {
        case 400: return "잘못된 요청입니다. 입력값을 확인해 주세요."
        case 401: return "인증에 실패했습니다. 다시 로그인해 주세요."
        case 403: return "접근 권한이 없습니다."
        case 404: return "요청한 리소스를 찾을 수 없습니다."
        case 413: return "파일 크기가 너무 큽니다. 서버 제한을 초과했습니다."
        case 415: return "지원하지 않는 파일 형식입니다."
        case 422: return "처리할 수 없는 요청입니다. 데이터를 확인해 주세요."
        case 429: return "요청이 너무 많습니다. 잠시 후 다시 시도해 주세요."
        case 500: return "서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해 주세요."
        case 502: return "서버가 일시적으로 응답하지 않습니다. 잠시 후 다시 시도해 주세요."
        case 503: return "서비스를 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해 주세요."
        default:
            if statusCode >= 500 { return "서버 오류(\(statusCode))가 발생했습니다. 잠시 후 다시 시도해 주세요." }
            if statusCode >= 400 { return "요청 오류(\(statusCode))가 발생했습니다." }
            return "응답 코드가 잘못되었습니다.(\(statusCode))"
        }
    }

    // HTTP 요청 공통함수
    private func sendRequest(request: URLRequest,
                             hasResponseData: Bool,
                             completion: @escaping (Int, String, [[String: Any]]?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard self.checkNetworkError() != -1 else {
                self.hasError = true
                completion(-1, "네트워크가 연결되지 않았습니다.", [])
                return
            }

            if let urlError = error as? URLError {
                self.hasError = true
                let message = self.urlErrorMessage(urlError)
                ErrorHandler.handleError(error: urlError)
                completion(-2, message, [])
                return
            }
            if let error = error {
                self.hasError = true
                ErrorHandler.handleError(error: error)
                completion(-2, "요청 중 오류가 발생했습니다: \(error.localizedDescription)", [])
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                self.hasError = true
                let message = self.serverErrorMessage(statusCode: httpResponse.statusCode, responseData: data)
                ErrorHandler.handleError(error: "HTTP \(httpResponse.statusCode): \(message)")
                completion(-2, message, [])
                return
            }

            guard let data = data else {
                self.hasError = true
                completion(-2, "서버에서 응답 데이터를 받지 못했습니다.", [])
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let status = json["code"] as? Int,
                      let message = json["message"] as? String else {
                    self.hasError = true
                    completion(-2, "서버 응답 형식이 올바르지 않습니다.", [])
                    return
                }
                let scores = hasResponseData ? (json["scores"] as? [[String: Any]]) ?? [] : []
                self.hasError = false
                completion(status, message, scores)
            } catch {
                self.hasError = true
                ErrorHandler.handleError(error: error)
                completion(-2, "응답을 해석하는 중 오류가 발생했습니다.", [])
            }
        }
        task.resume()
    }

    // URLSession/URLError에 따른 메시지 반환
    private func urlErrorMessage(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "네트워크에 연결되지 않았습니다."
        case .timedOut:
            return "요청 시간이 초과되었습니다. 네트워크 상태를 확인해 주세요."
        case .cannotFindHost, .cannotConnectToHost:
            return "서버에 연결할 수 없습니다. 주소를 확인해 주세요."
        case .secureConnectionFailed:
            return "보안 연결에 실패했습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        default:
            return "요청 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
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
