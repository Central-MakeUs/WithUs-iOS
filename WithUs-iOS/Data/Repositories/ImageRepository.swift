//
//  ImageRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import Alamofire

protocol ImageRepositoryProtocol {
    func getPresignedURL(imageType: ImageType) async throws -> PresignedUrlResponse
    func uploadToS3(url: String, imageData: Data) async throws
}

final class ImageRepository: ImageRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func getPresignedURL(imageType: ImageType) async throws -> PresignedUrlResponse {
        let endpoint = ImageEndpoint.getPresignedURL(imageType: imageType)
        
        return try await networkService.request(
            endpoint: endpoint,
            responseType: PresignedUrlResponse.self
        )
        
    }
    
    func uploadToS3(url: String, imageData: Data) async throws {
        try await networkService.uploadToS3(url: url, imageData: imageData)
    }
}
