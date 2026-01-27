//
//  SettingHeaderView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import Foundation
import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(Font(UIFont.pretendard18SemiBold))
                .foregroundColor(Color(uiColor: .gray950))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .padding(.top, 16)
            
            Rectangle()
                .fill(Color(uiColor: .gray200))
                .frame(height: 1)
        }
        .background(Color(uiColor: .white))
    }
}

