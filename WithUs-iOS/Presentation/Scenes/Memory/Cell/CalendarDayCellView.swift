//
//  CalendarMonthCellView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import SwiftUI

struct CalendarMonthCellView: View {
    let monthData: ArchiveCalendarResponse
    let onDateTap: (String) -> Void
    
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 년월
            Text("\(String(monthData.year))년 \(monthData.month)월")
                .font(Font(UIFont.pretendard16SemiBold))
                .foregroundColor(Color(uiColor: .gray900))
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
            
            // 요일
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(Font(UIFont.pretendard12Regular))
                        .foregroundColor(Color(uiColor: .gray900))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
            }
            .padding(.top, 12)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 6
            ) {
                ForEach(Array(monthData.days.enumerated()), id: \.offset) { index, day in
                    CalendarDayCellView(day: day)
                        .frame(height: 42)
                        .onTapGesture {
                            if day.hasPhoto {
                                onDateTap(day.date)
                            }
                        }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct CalendarDayCellView: View {
    let day: ArchiveDay
    
    var body: some View {
        ZStack {
            if day.date.isEmpty {
                Color.clear
            } else if day.hasPhoto {
                ZStack(alignment: .center) {
                    if day.kind == .combined {
                        CombinedThumbnailView(
                            meUrl: day.meImageThumbnailUrl,
                            partnerUrl: day.partnerImageThumbnailUrl
                        )
                    } else {
                        // 둘 중 하나 있는 거 표시
                        SingleThumbnailView(imageURL: day.meImageThumbnailUrl ?? day.partnerImageThumbnailUrl)
                    }
                    
                    Text(String(format: "%02d", day.day))
                        .font(Font(UIFont.pretendard12Regular))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(width: 42, height: 42)
                .cornerRadius(8)
                .clipped()
            } else {
                Text(String(format: "%02d", day.day))
                    .font(Font(UIFont.pretendard12Regular))
                    .foregroundColor(Color(uiColor: .gray500))
            }
        }
        .frame(width: 42, height: 42)
    }
}

// MARK: - Combined: 내 사진(위) + 상대방 사진(아래)

private struct CombinedThumbnailView: View {
    let meUrl: String?
    let partnerUrl: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // 위: 내 사진
            ThumbnailImageView(imageURL: meUrl)
                .frame(maxWidth: .infinity)
                .frame(height: 21) // 42의 절반
                .clipped(antialiased: false)
            
            // 아래: 상대방 사진
            ThumbnailImageView(imageURL: partnerUrl)
                .frame(maxWidth: .infinity)
                .frame(height: 21)
                .clipped(antialiased: false)
        }
    }
}


private struct SingleThumbnailView: View {
    let imageURL: String?
    
    var body: some View {
        ThumbnailImageView(imageURL: imageURL)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped(antialiased: false)
    }
}


private struct ThumbnailImageView: View {
    let imageURL: String?
    
    var body: some View {
        if let url = imageURL.flatMap({ URL(string: $0) }) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                case .empty:
                    Color.gray.opacity(0.3)
                @unknown default:
                    Color.gray.opacity(0.3)
                }
            }
        } else {
            Color.gray.opacity(0.3)
        }
    }
}
