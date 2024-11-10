import UIKit

class TitleInputViewController: UIViewController {
    var titleInputView: TitleInputView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupAccessoryButton()
    }

    private func setupUI() {
        // Initialize TitleInputView and add it as a subview
        titleInputView = TitleInputView()
        titleInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleInputView)

        // Set constraints for TitleInputView
        NSLayoutConstraint.activate([
            titleInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupAccessoryButton() {
        // Create accessory button for the keyboard
        let accessoryButton = UIButton(type: .system)
        accessoryButton.setTitle("입력 완료", for: .normal)
        accessoryButton.setTitleColor(.white, for: .normal)
        accessoryButton.backgroundColor = .systemBlue
        accessoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.addTarget(self, action: #selector(accessoryButtonTapped), for: .touchUpInside)
        
        // Create a container view for the accessory button to fit it in the keyboard accessory view
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        accessoryView.backgroundColor = .clear
        accessoryView.addSubview(accessoryButton)
        
        // Set the accessory button to stretch across the full width of the accessory view
        NSLayoutConstraint.activate([
            accessoryButton.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor),
            accessoryButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor),
            accessoryButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
            accessoryButton.heightAnchor.constraint(equalToConstant: 64) // Set the height to 64
        ])
        
        // Set the accessory view for the textField
        titleInputView.textField.inputAccessoryView = accessoryView
    }



    @objc private func accessoryButtonTapped() {
        // Handle the action when "제목 입력 완료" button is tapped
        titleInputView.textField.resignFirstResponder() // Dismiss keyboard
        // You can add any additional completion logic here
    }
}
