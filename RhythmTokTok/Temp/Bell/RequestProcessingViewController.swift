//
//  RequestProcessingViewController.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import UIKit

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
    
    private func generateDummyRequests() {
        let dummyRequest1 = Request(
            id: UUID(),
            title: "첫 번째 요청",
            date: Date(),
            status: .inProgress
        )
        
        let dummyRequest2 = Request(
            id: UUID(),
            title: "두 번째 요청",
            date: Date(),
            status: .downloaded
        )
        
        let dummyRequest3 = Request(
            id: UUID(),
            title: "세 번째 요청",
            date: Date(),
            status: .scoreReady
        )
        
        requests = [dummyRequest1, dummyRequest2, dummyRequest3]
    }
    
    private func addRequestsToStackView() {
        // 요청들을 상태별로 그룹화
        var groupedRequests: [RequestStatus: [Request]] = [:]
        for request in requests {
            groupedRequests[request.status, default: []].append(request)
        }
        
        // 상태별 순서 지정
        let statuses: [RequestStatus] = [.scoreReady, .inProgress, .downloaded]
        
        for status in statuses {
            guard let requestsForStatus = groupedRequests[status] else { continue }
            
            let headerStackView = UIStackView()
            headerStackView.axis = .horizontal
            headerStackView.alignment = .leading
            headerStackView.spacing = 2
            
            // 헤더 레이블 추가
            let headerLabel = UILabel()
            headerLabel.font = UIFont(name: "Pretendard-Bold", size: 22)
            headerLabel.textColor = UIColor(named: "lable_primary")
            
            // 상태별 텍스트 설정
            let headerText = status.headerText
    
            // countLabel 텍스트 설정 및 색상 지정
            let countText = "\(requestsForStatus.count)"
            let attributedText = NSMutableAttributedString(string: "\(headerText) ")
            let countAttributedText = NSAttributedString(
                string: countText,
                attributes: [.foregroundColor: UIColor(named: "lable_quaternary") ?? .gray]
            )
            attributedText.append(countAttributedText)
            
            // 헤더 레이블에 attributedText 설정
            headerLabel.attributedText = attributedText
            headerLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            headerStackView.addArrangedSubview(headerLabel)
            stackView.addArrangedSubview(headerStackView)
            
            
            // inProgress 상태일 경우 정보 뷰 추가
            if status == .inProgress {
                let infoView = InProgressInfoView()
                stackView.addArrangedSubview(infoView)
                
                // infoView와 그 다음 요소 사이의 간격을 16으로 설정
                stackView.setCustomSpacing(16, after: infoView)
            }
            
            // 요청 뷰들 추가
            for request in requestsForStatus {
                let requestView = RequestCardView()
                requestView.request = request
                
                // 버튼 액션 추가
                requestView.requestActionButton.addTarget(self, action: #selector(handleButtonAction(_:)), for: .touchUpInside)
                
                // 태그를 사용하여 어떤 요청인지 식별
                requestView.requestActionButton.tag = requests.firstIndex(where: { $0.id == request.id }) ?? 0
                
                // 각 RequestView의 높이 자동 조절
                requestView.translatesAutoresizingMaskIntoConstraints = false
                requestView.heightAnchor.constraint(equalToConstant: 96).isActive = true
                
                stackView.addArrangedSubview(requestView)
            }
            // 각 상태 그룹의 마지막 뷰 뒤에 64의 패딩 추가
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
            cancelRequest(at: index)
        case .downloaded, .scoreReady:
            addSheet(at: index)
        }
    }
    
    private func cancelRequest(at index: Int) {
        // 요청 취소 처리 로직
        print("\(requests[index].title) - 요청 취소")
    }
    
    private func addSheet(at index: Int) {
        // 악보 추가 처리 로직
        print("\(requests[index].title) - 악보 추가")
    }
}
