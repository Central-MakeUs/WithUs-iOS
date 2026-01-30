//
//  UploadImageUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct UploadImageResult {
    let imageKey: String
    
    init(from response: PresignedUrlResponse) {
        self.imageKey = response.imageKey
    }
}

protocol UploadImageUseCaseProtocol {
    func execute(
        imageData: Data,
        imageType: ImageType
    ) async throws -> UploadImageResult
}

final class UploadImageUseCase: UploadImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol
    
    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    func execute(
        imageData: Data,
        imageType: ImageType
    ) async throws -> UploadImageResult {
        print("1️⃣ Presigned URL 요청")
        let presignedResponse = try await imageRepository.getPresignedURL(
            imageType: imageType
        )
        
        print("✅ Presigned URL 받음")
        print("   - uploadUrl: \(presignedResponse.uploadUrl)")
        print("   - imageKey: \(presignedResponse.imageKey)")
        
        print("2️⃣ S3에 이미지 업로드 시작")
        try await imageRepository.uploadToS3(
            url: presignedResponse.uploadUrl,
            imageData: imageData
        )
        
        print("✅ 이미지 업로드 완료")
        
        // 3. 결과 반환
        return UploadImageResult(from: presignedResponse)
    }
}

enum UploadImageError: Error {
    case invalidImageData
    case uploadFailed
    
    var message: String {
        switch self {
        case .invalidImageData:
            return "이미지 데이터가 올바르지 않습니다."
        case .uploadFailed:
            return "이미지 업로드에 실패했습니다."
        }
    }
}
