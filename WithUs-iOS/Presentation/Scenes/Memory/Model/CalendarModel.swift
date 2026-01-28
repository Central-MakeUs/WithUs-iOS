//
//  CalendarModel.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/28/26.
//

import Foundation

struct MonthData {
    let year: Int
    let month: Int
    var days: [CalendarDay]
}

struct CalendarDay {
    let date: Date?
    let day: Int
    let hasPhoto: Bool
    let thumbnailURL: String?
}

struct PhotoData {
    let thumbnailURL: String
    let photoCount: Int?
}

struct ArchivePhoto {
    let id: String
    let date: String?
    let imageURL: String?
    let hugCount: String?
}

