//
//  ArchivePhotoCellView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/27/26.
//

import SwiftUI
import UIKit

struct ArchivePhotoCellView: View {
    let photo: ArchivePhoto
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if photo.imageURL != nil {
                Color.gray.opacity(0.3)
            } else {
                Color.gray.opacity(0.2)
            }
            if let date = photo.date {
                Text(date)
                    .font(Font(UIFont.pretendard12SemiBold))
                    .foregroundColor(Color(uiColor: UIColor.gray900))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(.white)
                    .cornerRadius(6)
                    .padding(.top, 8)
                    .padding(.leading, 8)
            }
        }
    }
}
