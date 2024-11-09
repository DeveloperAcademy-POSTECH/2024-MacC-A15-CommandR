import UIKit


class TitleInputViewController: UIViewController {
    var titleInputView: TitleInputView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
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
}
