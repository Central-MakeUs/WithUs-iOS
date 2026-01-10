//
//  OnboardingPageCell.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/5/26.
//

import UIKit
import Then
import SnapKit

final class OnboardingPageCell: UICollectionViewCell {
    
    static let identifier = "OnboardingPageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemBlue
        $0.backgroundColor = .blue
    }
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "asdfasdf"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .systemGray
        $0.text = "asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleStackView)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(200)
        }
        
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(43)
            $0.bottom.equalToSuperview()
        }
    }
//    func configure(with page: OnboardingPage) {
//        imageView.image = UIImage(systemName: page.imageName)
//        titleLabel.text = page.title
//        subTitleLabel.text = page.description
//    }
}

import SwiftUI

struct OnboardingPageView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:200, height: 200)
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                Text("asdfasdf")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf")
                    .font(.system(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.horizontal, 43)
        }
    }
}

struct OnboardingPageCell_Previews: PreviewProvider {
    static var previews: some View {
//        let cell = OnboardingPageCell()
//        return cell.toPreview()
        
        OnboardingPageView()
    }
}
