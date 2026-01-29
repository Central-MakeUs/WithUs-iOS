//
//  ArchiveDetailData.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/29/26.
//

import Foundation

struct SinglePhotoData {
    enum Kind {
        case single
        case combined
    }
    
    let date: String
    let question: String
    let imageURL: String
    let name: String
    let time: String
    let kind: Kind
    
    let secondImageURL: String?
    let secondName: String?
    let secondTime: String?
    
    init(date: String, question: String, imageURL: String, name: String, time: String, kind: Kind, secondImageURL: String? = nil, secondName: String? = nil, secondTime: String? = nil) {
        self.date = date
        self.question = question
        self.imageURL = imageURL
        self.name = name
        self.time = time
        self.kind = kind
        self.secondImageURL = secondImageURL
        self.secondName = secondName
        self.secondTime = secondTime
    }
}
