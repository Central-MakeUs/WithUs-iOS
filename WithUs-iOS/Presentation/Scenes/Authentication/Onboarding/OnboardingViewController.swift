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
    
    weak var coordinator: AuthCoordinator?
    
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            image: "first",
            description: "매일 제시되는 질문에 사진으로 답하면,\n상대의 생각을 자연스럽게 엿볼 수 있어요."
        ),
        OnboardingPage(
            image: "second",
            description: "함께 정한 키워드로 사진 한 장씩,\n부담 없이 가볍고 다정한 일상 공유가 시작돼요."
        ),
        OnboardingPage(
            image: "third",
            description: "일주일의 일상 사진이 자동으로 추억이 되고,\n원하는 순간을 직접 담을 수도 있어요."
        )
    ]
    
    private var currentPage: Int = 0 {
        didSet {
            updateUI(for: currentPage)
        }
    }
     
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
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
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
        super.setupUI()
        view.addSubview(pageControl)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(56)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-46)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    
    private func updateUI(for page: Int) {
        let isLastPage = page == onboardingPages.count - 1
        
        nextButton.setTitle(isLastPage ? "시작하기" : "다음", for: .normal)
        pageControl.currentPage = page
        for i in 0..<onboardingPages.count {
            pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
        }
        pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: page)
    }
    
    @objc private func nextBtnTapped() {
        let isLastPage = currentPage == onboardingPages.count - 1
        
        if isLastPage {
            coordinator?.showLogin()
        } else {
            let nextPage = currentPage + 1
            let indexPath = IndexPath(item: nextPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentPage = nextPage
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
        currentPage = page
    }
}
