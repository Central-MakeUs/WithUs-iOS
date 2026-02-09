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
        VStack(spacing: 24) {
            if let uiImage = UIImage(named: page.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
            }
            
            Text(page.description)
                .font(Font(UIFont.pretendard16Regular))
                .foregroundStyle(Color(UIColor.gray900))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 43)
        }
    }
}
