import Foundation
import UIKit

class ErrorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupUI() {
        // 배경색 설정
        view.backgroundColor = .white
        
        // 1. 경고 아이콘 이미지
        let warningIcon = UIImageView()
        warningIcon.image = UIImage(named: "caution.color") ?? UIImage(systemName: "exclamationmark.circle.fill")
        warningIcon.tintColor = .systemYellow
        warningIcon.contentMode = .scaleAspectFit
        
        // 2. 메인 메시지 레이블
        let mainMessageLabel = UILabel()
        mainMessageLabel.text = "음악 요청을 처리하지 못했어요"
        mainMessageLabel.textColor = .lablePrimary
        mainMessageLabel.font = UIFont.customFont(forTextStyle: .heading2Bold)
        mainMessageLabel.textAlignment = .center
        mainMessageLabel.adjustsFontForContentSizeCategory = true
        
        // 3. 하위 메시지 레이블
        let subMessageLabel = UILabel()
        subMessageLabel.text = "문제가 발생했으니 다시 시도해 주세요"
        subMessageLabel.textColor = .lableTertiary
        subMessageLabel.font = UIFont.customFont(forTextStyle: .subheadingRegular)
        subMessageLabel.textAlignment = .center
        subMessageLabel.adjustsFontForContentSizeCategory = true
        
        // 4. 버튼
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("처음으로 가기", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.customFont(forTextStyle: .button1Medium)
        retryButton.backgroundColor = .buttonPrimary
        retryButton.layer.cornerRadius = 10
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        retryButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // 버튼 액션 추가
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        // 5. Stack View 설정
        let stackView = UIStackView(arrangedSubviews: [warningIcon, mainMessageLabel, subMessageLabel, retryButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 6. Auto Layout 설정
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 경고 아이콘 크기 지정
            warningIcon.widthAnchor.constraint(equalToConstant: 80),
            warningIcon.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func retryButtonTapped() {
        // 버튼 클릭 시 동작 (처음 화면으로 이동)
        navigationController?.popToRootViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
}
