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
    let photoData: SinglePhotoData?  // 사진 있는 날짜의 첫 번째 데이터
}

struct PhotoData {
    let thumbnailURL: String
    let photoCount: Int?
    let photoData: SinglePhotoData  // 해당 날짜의 첫 번째 사진 데이터
}
