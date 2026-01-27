//
//  CalendarDayCellView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import SwiftUI

struct CalendarDayCellView: View {
    let day: CalendarDay
    
    var body: some View {
        ZStack {
            if day.day == 0 {
                Color.clear
                    .frame(width: 42, height: 42)
            } else if day.hasPhoto {
                ZStack {
                    if let imageURL = day.thumbnailURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    } else {
                        Color.gray.opacity(0.3)
                    }
                    
                    Text(String(format: "%02d", day.day))
                        .font(Font(UIFont.pretendard12Regular))
                        .foregroundColor(.white)
                }
                .frame(width: 42, height: 42)
                .cornerRadius(8)
                .clipped()
            } else {
                Text(String(format: "%02d", day.day))
                    .font(Font(UIFont.pretendard12Regular))
                    .foregroundColor(Color(uiColor: .gray500))
                    .frame(width: 42, height: 42)
            }
        }
        .frame(width: 42, height: 42)
    }
}
struct CalendarMonthHeaderView: View {
    let year: Int
    let month: Int
    let weekdays = ["일","월","화","수","목","금","토"]

    var body: some View {
        VStack(spacing: 6) {

            // Month
            Text("\(year)년 \(month)월")
                .font(Font(UIFont.pretendard16SemiBold))
                .foregroundColor(Color(uiColor: .gray900))
                .frame(height: 36)

            // Weekday
            HStack(spacing: 6) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(Font(UIFont.pretendard12Regular))
                        .foregroundColor(Color(uiColor: .gray600))
                        .frame(width: 42, height: 36)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 6)
        .background(Color.white)
    }
}
