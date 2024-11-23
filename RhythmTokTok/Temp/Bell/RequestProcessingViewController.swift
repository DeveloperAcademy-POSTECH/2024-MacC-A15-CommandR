//
//  RequestProcessingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import UIKit
import CoreData

class RequestProcessingViewController: UIViewController,
                                       UIGestureRecognizerDelegate {
    private let navigationBar = CommonNavigationBar()
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        return view
    }()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    @MainActor
    var requests: [Request] = []
    var deviceID: String {
        return encrypt(ServerManager.shared.getDeviceUUID())
    }
    
    // device 암호화 함수
    func encrypt(_ input: String) -> String {
        do {
            return try AES256Cryption.encrypt(string: input)
        } catch {
            print("Device UUID before encryption: \(input)")
            ErrorHandler.handleError(error: error)
            return ""
        }
    }
    
    // deviceToken 암호화
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 전체 배경색 변경
        view.backgroundColor = .backgroundPrimary
        
        // 네비게이션 바 타이틀 설정
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationBar.configure(title: "요청 목록")
        navigationBar.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        setupViews()
        
        // 요청들을 화면에 추가
        addRequestsToStackView()
        
        // 서버에서 요청 목록을 불러옴
        fetchRequestsFromServer()
    }
    
    @objc private func showTestEmptyState() {
        showEmptyState()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Back 버튼 액션
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        // 네비게이션바 추가
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        // divider
        view.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        // 스크롤뷰와 스택뷰 설정
        view.addSubview(scrollView)
        scrollView.backgroundColor = .backgroundTertiary
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 스크롤뷰 제약 조건
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 64),
            
            // divider
            divider.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor), // 좌우 패딩 없이 전체 너비
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),  // 1pt 너비로 가로선 추가
            
            scrollView.topAnchor.constraint(equalTo: divider.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 스택뷰 제약 조건
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func addRequestsToStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var groupedRequests: [RequestStatus: [Request]] = [:]
        for request in requests {
            groupedRequests[request.status, default: []].append(request)
        }
        
        let statuses: [RequestStatus] = [.scoreReady, .inProgress, .errorOccurred]
        
        for status in statuses {
            guard var requestsForStatus = groupedRequests[status] else { continue }
            
            requestsForStatus.sort { $0.requestDate > $1.requestDate }
            
            let headerStackView = UIStackView()
            headerStackView.axis = .horizontal
            headerStackView.alignment = .leading
            headerStackView.spacing = 2
            
            let headerLabel = UILabel()
            headerLabel.font = UIFont(name: "Pretendard-Bold", size: 22)
            headerLabel.textColor = UIColor(named: "lable_primary")
            
            let headerText = status.headerText
            let countText = "\(requestsForStatus.count)"
            let attributedText = NSMutableAttributedString(string: "\(headerText) ")
            let countAttributedText = NSAttributedString(
                string: countText,
                attributes: [.foregroundColor: UIColor(named: "lable_quaternary") ?? .gray]
            )
            attributedText.append(countAttributedText)
            headerLabel.attributedText = attributedText
            headerLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            headerStackView.addArrangedSubview(headerLabel)
            stackView.addArrangedSubview(headerStackView)
            
            if status == .inProgress {
                let infoView = ExtraInfoView(text: "🚨 음악 완성까지 약 1~2일이 소요될 수 있어요")
                stackView.addArrangedSubview(infoView)
                stackView.setCustomSpacing(16, after: infoView)
            }
            
            else if status == .errorOccurred {
                let infoView = ExtraInfoView(text: "🚫 변환이 안된 이유는 클릭해서 확인하실 수 있어요.")
                stackView.addArrangedSubview(infoView)
                stackView.setCustomSpacing(16, after: infoView)
            }
            
            for request in requestsForStatus {
                let requestView = RequestCardView()
                requestView.request = request
                requestView.requestActionButton.addTarget(self,
                                                          action: #selector(handleButtonAction(_:)),
                                                          for: .touchUpInside)
                requestView.requestActionButton.tag = requests.firstIndex(where: { $0.id == request.id }) ?? 0
                requestView.translatesAutoresizingMaskIntoConstraints = false
                requestView.heightAnchor.constraint(equalToConstant: 96).isActive = true
                stackView.addArrangedSubview(requestView)
            }
            
            if let lastView = stackView.arrangedSubviews.last {
                stackView.setCustomSpacing(64, after: lastView)
            }
        }
    }
    
    @objc private func handleButtonAction(_ sender: UIButton) {
        let index = sender.tag
        let request = requests[index]
        
        switch request.status {
        case .inProgress:
            //            showCancelAlert(for: request, index: index)
            showErrorOccurredAlert(for: request, index: index)
        case .errorOccurred:
            showErrorOccurredAlert(for: request, index: index)
        case .scoreReady:
            addScore(at: index)
        case .downloaded, .deleted, .cancelled:
            return
        }
    }
    
    // MARK: - 서버에서 데이터 가져오기
    private func fetchRequestsFromServer() {
        ServerManager.shared.fetchScores(deviceID: deviceID) { [weak self] code, message, scores in
            
            DispatchQueue.main.async {
                guard code == 1, let scores = scores else {
                    print("Failed to fetch scores: \(message)")
                    self?.showEmptyState()
                    return
                }
                
                if scores.isEmpty {
                    // 데이터가 없을 경우 EmptyStateView 표시
                    self?.showEmptyState()
                    return
                }
                
                // 데이터가 있을 경우 파싱 및 UI 업데이트
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                self?.requests = scores.compactMap { scoreDict in
                    guard let scoreId = scoreDict["id"] as? Int,
                          let title = scoreDict["title"] as? String,
                          let statusValue = scoreDict["status"] as? Int,
                          let requestDateString = scoreDict["request_date"] as? String,
                          let requestDate = dateFormatter.date(from: requestDateString),
                          let xmlURL = scoreDict["xml_url"] as? String,
                          let status = RequestStatus(rawValue: statusValue) else {
                        print("Failed to parse scoreDict:", scoreDict)
                        return nil
                    }

                    return Request(id: scoreId, title: title, requestDate: requestDate, status: status, xmlURL: xmlURL)
                }
                self?.updateRequestsUI()
            }
        }
    }
    
    func addScore(at index: Int) {
        let request = requests[index]
        
        // XML URL을 가져옵니다.
        guard let xmlURLString = request.xmlURL,
              let xmlURL = URL(string: xmlURLString) else {
            print("Invalid XML URL")
            return
        }
        
        // XML 데이터를 다운로드합니다.
        let task = URLSession.shared.dataTask(with: xmlURL) { data, response, error in
            if let error = error {
                print("Failed to download XML: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from XML URL")
                return
            }
            
            // XML 데이터를 파싱합니다.
            let parser = MusicXMLParser()
            Task {
                let score = await parser.parseMusicXML(from: data)
                
                // request.title을 score.title로 설정
                if score.title.isEmpty {
                    score.title = request.title
                }
                
                // Core Data에 저장합니다.
                let scoreService = ScoreService()
                scoreService.addScoreWithNotes(scoreData: score)
                
                // UI를 메인 스레드에서 업데이트합니다.
                DispatchQueue.main.async {
                    // 요청 상태를 .downloaded로 업데이트합니다.
                    self.requests[index].status = .downloaded
                    // 서버에 상태 업데이트를 요청합니다.
                    ServerManager.shared.updateScoreStatus(deviceID: self.deviceID,
                                                           scoreID: String(request.id),
                                                           newStatus: 2) { status, message in
                        print("Update status: \(status), message: \(message)")
                    }
                    
                    // 토스트 알림을 표시합니다.
                    ToastAlert.show(message: "음악이 추가되었어요.", in: self.view, iconName: "check.circle.color")
                    
                    // 요청 리스트를 재구성합니다.
                    self.updateRequestsUI()
                }
            }
        }
        task.resume()
    }
    
    private func updateRequestsUI() {
        // 스택뷰의 기존 서브뷰 제거
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 갱신된 요청 리스트로 UI 재구성
        addRequestsToStackView()
    }
    
    // MARK: - 요청 취소 메서드 추가
    private func cancelRequest(at index: Int, completion: @escaping (Bool) -> Void) {
        let request = requests[index]
        
        ServerManager.shared.updateScoreStatus(deviceID: deviceID,
                                               scoreID: String(request.id),
                                               newStatus: 11) { [weak self] status, message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if status == 1 {
                    self.requests[index].status = .cancelled
                    self.updateRequestsUI()
                    completion(true)
                } else {
                    print("Failed to cancel request: \(message)")
                    completion(false)
                }
            }
        }
    }
    
    func showEmptyState() {
        view.subviews
            .filter { $0 is EmptyStateView }
            .forEach { $0.removeFromSuperview() }
        
        // 새로운 EmptyStateView 추가
        let emptyStateView = EmptyStateView(
            message: "만들고 있는 음악이 없어요",
            subMessage: "원하는 음악을 요청하여 만들어보세요!"
        )
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// 음악 추가 요청 취소 팝업
extension RequestProcessingViewController {
    private func showCancelAlert(for request: Request, index: Int) {
        let alertVC = CustomAlertViewController(
            title: "음악 추가 요청을 취소하시겠어요?",
            message: "취소 후에는 되돌릴 수 없어요.",
            confirmButtonText: "취소하기",
            cancelButtonText: "닫기",
            confirmButtonColor: UIColor(named: "button_danger") ?? .red,
            cancelButtonColor: UIColor(named: "button_cancel") ?? .gray,
            highlightedTexts: ["되돌릴 수 없어요."]
        )
        
        alertVC.onCancel = { [weak self] in
            // 요청 삭제 동작
            guard let self = self else { return }
            self.deleteRequest(for: request.id)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - 서버에서 변환 에러 발생시 팝업
extension RequestProcessingViewController {
    private func showErrorOccurredAlert(for request: Request, index: Int) {
        let titleAndMessages: [Int: (String, String)] = [
            22: ("PDF 파일 오류", "파일 변환에 실패했습니다. 다시 시도해주세요."),
            23: ("지원하지 않는 파일", "해당 파일 형식은 지원되지 않습니다."),
            24: ("파일 손상", "업로드된 파일이 손상되었습니다."),
            25: ("파일 누락", "필요한 파일이 누락되었습니다.")
        ]
        
        let statusValue = request.status.rawValue
        guard let (title, message) = titleAndMessages[statusValue] else {
            print("알 수 없는 상태 코드: \(statusValue)")
            return
        }
        
        let alertVC = CustomAlertViewController(
            title: title,
            message: message,
            confirmButtonText: "파일 변경",
            cancelButtonText: "요청 삭제",
            confirmButtonColor: UIColor(named: "button_primary") ?? .red,
            cancelButtonColor: UIColor(named: "button_cancel") ?? .gray,
            highlightedTexts: [""]
        )
        
        alertVC.onConfirm = { [weak self] in
            // 파일 변경 동작
            self?.handleFileChange(for: request, requestID: request.id)
        }
        
        alertVC.onCancel = { [weak self] in
            // 요청 삭제 동작
            guard let self = self else { return }
            self.deleteRequest(for: request.id)
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
    
    @MainActor
    private func handleFileChange(for request: Request, requestID: Int) {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else {
            print("Request ID \(requestID) not found.")
            return
        }
        
        cancelRequest(at: index) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                let checkPDFVC = CheckPDFViewController()
//                checkPDFVC.fileURL = URL(string: request.xmlURL ?? "")
                self.navigationController?.pushViewController(checkPDFVC, animated: true)
            } else {
                ToastAlert.show(message: "요청 취소에 실패했습니다.", in: self.view, iconName: "error_icon")
            }
        }
    }
    private func deleteRequest(for requestID: Int) {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else {
            print("Request ID \(requestID) not found.")
            return
        }
        
        cancelRequest(at: index) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                ToastAlert.show(message: "요청이 삭제되었습니다.", in: self.view, iconName: "check.circle.color")
            } else {
                ToastAlert.show(message: "요청 삭제에 실패했습니다.", in: self.view, iconName: "error_icon")
            }
        }
    }
}
    //        // 로컬 데이터에서 요청 삭제
    //        if let index = requests.firstIndex(where: { $0.id == requestID }) {
    //            requests.remove(at: index)
    //        }
    //
    //        // UI 업데이트
    //        updateRequestsUI()
    
    // TODO: 요청 오류났을 때 삭제 기능 추가하기
    // 서버에서 요청 삭제 API 호출 (선택 사항)
    //    ServerManager.shared.deleteRequest(deviceID: deviceID, requestID: requestID) { [weak self] success, message in
    //        DispatchQueue.main.async {
    //            if success {
    //                ToastAlert.show(message: "요청이 삭제되었습니다.", in: self?.view ?? UIView(), iconName: "check.circle.color")
    //            } else {
    //                ToastAlert.show(message: "요청 삭제 실패: \(message)", in: self?.view ?? UIView(), iconName: "error_icon")
    //            }
    //        }
    //    }

