//
//  ArchiveListResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

struct ArchiveListResponse: Decodable {
    let archiveList: [ArchiveItem]
    let hasNext: Bool
    let nextCursor: String?
}

struct ArchiveItem: Decodable {
    let date: String
    let imageInfoList: [ArchiveImageInfo]
}

struct ArchiveImageInfo: Codable {
    let archiveType: String
    let id: Int
    let myImageUrl: String?
    let partnerImageUrl: String?
}

struct ArchivePhotoViewModel {
    let date: String
    let kind: PhotoKind
    let archiveType: String
    let id: Int
    let myImageUrl: String?
    let partnerImageUrl: String?
    
    enum PhotoKind {
        case single
        case combined
    }
    
    static func from(_ item: ArchiveItem) -> [ArchivePhotoViewModel] {
        return item.imageInfoList.map { imageInfo in
            let myHasImage = imageInfo.myImageUrl != nil
            let partnerHasImage = imageInfo.partnerImageUrl != nil
            
            let kind: PhotoKind = (myHasImage && partnerHasImage) ? .combined : .single
            
            return ArchivePhotoViewModel(
                date: item.date,
                kind: kind,
                archiveType: imageInfo.archiveType,
                id: imageInfo.id,
                myImageUrl: imageInfo.myImageUrl,
                partnerImageUrl: imageInfo.partnerImageUrl
            )
        }
    }
}
