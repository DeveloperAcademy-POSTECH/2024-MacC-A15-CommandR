import UIKit
import PDFKit
import QuickLook

class AddGridViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var convertButton: UIButton!
    var captureButton: UIButton!
    var viewPDFButton: UIButton!
    var pdfURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        convertButton = UIButton(type: .system)
        convertButton.setTitle("Convert to PDF", for: .normal)
        convertButton.isHidden = true
        convertButton.addTarget(self, action: #selector(convertToPDF), for: .touchUpInside)
        convertButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(convertButton)
        
        captureButton = UIButton(type: .system)
        captureButton.setTitle("사진 촬영", for: .normal)
        captureButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        viewPDFButton = UIButton(type: .system)
        viewPDFButton.setTitle("View PDF", for: .normal)
        viewPDFButton.isHidden = true
        viewPDFButton.addTarget(self, action: #selector(showPDF), for: .touchUpInside)
        viewPDFButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPDFButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            convertButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            convertButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: 20),
            
            viewPDFButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewPDFButton.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 20)
        ])
    }
    
    // 카메라 열기
    @objc func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("카메라를 사용할 수 없습니다.")
        }
    }
    
    // 이미지 선택 후 처리
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            convertButton.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 -> PDF 변환 및 저장
    @objc func convertToPDF() {
        guard let image = imageView.image else { return }
        
//        // PDF 변환 및 저장을 PDFConvertManager에서 처리
//        if let pdfData = PDFConvertManager.convertImageToPDF(image: image),
//           let savedURL = PDFConvertManager.savePDF(data: pdfData) {
//            pdfURL = savedURL
//            viewPDFButton.isHidden = false
//        }
    }
    
    // PDF 보기
    @objc func showPDF() {
        guard pdfURL != nil else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
    
    // 이미지 선택 취소 시 처리
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddGridViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL! as QLPreviewItem
    }
}
