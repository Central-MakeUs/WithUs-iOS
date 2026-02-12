//
//  UpdateProfileUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(
        nickname: String,
        birthday: String,
        profileImage: Data?,
        isImageUpdated: Bool
    ) async throws -> User
}

final class UpdateCompleteProfileUseCase: UpdateProfileUseCaseProtocol {
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let updateUserRepository: UpdateUserRepositoryProtocol
    
    init(uploadImageUseCase: UploadImageUseCaseProtocol, updateUserRepository: UpdateUserRepositoryProtocol) {
        self.uploadImageUseCase = uploadImageUseCase
        self.updateUserRepository = updateUserRepository
    }
    
    func execute(
           nickname: String,
           birthday: String,
           profileImage: Data?,
           isImageUpdated: Bool  // 추가
       ) async throws -> User {
           
           var imageKey: String? = nil
           
           // 이미지가 변경됐고 새 이미지가 있을 때만 업로드
           if isImageUpdated, let imageData = profileImage {
               print("🖼️ 프로필 이미지 업로드 시작")
               let uploadResult = try await uploadImageUseCase.execute(
                   imageData: imageData,
                   imageType: .profile
               )
               imageKey = uploadResult.imageKey
               print("✅ 이미지 업로드 완료: \(imageKey ?? "")")
           }
           // isImageUpdated: true & profileImage: nil → imageKey nil 그대로 (삭제)
           // isImageUpdated: false → imageKey nil 그대로 (변경 안 함)
           
           print("👤 프로필 업데이트 시작")
           let response = try await updateUserRepository.updateProfile(
               nickname: nickname,
               birthday: birthday,
               imageKey: imageKey,
               isImageUpdated: isImageUpdated
           )
           
           print("✅ 프로필 설정 완료!")
           return User(from: response)
       }

}
