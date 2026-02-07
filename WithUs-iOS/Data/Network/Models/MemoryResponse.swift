//
//  MemoryResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation

struct MemorySummaryResponse: Codable {
    let monthKey: Int
    let weekMemorySummaries: [WeekMemorySummary]
}

struct WeekMemorySummary: Codable, Equatable {
    let memoryType: MemoryType
    let title: String
    let customMemoryId: Int?
    let weekEndDate: String?
    let status: MemoryStatus
    let needCreateImageUrls: [String]?
    let createdImageUrl: String?
    let createdAt: String
}

enum MemoryType: String, Codable, Equatable {
    case weekMemory = "WEEK_MEMORY"
    case customMemory = "CUSTOM_MEMORY"
}

enum MemoryStatus: String, Codable, Equatable {
    case unavailable = "UNAVAILABLE"
    case needCreate = "NEED_CREATE"
    case created = "CREATED"
}

struct MemoryResponse: Codable {
    let fourCuts: [FourCutItem]
    let nextCursor: String?
    let hasNext: Bool
}

struct FourCutItem: Codable {
    let fourCutId: Int
    let thumbnailUrl: String
    let createdAt: String
}
