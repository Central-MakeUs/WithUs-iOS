//
//  QuestionData.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//
import Foundation

// MARK: - Question Status (정확히 4가지)
enum QuestionStatus {
    case beforeTime(remainingTime: String)           // 1. 시간 안됨
    case waitingBoth(question: String)               // 2. 시간 됨, 아무도 안보냄
    case partnerOnly(partnerImageURL: String, question: String)  // 3. 시간 됨, 상대만 보냄
    case bothAnswered(myImageURL: String, partnerImageURL: String, question: String) // 4. 둘 다 보냄
}

struct QuestionData {
    let id: String
    let question: String
    let scheduledTime: Date
    let myImageURL: String?
    let partnerImageURL: String?
    
    var status: QuestionStatus {
        let now = Date()
        
        if now < scheduledTime {
            // 1. 시간 전
            let timeInterval = scheduledTime.timeIntervalSince(now)
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            return .beforeTime(remainingTime: "\(hours)시간 \(minutes)분")
        } else {
            // 시간 후
            switch (myImageURL, partnerImageURL) {
            case (let myURL?, let partnerURL?):
                // 4. 둘 다 보냄
                return .bothAnswered(myImageURL: myURL, partnerImageURL: partnerURL, question: question)
                
            case (nil, let partnerURL?):
                // 3. 상대만 보냄
                return .partnerOnly(partnerImageURL: partnerURL, question: question)
                
            default:
                // 2. 아무도 안보냄 (내가만 보낸 경우는 없음)
                return .waitingBoth(question: question)
            }
        }
    }
}
