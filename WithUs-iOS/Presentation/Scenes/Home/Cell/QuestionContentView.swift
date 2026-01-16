//
//  QuestionContentView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import SwiftUI

// MARK: - Question Content View
struct QuestionContentView: View {
    let status: QuestionStatus
    let onCameraButtonTapped: () -> Void
    
    var body: some View {
        switch status {
        case .beforeTime(let remainingTime):
            BeforeTimeView(remainingTime: remainingTime)
            
        case .waitingBoth(let question):
            WaitingBothView(question: question, onCameraButtonTapped: onCameraButtonTapped)
            
        case .partnerOnly(let partnerImageURL, let question):
            PartnerOnlyView(partnerImageURL: partnerImageURL, question: question, onCameraButtonTapped: onCameraButtonTapped)
            
        case .bothAnswered(let myImageURL, let partnerImageURL, let question):
            BothAnsweredView(myImageURL: myImageURL, partnerImageURL: partnerImageURL, question: question)
        }
    }
}

// MARK: - 1. 시간 안됨
struct BeforeTimeView: View {
    let remainingTime: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text("오늘의 랜덤 질문이\n\(remainingTime) 후에 도착해요!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(uiColor: .gray900))
                .multilineTextAlignment(.center)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .gray100))
                .frame(height: 300)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 2. 시간 됨, 아무도 안보냄
struct WaitingBothView: View {
    let question: String
    let onCameraButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Q.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(uiColor: .gray900))
                
                Text(question)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(uiColor: .gray900))
                    .multilineTextAlignment(.center)
            }
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .gray100))
                .frame(height: 300)
                .overlay(
                    VStack(spacing: 12) {
                        Text("질문에 대한 나의 이야기를\n사진으로 표현해주세요")
                            .font(.system(size: 14))
                            .foregroundColor(Color(uiColor: .gray500))
                            .multilineTextAlignment(.center)
                        
                        Button(action: onCameraButtonTapped) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                Text("답변하기")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                    }
                )
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 3. 시간 됨, 상대만 보냄
struct PartnerOnlyView: View {
    let partnerImageURL: String
    let question: String
    let onCameraButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                Text("Q.")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(uiColor: .gray900))
                
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color(uiColor: .systemOrange))
                    .font(.system(size: 20))
            }
            
            Text(question)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(uiColor: .gray900))
                .multilineTextAlignment(.center)
            
            // 블러 처리된 상대방 사진
            AsyncImage(url: URL(string: partnerImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: 200)
            .cornerRadius(12)
            .clipped()
            .blur(radius: 20)
            .overlay(
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        Text("상대방")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text("답변완료")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            )
            
            VStack(spacing: 8) {
                Text("상대방이 먼저 사진을 보냈어요")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .gray500))
                
                Text("내 사진을 공개하면\n상대방의 사진도 확인할 수 있어요.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .gray500))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onCameraButtonTapped) {
                Text("나도 답변하기 →")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - 4. 둘 다 보냄
struct BothAnsweredView: View {
    let myImageURL: String
    let partnerImageURL: String
    let question: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("오늘의 질문")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(uiColor: .systemRed))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .systemRed).opacity(0.1))
                    .cornerRadius(12)
                
                Text("맛집")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .gray700))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .gray100))
                    .cornerRadius(12)
                
                Spacer()
                
                HStack(spacing: -12) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        )
                    
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        )
                }
            }
            .padding(.horizontal, 16)
            
            // 상대방 사진
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: partnerImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        Text("성희")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("맛이 어떤 건물 앞 내게 사주겠다던")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .padding(16)
                .frame(height: 200)
            }
            .padding(.horizontal, 16)
            
            // 내 사진
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: myImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        Text("조아")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("당신 오늘도 건물 앞 내게 사주겠다던")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .padding(16)
                .frame(height: 200)
            }
            .padding(.horizontal, 16)
        }
    }
}
