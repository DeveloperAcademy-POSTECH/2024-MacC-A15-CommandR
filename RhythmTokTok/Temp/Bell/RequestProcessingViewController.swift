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
        
        // MARK: - 더미데이터 테스트
        // 더미 데이터 생성
        generateDummyRequests()
        
        // 요청들을 화면에 추가
        addRequestsToStackView()
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
    
    // 더미데이터
    private func generateDummyRequests() {
        let dummyRequest1 = Request(id: UUID(), title: "첫 번째 요청", date: Date(), status: .inProgress)
        let dummyRequest2 = Request(id: UUID(), title: "두 번째 요청", date: Date(), status: .downloaded)
        let dummyRequest3 = Request(id: UUID(), title: "세 번째 요청", date: Date(), status: .scoreReady)
        
        // 일주일 전 날짜
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let dummyRequest4 = Request(id: UUID(), title: "네 번째 요청", date: oneWeekAgo, status: .scoreReady)
        
        requests = [dummyRequest1, dummyRequest2, dummyRequest3, dummyRequest4]
    }
    
    private func addRequestsToStackView() {
        var groupedRequests: [RequestStatus: [Request]] = [:]
        for request in requests {
            groupedRequests[request.status, default: []].append(request)
        }
        
        let statuses: [RequestStatus] = [.scoreReady, .inProgress, .downloaded]
        
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
            // 악보가 이미 추가된 상태일 때 경고 메시지 표시
            ToastAlert.show(message: "악보가 이미 추가되어 있어요.", in: self.view, iconName: "caution.color")
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
