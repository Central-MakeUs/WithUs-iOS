//
//  HomeContentUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import UIKit

protocol FetchTodayQuestionUseCaseProtocol {
    func execute() async throws -> TodayQuestionResponse
}

final class FetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol {
    private let repository: HomeContentRepositoryProtocol
    
    init(repository: HomeContentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> TodayQuestionResponse {
        try await repository.fetchTodayQuestion()
    }
}

protocol UploadQuestionImageUseCaseProtocol {
    func execute(coupleQuestionId: Int, image: UIImage) async throws -> String
}

final class UploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol {
    private let repository: HomeContentRepositoryProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let imageCompressor: ImageCompressor
    
    init(
        repository: HomeContentRepositoryProtocol,
        uploadImageUseCase: UploadImageUseCaseProtocol,
        imageCompressor: ImageCompressor = .shared
    ) {
        self.repository = repository
        self.uploadImageUseCase = uploadImageUseCase
        self.imageCompressor = imageCompressor
    }
    
    func execute(coupleQuestionId: Int, image: UIImage) async throws -> String {
        print("🗜️ 이미지 압축 시작...")
        guard let compressedData = imageCompressor.compress(image, maxSizeKB: 500) else {
            throw UploadImageError.invalidImageData
        }
        
        print("📤 이미지 업로드 시작...")
        let uploadResult = try await uploadImageUseCase.execute(
            imageData: compressedData,
            imageType: .memory
        )
        
        // 3. 서버에 imageKey 전달
        print("✅ 서버에 imageKey 전달: \(uploadResult.imageKey)")
        try await repository.uploadQuestionImage(
            coupleQuestionId: coupleQuestionId,
            imageKey: uploadResult.imageKey
        )
        
        print("🎉 오늘의 질문 이미지 업로드 완료!")
        return uploadResult.imageKey
    }
}

// MARK: - Fetch Today Keyword
protocol FetchTodayKeywordUseCaseProtocol {
    func execute(coupleKeywordId: Int) async throws -> TodayKeywordResponse
}

final class FetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol {
    private let repository: HomeContentRepositoryProtocol
    
    init(repository: HomeContentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(coupleKeywordId: Int) async throws -> TodayKeywordResponse {
        return try await repository.fetchTodayKeyword(coupleKeywordId: coupleKeywordId)
    }
}

// MARK: - Upload Keyword Image
protocol UploadKeywordImageUseCaseProtocol {
    func execute(coupleKeywordId: Int, image: UIImage) async throws -> String
}

final class UploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol {
    private let repository: HomeContentRepositoryProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let imageCompressor: ImageCompressor
    
    init(
        repository: HomeContentRepositoryProtocol,
        uploadImageUseCase: UploadImageUseCaseProtocol,
        imageCompressor: ImageCompressor = .shared
    ) {
        self.repository = repository
        self.uploadImageUseCase = uploadImageUseCase
        self.imageCompressor = imageCompressor
    }
    
    func execute(coupleKeywordId: Int, image: UIImage) async throws -> String {
        // 1. 이미지 압축 (500KB 이하)
        print("🗜️ 이미지 압축 시작...")
        guard let compressedData = imageCompressor.compress(image, maxSizeKB: 500) else {
            throw UploadImageError.invalidImageData
        }
        
        // 2. UploadImageUseCase를 통해 S3 업로드
        print("📤 이미지 업로드 시작...")
        let uploadResult = try await uploadImageUseCase.execute(
            imageData: compressedData,
            imageType: .memory
        )
        
        // 3. 서버에 imageKey 전달
        print("✅ 서버에 imageKey 전달: \(uploadResult.imageKey)")
        try await repository.uploadKeywordImage(
            coupleKeywordId: coupleKeywordId,
            imageKey: uploadResult.imageKey
        )
        
        print("🎉 키워드 이미지 업로드 완료!")
        return uploadResult.imageKey
    }
}
