//
//  UpdateProfileUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation

final class UpdateCompleteProfileUseCase: CompleteProfileUseCaseProtocol {
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let updateUserRepository: UpdateUserRepositoryProtocol
    
    init(uploadImageUseCase: UploadImageUseCaseProtocol, updateUserRepository: UpdateUserRepositoryProtocol) {
        self.uploadImageUseCase = uploadImageUseCase
        self.updateUserRepository = updateUserRepository
    }
    
    func execute(
        nickname: String,
        birthday: String,
        profileImage: Data?
    ) async throws -> User {
        
        var imageKey: String? = nil
        
        if let imageData = profileImage {
            print("🖼️ 프로필 이미지 업로드 시작")
            
            let uploadResult = try await uploadImageUseCase.execute(
                imageData: imageData,
                imageType: .profile
            )
            
            imageKey = uploadResult.imageKey
            print("✅ 이미지 업로드 완료: \(imageKey ?? "")")
        }
        
        // 2. 프로필 업데이트
        print("👤 프로필 업데이트 시작")
        
        let response = try await updateUserRepository.updateProfile(
            nickname: nickname,
            birthday: birthday,
            imageKey: imageKey
        )
        
        print("✅ 프로필 설정 완료!")
        
        return User(from: response)
    }
    
    func execute() async throws -> User {
        let response = try await updateUserRepository.getProfile()
        return User(from: response)
    }
}
