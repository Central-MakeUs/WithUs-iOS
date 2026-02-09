//
//  MonthCellView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 2/5/26.
//

import SwiftUI

struct MonthCellView: View {
    let item: MonthItem
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color(UIColor.gray900) : Color.white)
            
            Text(item.name)
                .font(Font(UIFont.pretendard16SemiBold))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(8)
    }
    
    private var textColor: Color {
        if !item.isEnabled {
            return Color(UIColor.gray300)
        } else if isSelected {
            return .white
        } else {
            return Color(UIColor.gray900)
        }
    }
}
