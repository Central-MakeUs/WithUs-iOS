//
//  OnboardingPageView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/5/26.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: page.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:200, height: 200)
                .foregroundStyle(Color(UIColor.gray400))
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(Font(UIFont.pretendard(.semiBold, size: 32)))
                    .foregroundStyle(Color(UIColor.gray900))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(Font(UIFont.pretendard14Regular))
                    .foregroundStyle(Color(UIColor.gray900))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.horizontal, 43)
        }
    }
}

