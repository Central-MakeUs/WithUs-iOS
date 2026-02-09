//
//  MemoryContentUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation
import UIKit

protocol MemoryContentUseCaseProtocol {
    func execute(image: UIImage, title: String) async throws -> String
    func execute(year: Int, month: Int) async throws -> MemorySummaryResponse
    func execute(weekEndDate: String, image: UIImage) async throws -> String
    func execute(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) async throws -> String
}

final class MemoryContentUseCase: MemoryContentUseCaseProtocol {
    private let repository: MemoryContentRepositoryProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let imageCompressor: ImageCompressor
    
    init(
        repository: MemoryContentRepositoryProtocol,
        uploadImageUseCase: UploadImageUseCaseProtocol,
        imageCompressor: ImageCompressor = .shared
    ) {
        self.repository = repository
        self.uploadImageUseCase = uploadImageUseCase
        self.imageCompressor = imageCompressor
    }
    
    func execute(image: UIImage, title: String) async throws -> String {
        print("🗜️ 이미지 압축 시작...")
        guard let compressedData = imageCompressor.compress(image, maxSizeKB: 500) else {
            throw UploadImageError.invalidImageData
        }
        
        print("📤 이미지 업로드 시작...")
        let uploadResult = try await uploadImageUseCase.execute(
            imageData: compressedData,
            imageType: .memory
        )
        
        print("✅ 서버에 imageKey 전달: \(uploadResult.imageKey)")
        try await repository.uploadImage(imageKey: uploadResult.imageKey, title: title)
        
        print("🎉 키워드 이미지 업로드 완료!")
        return uploadResult.imageKey
    }
    
    func execute(year: Int, month: Int) async throws -> MemorySummaryResponse {
        return try await repository.fetchImage(year: year, month: month)
    }
    
    func execute(weekEndDate: String, image: UIImage) async throws -> String {
        print("🗜️ 이미지 압축 시작...")
        guard let compressedData = imageCompressor.compress(image, maxSizeKB: 500) else {
            throw UploadImageError.invalidImageData
        }
        
        print("📤 이미지 업로드 시작...")
        let uploadResult = try await uploadImageUseCase.execute(
            imageData: compressedData,
            imageType: .memory
        )
        
        print("✅ 서버에 imageKey 전달: \(uploadResult.imageKey)")
        try await repository.makeMemory(weekEndDate: weekEndDate, imageKey: uploadResult.imageKey)
        
        print("🎉 키워드 이미지 업로드 완료!")
        return uploadResult.imageKey
    }
    
    func execute(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) async throws -> String {
        let result = try await repository.fetchDetailImage(
            memoryType: memoryType,
            weekEndDate: weekEndDate,
            targetId: targetId
        ).imageUrl
        
        return result
    }
}
