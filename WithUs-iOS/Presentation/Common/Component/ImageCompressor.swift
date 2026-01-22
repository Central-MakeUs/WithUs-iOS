//
//  ImageCompressor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import UIKit

final class ImageCompressor {
    static let shared = ImageCompressor()
    private init() {}
    func compress(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        let maxSizeBytes = maxSizeKB * 1024
        
        // 1. 먼저 리사이즈 (긴 쪽 기준 1920px)
        let resizedImage = resize(image, maxDimension: 1920)
        
        // 2. JPEG 압축 (품질 조정)
        var compression: CGFloat = 0.9
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        // 3. 목표 크기에 도달할 때까지 압축률 조정
        while let data = imageData, data.count > maxSizeBytes && compression > 0.1 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
            
            let currentSizeKB = data.count / 1024
            print("🗜️ 압축 중... 현재: \(currentSizeKB)KB, 목표: \(maxSizeKB)KB, 품질: \(Int(compression * 100))%")
        }
        
        if let finalData = imageData {
            let finalSizeKB = finalData.count / 1024
            print("✅ 압축 완료! 최종 크기: \(finalSizeKB)KB")
        }
        
        return imageData
    }
    
    /// 이미지 리사이즈
    private func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            // 가로가 긴 경우
            newSize = CGSize(width: min(maxDimension, size.width),
                           height: min(maxDimension, size.width) / aspectRatio)
        } else {
            // 세로가 긴 경우
            newSize = CGSize(width: min(maxDimension, size.height) * aspectRatio,
                           height: min(maxDimension, size.height))
        }
        
        // 이미 작은 이미지는 리사이즈하지 않음
        if newSize.width >= size.width && newSize.height >= size.height {
            return image
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}








