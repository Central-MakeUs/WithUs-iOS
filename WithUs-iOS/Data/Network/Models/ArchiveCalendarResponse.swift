//
//  ArchiveCalendarResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

struct ArchiveCalendarResponse: Codable, Equatable {
    let year: Int
    let month: Int
    let days: [ArchiveDay]
}

struct ArchiveDay: Codable, Equatable {
    let date: String
    let meImageThumbnailUrl: String?
    let partnerImageThumbnailUrl: String?
}

extension ArchiveDay {
    enum PhotoKind {
        case single
        case combined
    }
    
    var kind: PhotoKind {
        let myHasImage = meImageThumbnailUrl != nil
        let partnerHasImage = partnerImageThumbnailUrl != nil
        
        return (myHasImage && partnerHasImage) ? .combined : .single
    }

    var dateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }

    var day: Int {
        guard let d = dateObject else { return 0 }
        return Calendar.current.component(.day, from: d)
    }
    
    var hasPhoto: Bool {
        meImageThumbnailUrl != nil || partnerImageThumbnailUrl != nil
    }
}
