//
//  HomeContentRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import Foundation

protocol HomeContentRepositoryProtocol {
    func fetchTodayQuestion() async throws -> TodayQuestionResponse
    
    func uploadQuestionImage(coupleQuestionId: Int, imageKey: String) async throws
    
    func fetchTodayKeyword(coupleKeywordId: Int) async throws -> TodayKeywordResponse
    
    func uploadKeywordImage(coupleKeywordId: Int, imageKey: String) async throws
}

final class HomeContentRepository: HomeContentRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchTodayQuestion() async throws -> TodayQuestionResponse {
        let endpoint = HomeContentEndpoint.getTodayQuestion
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: TodayQuestionResponse.self
        )
        
        return response
    }
    
    func uploadQuestionImage(coupleQuestionId: Int, imageKey: String) async throws {
        let endpoint = HomeContentEndpoint.uploadQuestionImage(
            coupleQuestionId: coupleQuestionId,
            imageKey: imageKey
        )
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
    
    func fetchTodayKeyword(coupleKeywordId: Int) async throws -> TodayKeywordResponse {
        let endpoint = HomeContentEndpoint.getTodayKeyword(coupleKeywordId: coupleKeywordId)
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: TodayKeywordResponse.self
        )
        
        return response
    }
    
    func uploadKeywordImage(coupleKeywordId: Int, imageKey: String) async throws {
        let endpoint = HomeContentEndpoint.uploadKeywordImage(
            coupleKeywordId: coupleKeywordId,
            imageKey: imageKey
        )
        
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
}

