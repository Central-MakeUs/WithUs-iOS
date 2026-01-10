//
//  OnboardingViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/5/26.
//

import SnapKit
import UIKit
import Then
import SwiftUI

final class OnboardingViewController: BaseViewController {
    
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            image: "heart.fill",
            title: "매일 발송되는 랜덤 질문",
            description: "주어진 질문에 사진 한 장으로\n서로의 마음을 확인해요"
        ),
        OnboardingPage(
            image: "photo.fill",
            title: "사진으로 일상을 함께",
            description: "쌓여가는 둘만의 사진 기록을\n한눈에 확인해요"
        ),
        OnboardingPage(
            image: "hand.wave.fill",
            title: "우리 취향대로 커플네컷",
            description: "원하는 사진으로\n둘만의 인생 네컷을 만들어봐요"
        )
    ]
     
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = UIColor.gray900
        $0.pageIndicatorTintColor = UIColor.gray300
        $0.numberOfPages = 3
        $0.preferredIndicatorImage = UIImage(named: "page_control_inactive")
        $0.setIndicatorImage(UIImage(named: "page_control_active"), forPage: 0)
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, OnboardingPage> {
        cell, indexPath, page in
        cell.contentConfiguration = UIHostingConfiguration {
            OnboardingPageView(page: page)
        }
        .margins(.all, 0)
        .background(Color(.white))
    }
    
    override func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(166)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-140)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-50)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = onboardingPages.count
        return onboardingPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let page = onboardingPages[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: page)
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
        for i in 0..<onboardingPages.count {
            pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
        }
        pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: page)
        nextButton.isHidden = (page != onboardingPages.count - 1)
    }
}

//import SwiftUI
//
//#if DEBUG
//struct OnboardingViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingViewController()
//            .toPreview()
//    }
//}
//#endif
