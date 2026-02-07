//
//  MemoryViews.swift
//  WithUs-iOS
//
//  Created by Claude on 2/5/26.
//

import SwiftUI

// MARK: - Memory Full Cell View (DateRange + MemoryCell 통합)

struct MemoryFullCellView: View {
    let item: WeekMemorySummary
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(item.title)
                    .font(Font(UIFont.pretendard14SemiBold))
                    .foregroundColor(Color(uiColor: UIColor(hex: "#000000")))
                
                Spacer()
            }
            .frame(height: 24)
            
            ZStack {
                switch item.status {
                case .created:
                    if let imageURL = item.createdImageUrl,
                       let url = URL(string: imageURL) {
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
                    }
                    
                case .needCreate:
                    ZStack {
                        Color.black.opacity(0.7)
                        
                        VStack(spacing: 8) {
                            Text(getWeekText())
                                .font(Font(UIFont.pretendard16SemiBold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("추억이 만들어졌어요.\n화면을 터치해 확인해 보세요!")
                                .font(Font(UIFont.pretendard14Regular))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                case .unavailable:
                    ZStack {
                        Color.black.opacity(0.7)
                        
                        VStack(spacing: 8) {
                            Text("두 명 모두 6장 이상\n사진을 올려서\n추억이 자동 생성돼요.")
                                .font(Font(UIFont.pretendard14Regular))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                    }
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
    
    private func getWeekText() -> String {
        let components = item.title.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0]) \(components[1]) 추억"
        }
        return "이번주 추억"
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
