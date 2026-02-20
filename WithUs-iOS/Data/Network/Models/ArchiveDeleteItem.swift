//
//  ArchiveDeleteItem.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/20/26.
//

import Foundation

struct ArchiveDeleteItem: Codable, Hashable {
    var archiveType: String
    var id: Int
    var date: String
}

struct ArchiveBulkDeleteRequest: Codable {
    let items: [ArchiveDeleteItem]
}
