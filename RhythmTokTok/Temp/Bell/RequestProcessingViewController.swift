//
//  RequestProcessingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import UIKit
import CoreData

class RequestProcessingViewController: UIViewController, UIGestureRecognizerDelegate {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    var requests: [Request] = []
    var deviceID: String {
        return encrypt(ServerManager.shared.getDeviceUUID())
    }
        
    // 암호화 함수
    func encrypt(_ input: String) -> String {
        do {
            return try AES256Cryption.encrypt(string: input)
        } catch {
            ErrorHandler.handleError(error: error)
            return ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 전체 배경색 변경
        view.backgroundColor = UIColor(named: "background_tertiary")
        
        // 네비게이션 바 타이틀 설정
        self.title = "요청 목록"
        
        // 네비게이션 바 타이틀의 색상, 폰트, 크기 설정
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "lable_primary") ?? .black,
            .font: UIFont(name: "Pretendard-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        ]
        
        // Back 버튼 이미지 변경
        let backImage = UIImage(named: "back")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonPressed))
        
        setupViews()
        
        // 요청들을 화면에 추가
        addRequestsToStackView()
        
        // 서버에서 요청 목록을 불러옴
        fetchRequestsFromServer()
        
        //TODO: PDF 업로드 테스트 버튼 추가 -> 추후 삭제
        setupTestUploadButton()
    }
    
    // TODO: - PDF 테스트 -> 추후 삭제
    // PDF 업로드 테스트 버튼 추가
    private func setupTestUploadButton() {
        let uploadButton = UIButton(type: .system)
        uploadButton.setTitle("Upload Test PDF", for: .normal)
        uploadButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        uploadButton.backgroundColor = UIColor.systemBlue
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.layer.cornerRadius = 8
        uploadButton.addTarget(self, action: #selector(uploadTestPDF), for: .touchUpInside)

        view.addSubview(uploadButton)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false

        // 버튼의 위치 설정
        NSLayoutConstraint.activate([
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.widthAnchor.constraint(equalToConstant: 200),
            uploadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // PDF 업로드 테스트 버튼 액션
    @objc private func uploadTestPDF() {
        guard let pdfURL = Bundle.main.url(forResource: "cry", withExtension: "pdf") else {
            print("cry.pdf 파일을 찾을 수 없습니다.")
            return
        }

        let title = "Test Cry PDF"
        let page = 1 // 페이지 수 예시 값
        ServerManager.shared.uploadPDF(deviceID: deviceID, title: title, pdfFileURL: pdfURL, page: page) { status, message in
            print("Upload status: \(status), message: \(message)")
            DispatchQueue.main.async {
                if status == 1 {
                    ToastAlert.show(message: "PDF 업로드 성공: \(title)", in: self.view, iconName: "check.circle.color")
                    self.fetchRequestsFromServer()
                } else {
                    ToastAlert.show(message: "PDF 업로드 실패: \(message)", in: self.view, iconName: "error_icon")
                }
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Back 버튼 액션
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        // 스크롤뷰와 스택뷰 설정
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 스크롤뷰 제약 조건
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        
        let statuses: [RequestStatus] = [.scoreReady, .inProgress]
        
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
                let infoView = InProgressInfoView()
                stackView.addArrangedSubview(infoView)
                stackView.setCustomSpacing(16, after: infoView)
            }
            
            for request in requestsForStatus {
                let requestView = RequestCardView()
                requestView.request = request
                requestView.requestActionButton.addTarget(self, action: #selector(handleButtonAction(_:)), for: .touchUpInside)
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
            showCancelAlert(for: request, index: index)
        case .downloaded, .deleted, .cancelled:
            return
        case .scoreReady:
            addScore(at: index)
        }
    }
    
    //MARK: - 서버에서 데이터 가져오기
    private func fetchRequestsFromServer() {
        ServerManager.shared.fetchScores(deviceID: deviceID) { [weak self] code, message, scores in
            print("Fetch status: \(code), message: \(message)")
            guard code == 1, let scores = scores else {
                print("Failed to fetch scores: \(message)")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 서버의 날짜 포맷에 맞춤
//            let dateFormatter = ISO8601DateFormatter() // 날짜 포맷 설정
//            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 서버와의 통신을 위한 미세초 변환
            
            self?.requests = scores.compactMap { scoreDict in
                guard let id = scoreDict["id"] as? Int,
                      let title = scoreDict["title"] as? String,
                      let statusValue = scoreDict["status"] as? Int,
                      let requestDateString = scoreDict["request_date"] as? String,
                      let requestDate = dateFormatter.date(from: requestDateString), // 날짜 변환
                      let xmlURL = scoreDict["xml_url"] as? String else {
                    print("파싱 실패 - scoreDict:", scoreDict)
                    return nil
                }
                //TODO: 요청 서버에서 받으면 프린트 띄우기
//                print("score 생성 - id: \(id), title: \(title), status: \(statusValue), date: \(requestDate), url: \(xmlURL)")
                let status: RequestStatus
                switch statusValue {
                case 0: status = .inProgress
                case 1: status = .scoreReady
                case 2: status = .downloaded
                default: return nil
                }
                return Request(id: id, title: title, requestDate: requestDate, status: status, xmlURL: xmlURL)
            }
            
            DispatchQueue.main.async {
                self?.updateRequestsUI()
            }
        }
    }
    
    private func addScore(at index: Int) {
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
                score.title = request.title // 요청의 제목을 설정합니다.
                
                // Core Data에 저장합니다.
                ScoreManager.shared.addScoreWithNotes(scoreData: score)
                
                // 요청 상태를 .downloaded로 업데이트합니다.
                self.requests[index].status = .downloaded
                
                // 서버에 상태 업데이트를 요청합니다.
                ServerManager.shared.updateScoreStatus(deviceID: self.deviceID, scoreID: String(request.id), newStatus: 2) { status, message in
                    print("Update status: \(status), message: \(message)")
                }
                
                // UI를 메인 스레드에서 업데이트합니다.
                DispatchQueue.main.async {
                    // 토스트 알림을 표시합니다.
                    ToastAlert.show(message: "악보가 추가되었어요.", in: self.view, iconName: "check.circle.color")
                    
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
    private func cancelRequest(at index: Int) {
        let request = requests[index]

        // 서버에 상태 업데이트를 요청
        ServerManager.shared.updateScoreStatus(deviceID: deviceID, scoreID: String(request.id), newStatus: 11) { [weak self] status, message in
            guard let self = self else { return }
            print("Cancel status: \(status), message: \(message)")

            if status == 1 {
                DispatchQueue.main.async {
                    // 요청 상태를 .cancelled로 변경
                     self.requests[index].status = .cancelled
                     self.updateRequestsUI()
                    ToastAlert.show(message: "요청이 취소되었습니다.", in: self.view, iconName: "cancle.color")
                }
            } else {
                DispatchQueue.main.async {
                    ToastAlert.show(message: "요청 취소에 실패했습니다: \(message)", in: self.view, iconName: "error_icon")
                }
            }
        }
    }
}

// 악보 요청 취소 팝업
extension RequestProcessingViewController {
    private func showCancelAlert(for request: Request, index: Int) {
        let alertVC = CustomAlertViewController(
            title: "악보 요청을 취소하시겠어요?",
            message: "취소 후에는 되돌릴 수 없어요.",
            confirmButtonText: "취소하기",
            cancelButtonText: "닫기",
            confirmButtonColor: UIColor(named: "button_danger") ?? .red,
            cancelButtonColor: UIColor(named: "button_cancel") ?? .gray
        )
        
        alertVC.onConfirm = { [weak self] in
            self?.cancelRequest(at: index)
//            ToastAlert.show(message: "요청이 취소되었습니다.", in: self?.view ?? UIView(), iconName: "cancle.color")
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
}
