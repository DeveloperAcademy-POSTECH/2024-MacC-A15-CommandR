import UIKit
import PDFKit
import QuickLook

class AddGridViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!           // 촬영된 이미지를 보여줄 이미지 뷰
    var convertButton: UIButton!          // 이미지를 PDF로 변환하는 버튼
    var captureButton: UIButton!          // 사진 촬영을 위한 버튼
    var viewPDFButton: UIButton!          // 생성된 PDF를 볼 버튼
    var pdfURL: URL?                      // 생성된 PDF 파일의 경로
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white     // 배경 색상 설정
        
        // UIImageView 설정 (촬영된 이미지를 표시할 뷰)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit  // 이미지 비율을 유지하여 화면에 맞게 조정
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)         // 이미지뷰를 뷰에 추가
        
        // "Convert to PDF" 버튼 설정
        convertButton = UIButton(type: .system)
        convertButton.setTitle("Convert to PDF", for: .normal)
        convertButton.isHidden = true      // 이미지를 선택한 후에만 보이도록 설정
        convertButton.addTarget(self, action: #selector(convertToPDF), for: .touchUpInside)
        convertButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(convertButton)     // 버튼을 뷰에 추가
        
        // "사진 촬영" 버튼 설정
        captureButton = UIButton(type: .system)
        captureButton.setTitle("사진 촬영", for: .normal)
        captureButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)     // 버튼을 뷰에 추가
        
        // "View PDF" 버튼 설정
        viewPDFButton = UIButton(type: .system)
        viewPDFButton.setTitle("View PDF", for: .normal)
        viewPDFButton.isHidden = true      // PDF 생성 후에만 보이도록 설정
        viewPDFButton.addTarget(self, action: #selector(showPDF), for: .touchUpInside)
        viewPDFButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPDFButton)     // 버튼을 뷰에 추가
        
        // 오토레이아웃 제약 조건 설정
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 이미지뷰 레이아웃 (중앙에 배치, 300x300 크기)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            // "Convert to PDF" 버튼 레이아웃 (이미지뷰 아래에 배치)
            convertButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            convertButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            // "사진 촬영" 버튼 레이아웃 (Convert to PDF 버튼 아래에 배치)
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: 20),
            
            // "View PDF" 버튼 레이아웃 (사진 촬영 버튼 아래에 배치)
            viewPDFButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewPDFButton.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 20)
        ])
    }
    
    // 카메라 열기 메서드
    @objc func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {  // 카메라가 사용 가능한지 확인
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self                              // 델리게이트 설정
            imagePicker.sourceType = .camera                         // 소스 타입을 카메라로 설정
            present(imagePicker, animated: true, completion: nil)    // 카메라 뷰를 보여줌
        } else {
            print("카메라를 사용할 수 없습니다.")
        }
    }
    
    // 이미지 선택 후 처리 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {  // 선택된 이미지가 있는지 확인
            imageView.image = selectedImage                       // 선택한 이미지를 이미지뷰에 설정
            convertButton.isHidden = false                        // 이미지가 선택되면 PDF 변환 버튼을 보이게 설정
        }
        picker.dismiss(animated: true, completion: nil)           // 이미지 피커 닫기
    }
    
    @objc func convertToPDF() {
        guard let image = imageView.image else { return }
        
        // 이미지의 방향에 따라 회전된 상태를 처리한 후 올바르게 그리기
        let fixedImage = fixImageOrientation(image: image)
        
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        
        // PDF 페이지 크기 설정 (A4 크기)
        let pdfPageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        var mediaBox = pdfPageBounds
        
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else { return }
        
        pdfContext.beginPDFPage(nil)
        
        // 이미지 크기 비율 유지하면서 PDF에 맞게 조정
        let imageSize = fixedImage.size
        let imageAspectRatio = imageSize.width / imageSize.height
        
        // A4 페이지 크기의 비율
        let pdfAspectRatio = pdfPageBounds.width / pdfPageBounds.height
        
        var drawingRect = CGRect.zero
        
        // 이미지가 세로가 더 길 때
        if imageAspectRatio > pdfAspectRatio {
            let scaledWidth = pdfPageBounds.width
            let scaledHeight = scaledWidth / imageAspectRatio
            let yOffset = (pdfPageBounds.height - scaledHeight) / 2
            drawingRect = CGRect(x: 0, y: yOffset, width: scaledWidth, height: scaledHeight)
        } else {
            // 이미지가 가로가 더 길 때
            let scaledHeight = pdfPageBounds.height
            let scaledWidth = scaledHeight * imageAspectRatio
            let xOffset = (pdfPageBounds.width - scaledWidth) / 2
            drawingRect = CGRect(x: xOffset, y: 0, width: scaledWidth, height: scaledHeight)
        }
        
        // 이미지를 PDF 페이지에 맞춰 그리기
        pdfContext.draw(fixedImage.cgImage!, in: drawingRect)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        // PDF 파일 저장 경로 설정
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
        pdfData.write(to: fileURL, atomically: true)
        
        pdfURL = fileURL
        viewPDFButton.isHidden = false // PDF 파일 생성 후 PDF 보기 버튼 보이기
    }
    
    // PDF 보기 메서드
    @objc func showPDF() {
        guard let pdfURL = pdfURL else { return }               // PDF 파일 경로가 있는지 확인
        
        let previewController = QLPreviewController()           // QLPreviewController 생성
        previewController.dataSource = self                     // 데이터 소스 설정
        present(previewController, animated: true, completion: nil)  // PDF 미리보기 띄우기
    }
    
    // 이미지 선택 취소 시 처리
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)          // 이미지 선택 취소 시 이미지 피커 닫기
    }
    
    // 이미지의 방향을 수정하는 함수
    func fixImageOrientation(image: UIImage) -> UIImage {
        // 이미지의 방향이 .up (기본값)인 경우 변경할 필요 없음
        if image.imageOrientation == .up {
            return image
        }
        
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi / 2)
            
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        guard let cgImage = image.cgImage else { return image }
        
        // 새로운 컨텍스트를 생성하여 이미지를 회전 및 변형 처리
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(image.size.width),
                                      height: Int(image.size.height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return image
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        // 수정된 이미지를 반환
        guard let newCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: newCGImage)
    }
}

// QLPreviewControllerDataSource 확장 (미리보기 기능 구현)
extension AddGridViewController: QLPreviewControllerDataSource {
    // 미리 볼 PDF 파일의 개수 설정
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1   // 미리볼 PDF 파일은 하나
    }
    
    // 미리 볼 PDF 파일 경로 설정
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL! as QLPreviewItem  // PDF 파일의 경로를 반환
    }
}
