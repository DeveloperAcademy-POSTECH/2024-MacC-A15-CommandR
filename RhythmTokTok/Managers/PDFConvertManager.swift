//
//  PDFConvertManager.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 10/9/24.
//

import UIKit
import PDFKit

struct PDFConvertManager {
    // 이미지 -> PDF로 변환하는 함수
    static func convertImageToPDF(image: UIImage) async -> Data? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fixedImage = fixImageOrientation(image: image)
                let pdfData = NSMutableData()
                let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
                
                let pdfPageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
                var mediaBox = pdfPageBounds
                
                guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                pdfContext.beginPDFPage(nil)
                
                let dpi = calculateImageDPI(image: fixedImage, pdfBounds: pdfPageBounds)
                print("이미지 DPI: \(dpi.horizontalDPI) DPI (가로), \(dpi.verticalDPI) DPI (세로)")
                
                let imageSize = fixedImage.size
                let imageAspectRatio = imageSize.width / imageSize.height
                let pdfAspectRatio = pdfPageBounds.width / pdfPageBounds.height
                var drawingRect = CGRect.zero
                
                if imageAspectRatio > pdfAspectRatio {
                    let scaledWidth = pdfPageBounds.width
                    let scaledHeight = scaledWidth / imageAspectRatio
                    let yOffset = (pdfPageBounds.height - scaledHeight) / 2
                    drawingRect = CGRect(x: 0, y: yOffset, width: scaledWidth, height: scaledHeight)
                } else {
                    let scaledHeight = pdfPageBounds.height
                    let scaledWidth = scaledHeight * imageAspectRatio
                    let xOffset = (pdfPageBounds.width - scaledWidth) / 2
                    drawingRect = CGRect(x: xOffset, y: 0, width: scaledWidth, height: scaledHeight)
                }
                
                pdfContext.draw(fixedImage.cgImage!, in: drawingRect)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
                
                continuation.resume(returning: pdfData as Data)
            }
        }
    }
    
    // PDF 파일을 임시 디렉토리에 저장하는 함수
    static func savePDF(data: Data) -> URL? {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            ErrorHandler.handleError(error: "Failed to PDF 저장 실패: \(error)")
            return nil
        }
    }
    
    // 이미지의 방향을 수정하는 함수
    static func fixImageOrientation(image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else {
            return image  // 이미지가 이미 정상 방향이면 그대로 반환
        }
        
        var transform = CGAffineTransform.identity
        
        // 방향에 따른 변환 설정
        transform = applyRotation(for: image.imageOrientation, size: image.size, currentTransform: transform)
        transform = applyMirroring(for: image.imageOrientation, size: image.size, currentTransform: transform)
        
        guard let cgImage = image.cgImage else { return image }
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
        
        let drawRect: CGRect
        if image.imageOrientation == .left || image.imageOrientation == .leftMirrored ||
            image.imageOrientation == .right || image.imageOrientation == .rightMirrored {
            drawRect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
        } else {
            drawRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
        
        context.draw(cgImage, in: drawRect)
        
        guard let newCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: newCGImage)
    }

    // 이미지 회전 변환 처리 함수
    static func applyRotation(for orientation: UIImage.Orientation, size: CGSize,
                              currentTransform: CGAffineTransform) -> CGAffineTransform {
        var transform = currentTransform
        
        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        return transform
    }

    // 이미지 반전 처리 함수
    static func applyMirroring(for orientation: UIImage.Orientation, size: CGSize,
                               currentTransform: CGAffineTransform) -> CGAffineTransform {
        var transform = currentTransform
        
        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
    
    // DPI 계산 함수
    static func calculateImageDPI(image: UIImage, pdfBounds: CGRect) -> (horizontalDPI: CGFloat, verticalDPI: CGFloat) {
        // 이미지 픽셀 크기
        let imagePixelWidth = image.size.width * image.scale
        let imagePixelHeight = image.size.height * image.scale
        
        // PDF 페이지 크기를 인치 단위로 변환 (72 pt = 1 inch)
        let pdfWidthInInches = pdfBounds.width / 72.0
        let pdfHeightInInches = pdfBounds.height / 72.0
        
        // 이미지의 가로, 세로 DPI 계산
        let horizontalDPI = imagePixelWidth / pdfWidthInInches
        let verticalDPI = imagePixelHeight / pdfHeightInInches
        
        return (horizontalDPI, verticalDPI)
    }
    
    // pdf Img 배열로 반환
    static func loadPDFPages(from fileURL: URL) -> [UIImage] {
        var pdfPages: [UIImage] = []
        guard let pdfDocument = PDFDocument(url: fileURL) else { return pdfPages }

        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                let pageRect = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    
                    UIColor.white.set()
                    ctx.fill(pageRect)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                pdfPages.append(img)
            }
        }
        
        return pdfPages
    }
}
