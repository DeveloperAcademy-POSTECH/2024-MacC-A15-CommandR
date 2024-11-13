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
    let deviceID = "your_device_id"
    
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
    }
    
    // 서버에서 데이터 가져오기
    private func fetchRequestsFromServer() {
        ServerManager.shared.fetchScores(deviceID: deviceID) { [weak self] status, message, scores in
            // 데이터 수신 상태 및 내용 확인
            print("Fetch status: \(status), message: \(message)")
            guard status == 1, let scores = scores else {
                print("Failed to fetch scores: \(message)")
                return
            }

            // 서버에서 받은 데이터로 requests 배열 업데이트 전 데이터 확인
            self?.requests = scores.compactMap { scoreDict in
                guard let id = scoreDict["id"] as? String,
                      let title = scoreDict["title"] as? String,
                      let statusValue = scoreDict["status"] as? Int else {
                    return nil
                }

                let status: RequestStatus
                switch statusValue {
                case 0: status = .inProgress
                case 1: status = .scoreReady
                case 2: status = .downloaded
                default: return nil
                }
                return Request(id: UUID(uuidString: id) ?? UUID(), title: title, date: Date(), status: status)
            }

            print("Updated requests array: \(self?.requests ?? [])") // 배열 업데이트 후 데이터 확인

            // UI 업데이트
            DispatchQueue.main.async {
                print("Adding requests to stack view with data: \(self?.requests ?? [])")
                self?.addRequestsToStackView()
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
        var groupedRequests: [RequestStatus: [Request]] = [:]
        for request in requests {
            groupedRequests[request.status, default: []].append(request)
        }
        
        let statuses: [RequestStatus] = [.scoreReady, .inProgress]
        
        for status in statuses {
            guard var requestsForStatus = groupedRequests[status] else { continue }
            
            requestsForStatus.sort { $0.date > $1.date }
            
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
        case .downloaded:
            return
        case .scoreReady, .deleted:
            addScore(at: index)
        }
    }
    
    private func cancelRequest(at index: Int) {
        print("\(requests[index].title) - 요청 취소")
    }
    
    // 서버 요청 및 Core Data 저장 기능 추가
    private func addScore(at index: Int) {
        let request = requests[index]
        
        fetchSheetFromServer(for: request) { [weak self] result in
            switch result {
            case .success(let sheetData):
                // 여기에 코어데이터 저장 구현
                self?.saveSheetToCoreData(sheetData)
                DispatchQueue.main.async {
                    ToastAlert.show(message: "악보가 추가되었어요.", in: self?.view ?? UIView(), iconName: "check.circle.color")
                }
            case .failure(let error):
                print("악보 추가 실패: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - 서버, 코어데이터 구현해야할 곳
    private func fetchSheetFromServer(for request: Request, completion: @escaping (Result<Data, Error>) -> Void) {
        // 여기에 서버에서 데이터를 가져오는 함수 구현
        completion(.success(Data()))
    }
    
    private func saveSheetToCoreData(_ sheetData: Data) {
        // 여기에 코어데이터 저장 구현
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //          let newSheet = SheetEntity(context: context)
        //          newSheet.data = sheetData
        //          newSheet.dateAdded = Date()
        
        do {
            try context.save()
            print("악보가 성공적으로 Core Data에 저장되었습니다.")
        } catch {
            print("Core Data 저장 실패: \(error.localizedDescription)")
        }
    }
}

// 악보 요청 취소
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
            // TODO: 아이콘 애셋 변경 필요
            ToastAlert.show(message: "요청이 취소되었습니다.", in: self?.view ?? UIView(), iconName: "cancle.color")
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
}
