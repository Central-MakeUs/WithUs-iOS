//
//  SettingCellView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import SwiftUI

struct SettingCellView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(Font(UIFont.pretendard16Regular))
                .foregroundColor(Color(uiColor: .gray900))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("ic_arrow")
                .font(.system(size: 24))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(uiColor: .white))
    }
}

