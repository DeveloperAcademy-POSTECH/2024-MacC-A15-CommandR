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
    static func convertImageToPDF(image: UIImage) -> Data? {
        let fixedImage = fixImageOrientation(image: image)
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        
        // PDF 페이지 크기 설정 (A4 크기)
        let pdfPageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        var mediaBox = pdfPageBounds
        
        guard let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil) else { return nil }
        
        pdfContext.beginPDFPage(nil)
        
        // 이미지 크기 비율 유지하면서 PDF에 맞게 조정
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
        
        return pdfData as Data
    }
    
    // PDF 파일을 임시 디렉토리에 저장하는 함수
    static func savePDF(data: Data) -> URL? {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            print("PDF 저장 실패: \(error)")
            return nil
        }
    }
    
    // 이미지의 방향을 수정하는 함수
    static func fixImageOrientation(image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        
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
        
        guard let newCGImage = context.makeImage() else { return image }
        return UIImage(cgImage: newCGImage)
    }
}
