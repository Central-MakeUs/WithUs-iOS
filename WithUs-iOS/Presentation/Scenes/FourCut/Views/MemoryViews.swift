//
//  MemoryViews.swift
//  WithUs-iOS
//
//  Created by Claude on 2/5/26.
//

import SwiftUI

// MARK: - Memory Full Cell View (DateRange + MemoryCell 통합)

struct MemoryFullCellView: View {
    let item: MemoryItem
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(item.dateRange)
                    .font(Font(UIFont.pretendard14SemiBold))
                    .foregroundColor(Color(uiColor: UIColor(hex: "#000000")))
                
                Spacer()
            }
            .frame(height: 24)
            
            ZStack {
                if let imageURL = item.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                    GeometryReader { geometry in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            case .failure, .empty:
                                placeholderView
                            @unknown default:
                                placeholderView
                            }
                        }
                    }
                } else {
                    placeholderView
                    
                    VStack(spacing: 4) {
                        Text(item.title)
                            .font(Font(UIFont.pretendard14SemiBold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        if !item.subtitle.isEmpty {
                            Text(item.subtitle)
                                .font(Font(UIFont.pretendard12Regular))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .clipped()
        }
        .padding(.horizontal, 0)
        .background(Color.white)
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.3)
            
            VisualEffectBlur(blurStyle: .systemMaterial)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
