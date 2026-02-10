//
//  ImageGenerator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation
import UIKit
import Kingfisher
import SnapKit
import Then

final class ImageGenerator {
    static func generateImage(
        imageUrls: [String],
        dateText: String,
        frameColor: FrameColorType = .white,
        myProfileImageUrl: String?,
        partnerProfileImageUrl: String?
    ) async throws -> UIImage {
        guard imageUrls.count == 12 else {
            throw FourCutError.invalidImageCount
        }
        
        let images = try await downloadImages(urls: imageUrls)
        let myProfileImage = try? await downloadProfileImage(url: myProfileImageUrl)
        let partnerProfileImage = try? await downloadProfileImage(url: partnerProfileImageUrl)

        let transFormedDateText = formatWeekDateForUI(dateText)
        
        let finalImage = await createFourCutImageWithLayout(
            images: images,
            dateText: transFormedDateText,
            frameColor: frameColor,
            myProfileImage: myProfileImage,
            partnerProfileImage: partnerProfileImage
        )
        
        return finalImage
    }
    
    private static func downloadImages(urls: [String]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
            for (index, urlString) in urls.enumerated() {
                guard let url = URL(string: urlString) else {
                    throw FourCutError.invalidURL(urlString)
                }
                
                group.addTask {
                    let image = try await retrieveImage(from: url)
                    return (index, image)
                }
            }
            
            var downloadedImages: [Int: UIImage] = [:]
            
            for try await (index, image) in group {
                downloadedImages[index] = image
            }
            
            guard downloadedImages.count == urls.count else {
                throw FourCutError.downloadFailed
            }
            
            return downloadedImages.sorted { $0.key < $1.key }.map { $0.value }
        }
    }
    
    private static func downloadProfileImage(url: String?) async throws -> UIImage? {
        guard let urlString = url, let url = URL(string: urlString) else {
            return nil
        }
        return try await retrieveImage(from: url)
    }
    
    private static func retrieveImage(from url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @MainActor
    private static func createFourCutImageWithLayout(
        images: [UIImage],
        dateText: String,
        frameColor: FrameColorType,
        myProfileImage: UIImage?,
        partnerProfileImage: UIImage?
    ) -> UIImage {
        // 화면 크기
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let window = UIApplication.shared.windows.first
        let safeAreaTop = window?.safeAreaInsets.top ?? 0
        let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
        
        let navigationBarHeight: CGFloat = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController,
                   let navController = rootVC as? UINavigationController ?? rootVC.children.first as? UINavigationController {
                return navController.navigationBar.frame.height
            }
            return 54.0
        }()
        
        // TextInputViewController의 frameContainerView 크기 그대로
        let horizontalInset: CGFloat = 16
        let containerHeight: CGFloat = 120
        let gap: CGFloat = 8
        
        let frameWidth = screenWidth - (horizontalInset * 2)
        let frameHeight = screenHeight - safeAreaTop - navigationBarHeight - safeAreaBottom - containerHeight - gap
        
        // gridStackView 크기 계산
        let gridSpacing: CGFloat = 1.83
        let frameInset: CGFloat = 5.49
        let availableGridWidth = frameWidth - (frameInset * 2)
        let imageWidth = (availableGridWidth - (gridSpacing * 2)) / 3
        let gridHeight = (imageWidth * 4) + (gridSpacing * 3)
        
        print("frameHeight: \(frameHeight)")
        print("gridHeight: \(gridHeight)")
        
        // frameContainerView 생성
        let frameContainerView = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
        frameContainerView.backgroundColor = frameColor.backgroundColor
        
        // gridStackView
        let gridStackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = gridSpacing
        }
        
        var photoImageViews: [UIImageView] = []
        
        for _ in 0..<4 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = gridSpacing
            
            for _ in 0..<3 {
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                }
                
                photoImageViews.append(imageView)
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
        
        // 이미지 설정
        for (index, imageView) in photoImageViews.enumerated() {
            if index < images.count {
                imageView.image = images[index]
            }
        }
        
        // bottomBar
        let bottomBar = UIView()
        bottomBar.backgroundColor = frameColor.backgroundColor
        
        let dateLabel = UILabel().then {
            $0.text = dateText
            $0.textColor = frameColor.textColor
            $0.font = UIFont.didot(size: 34.76, isRegular: false)
        }
        
        let profileLabel = UILabel().then {
              $0.text = "by"
              $0.textColor = frameColor.textColor
              $0.font = UIFont.didot(size: 14.63, isRegular: true)
          }
          
          let myProfileImageView = UIImageView().then {
              $0.layer.cornerRadius = 11
              $0.clipsToBounds = true
              $0.image = myProfileImage ?? UIImage(systemName: "person.fill")
              $0.tintColor = .white
              $0.backgroundColor = UIColor.gray200
              $0.contentMode = .scaleAspectFill
          }
          
          let partnerProfileImageView = UIImageView().then {
              $0.layer.cornerRadius = 11
              $0.clipsToBounds = true
              $0.image = partnerProfileImage ?? UIImage(systemName: "person.fill")
              $0.tintColor = .white
              $0.backgroundColor = UIColor.gray200
              $0.contentMode = .scaleAspectFill
          }
          
          let coupleStackView = UIStackView().then {
              $0.axis = .horizontal
              $0.spacing = 1.83
              $0.alignment = .center
          }
          
        
        // 뷰 계층
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(dateLabel)
        bottomBar.addSubview(profileLabel)
        bottomBar.addSubview(coupleStackView)
        coupleStackView.addArrangedSubview(myProfileImageView)
        coupleStackView.addArrangedSubview(partnerProfileImageView)
        
        // TextInputViewController constraint 그대로 복사
        gridStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9.15)
            $0.leading.trailing.equalToSuperview().inset(5.49)
            $0.height.equalTo(gridHeight)  // ← gridHeight 지정
        }
        
        bottomBar.snp.makeConstraints {
            $0.top.equalTo(gridStackView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()  // ← 나머지 공간 차지
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(9.15)
        }
        coupleStackView.snp.makeConstraints {
            $0.right.equalToSuperview().inset(9.15)
            $0.bottom.equalToSuperview().inset(18.29)
        }
        
        myProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        partnerProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        profileLabel.snp.makeConstraints {
            $0.right.equalTo(coupleStackView.snp.left).offset(-7.32)
            $0.bottom.equalToSuperview().inset(18.29)
        }
        
        // 레이아웃 적용
        frameContainerView.setNeedsLayout()
        frameContainerView.layoutIfNeeded()
        
        // 렌더링
        let renderer = UIGraphicsImageRenderer(bounds: frameContainerView.bounds)
        return renderer.image { context in
            frameContainerView.layer.render(in: context.cgContext)
        }
    }
    
    private static func formatWeekDateForUI(_ weekEndDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: weekEndDate) else {
            return weekEndDate
        }
        
        let calendar = Calendar.current
        let weekOfMonth = calendar.component(.weekOfMonth, from: date)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let monthName = monthFormatter.string(from: date)
        
        return "Week\(weekOfMonth) \(monthName)"
    }
}

enum FourCutError: LocalizedError {
    case invalidImageCount
    case invalidURL(String)
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImageCount:
            return "이미지는 정확히 12장이어야 합니다."
        case .invalidURL(let url):
            return "유효하지 않은 URL입니다: \(url)"
        case .downloadFailed:
            return "이미지 다운로드에 실패했습니다."
        }
    }
}

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
