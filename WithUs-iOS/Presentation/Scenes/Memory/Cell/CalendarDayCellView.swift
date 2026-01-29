//
//  CalendarMonthCellView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import SwiftUI

struct CalendarMonthCellView: View {
    let monthData: MonthData
    let onDateTap: (Date) -> Void
    
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
                            if day.hasPhoto, let date = day.date {
                                onDateTap(date)
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
    let day: CalendarDay
    
    var body: some View {
        ZStack {
            if day.day == 0 {
                Color.clear
            } else if day.hasPhoto {
                #warning("테스트중")
                //                ZStack {
                //                    if let imageURL = day.thumbnailURL {
                //                        AsyncImage(url: URL(string: imageURL)) { image in
                //                            image
                //                                .resizable()
                //                                .aspectRatio(contentMode: .fill)
                //                        } placeholder: {
                //                            Color.gray.opacity(0.3)
                //                        }
                //                    } else {
                //                        Color.gray.opacity(0.3)
                //                    }
                //
                //                    Text(String(format: "%02d", day.day))
                //                        .font(Font(UIFont.pretendard12Regular))
                //                        .foregroundColor(.white)
                //                }
                //                .frame(width: 42, height: 42)
                //                .cornerRadius(8)
                //                .clipped()
                ZStack {
                    // 임시: 랜덤 색상으로 테스트
                    Color(
                        red: Double.random(in: 0.3...0.7),
                        green: Double.random(in: 0.3...0.7),
                        blue: Double.random(in: 0.3...0.7)
                    )
                    
                    // 흰색 날짜
                    Text(String(format: "%02d", day.day))
                        .font(Font(UIFont.pretendard12Regular))
                        .foregroundColor(.white)
                        .fontWeight(.semibold)  // 더 잘 보이게
                }
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
