//
//  ScoreSearchView.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/21/24.
//

import UIKit

class ScoreSearchView: UIView {
    let navigationBar = CommonNavigationBar()
    weak var parentViewController: UIViewController?
    
    let searchBackgroundView: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
        view.backgroundColor = UIColor(named: "background_primary")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(named: "background_secondary")
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.font = UIFont(name: "Pretendard-Medium", size: 16)
        
        // placeholder에 커스텀 폰트 적용
        let placeholderText = "음악 제목을 입력해 주세요"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "placeholder") ?? .lightGray,
            .font: UIFont(name: "Pretendard-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        textField.setLeftPaddingPoints(36)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(named: "border_secondary")?.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "search"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let tableHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Bold", size: 24)
        label.textColor = UIColor(named: "label_primary")
        label.text = "검색 결과"
        label.isHidden = true // 초기에는 숨김
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "background_tertiary")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationBar() {
        navigationBar.configure(title: "음악 검색")
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            guard let parentVC = self.parentViewController else {
                return
            } // 부모 컨트롤러 참조
            
            if let navigationController = parentVC.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                parentVC.dismiss(animated: true, completion: nil)
            }
        }
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor
                .constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "background_primary")
        
        let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "background_tertiary")
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        addSubview(searchBackgroundView)
        searchBackgroundView.addSubview(searchTextField)
        searchBackgroundView.addSubview(searchIcon)
        
        addSubview(containerView)
        containerView.addSubview(tableHeaderLabel)
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [
                // Search Background
                searchBackgroundView.topAnchor
                    .constraint(equalTo: navigationBar.bottomAnchor),
                searchBackgroundView.leadingAnchor
                    .constraint(equalTo: leadingAnchor),
                searchBackgroundView.trailingAnchor
                    .constraint(equalTo: trailingAnchor),
                searchBackgroundView.heightAnchor.constraint(equalToConstant: 64),
                
                // 텍스트 필드
                searchTextField.leadingAnchor
                    .constraint(
                        equalTo: searchBackgroundView.leadingAnchor,
                        constant: 20
                    ),
                searchTextField.trailingAnchor
                    .constraint(
                        equalTo: searchBackgroundView.trailingAnchor,
                        constant: -20
                    ),
                searchTextField.bottomAnchor
                    .constraint(
                        equalTo: searchBackgroundView.bottomAnchor,
                        constant: -15
                    ),
                searchTextField.heightAnchor.constraint(equalToConstant: 48),
                
                // 검색 고정 아이콘
                searchIcon.leadingAnchor
                    .constraint(
                        equalTo: searchTextField.leadingAnchor,
                        constant: 12
                    ),
                searchIcon.centerYAnchor
                    .constraint(equalTo: searchTextField.centerYAnchor),
                searchIcon.widthAnchor.constraint(equalToConstant: 20),
                searchIcon.heightAnchor.constraint(equalToConstant: 20),
                
                // 배경색 고정을 위한 컨테이너 추가
                containerView.topAnchor
                    .constraint(equalTo: searchBackgroundView.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                // "검색 결과" 헤더
                tableHeaderLabel.topAnchor
                    .constraint(equalTo: containerView.topAnchor, constant: 24),
                tableHeaderLabel.leadingAnchor
                    .constraint(equalTo: containerView.leadingAnchor, constant: 20),
                
                // 검색 리스트
                tableView.topAnchor
                    .constraint(
                        equalTo: tableHeaderLabel.bottomAnchor,
                        constant: 8
                    ),
                tableView.leadingAnchor
                    .constraint(equalTo: containerView.leadingAnchor),
                tableView.trailingAnchor
                    .constraint(equalTo: containerView.trailingAnchor),
                tableView.bottomAnchor
                    .constraint(equalTo: containerView.bottomAnchor)
            ]
        )
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height)
        )
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
