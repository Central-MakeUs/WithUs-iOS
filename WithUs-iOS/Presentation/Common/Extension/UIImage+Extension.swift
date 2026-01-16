//
//  UIImage+Extension.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/15/26.
//

import UIKit

extension UIImage {
    func cropToSquare() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero)
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = normalizedImage.cgImage else {
            return self
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let squareSize = min(width, height)
        
        let x = (width - squareSize) / 2
        let y = (height - squareSize) / 2
        let cropRect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return normalizedImage
        }
        
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
    }
}


extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        self.image = nil

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let data = data,
                let image = UIImage(data: data),
                error == nil
            else {
                print("❌ 이미지 로드 실패:", error ?? "unknown error")
                return
            }

            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
