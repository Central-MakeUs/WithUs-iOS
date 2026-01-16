//
//  KeywordCellView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import SwiftUI

struct KeywordCellView: View {
    let keyword: String
    let isSelected: Bool
    let isAddButton: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if isAddButton {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(uiColor: .gray700))
            }
            
            Text(keyword)
                .font(isSelected ? Font(UIFont.pretendard14SemiBold) : Font(UIFont.pretendard14Regular))
                .foregroundColor(Color(uiColor: isSelected ? .white : .gray900))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: isSelected ? UIColor.init(hex: "#E95053") : .gray50))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    Color(uiColor: isSelected ? .white : .gray400),
                    lineWidth: 1
                )
        )
    }
}

//struct KeywordCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 12) {
//            KeywordCellView(keyword: "맛집", isSelected: false, isAddButton: false, onTap: {})
//            KeywordCellView(keyword: "여행", isSelected: true, isAddButton: false, onTap: {})
//            KeywordCellView(keyword: "새 키워드 추가", isSelected: false, isAddButton: true, onTap: {})
//        }
//        .padding()
//    }
//}
