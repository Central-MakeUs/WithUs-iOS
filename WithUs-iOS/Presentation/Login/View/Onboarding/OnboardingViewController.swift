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
    
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .systemBackground
        $0.delegate = self
        $0.dataSource = self
//        $0.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.identifier)
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = .label
        $0.pageIndicatorTintColor = .systemGray4
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Int> {
           cell, indexPath, item in
           cell.contentConfiguration = UIHostingConfiguration {
               OnboardingPageView()
           }
           .margins(.all, 0)
           .background(Color(.systemBackground))
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
        let count = 3
        pageControl.numberOfPages = count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: OnboardingPageCell.identifier,
//            for: indexPath
//        ) as? OnboardingPageCell else {
//            return UICollectionViewCell()
//        }
        
//        let page = viewModel.pages[indexPath.item]
//        cell.configure(with: page)
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: indexPath.item)
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        
                        
                        indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
//        let cell = OnboardingPageCell()
//        let targetSize = CGSize(
//            width: width,
//            height: UIView.layoutFittingCompressedSize.height
//        )
//        let size = cell.systemLayoutSizeFitting(
//            targetSize,
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
        return collectionView.bounds.size
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
//        viewModel.didSwipeToPage(index: page)
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
