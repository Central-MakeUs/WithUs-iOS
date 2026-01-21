//
//  SignUpSetKeywordViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/21/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI

final class SignUpSetKeywordViewController: BaseViewController {
    weak var coordinator: SignUpCoordinator?
    
    private var keywords: [Keyword] = [
        Keyword(text: "맛집"),
        Keyword(text: "여행"),
        Keyword(text: "데이트"),
        Keyword(text: "카페"),
        Keyword(text: "산책"),
        Keyword(text: "영화"),
        Keyword(text: "공연"),
        Keyword(text: "운동"),
        Keyword(text: "쇼핑"),
        Keyword(text: "드라이브"),
        Keyword(text: "새 키워드 추가", isAddButton: true)
    ]
    
    private var selectedKeywords: Set<UUID> = []
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "연인과 자주 사진을 주고받는\n일상 키워드를 골라 주세요"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "새로운 키워드를 이후에 추가할 수 있어요"
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return cv
    }()
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.disabled
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.bold, size: 16)
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    private var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, KeywordCellData> { cell, indexPath, item in
        cell.contentConfiguration = UIHostingConfiguration {
            KeywordCellView(
                keyword: item.keyword.text,
                isSelected: item.isSelected,
                isAddButton: item.keyword.isAddButton,
            )
        }
        .margins(.all, 0)
        .background(Color.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        let attributed = createHighlightedAttributedString(
            fullText: "3/4",
            highlightText: "3",
            highlightColor: UIColor(hex: "#EF4044"),
            normalColor: UIColor.gray900,
            font: UIFont.pretendard16SemiBold
        )
        setRightBarButton(attributedTitle: attributed)
    }
    
    override func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(collectionView)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(52)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }
    
    @objc private func nextButtonTapped() {
        let selectedKeywordTexts = keywords
            .filter { selectedKeywords.contains($0.id) && !$0.isAddButton }
            .map { $0.text }
        
        print("선택된 키워드: \(selectedKeywordTexts)")
        
        
        coordinator?.showSignUpProfile()
    }
    
    func createHighlightedAttributedString(
        fullText: String,
        highlightText: String,
        highlightColor: UIColor,
        normalColor: UIColor,
        font: UIFont
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: font,
            .foregroundColor: normalColor
        ], range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
        }
        
        return attributedString
    }
    
    private func showAddKeywordBottomSheet() {
        let bottomSheet = AddKeywordBottomSheet()
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        bottomSheet.onAddKeyword = { [weak self] newKeyword in
            guard let self = self else { return }
            
            let addButtonIndex = self.keywords.firstIndex(where: { $0.isAddButton }) ?? self.keywords.count
            let newKeywordItem = Keyword(text: newKeyword)
            self.keywords.insert(newKeywordItem, at: addButtonIndex)
            
            self.selectedKeywords.insert(newKeywordItem.id)
            
            self.collectionView.reloadData()
            self.updateNextButtonState()
        }
        
        present(bottomSheet, animated: true)
    }
    
    private func updateNextButtonState() {
        let selectedCount = selectedKeywords.count
        nextButton.isEnabled = selectedCount >= 3
        nextButton.backgroundColor = selectedCount >= 3 ? UIColor.abled : UIColor.disabled
    }
}

extension SignUpSetKeywordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let keyword = keywords[indexPath.item]
        let isSelected = selectedKeywords.contains(keyword.id)
        let cellData = KeywordCellData(keyword: keyword, isSelected: isSelected)
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: cellData
        )
    }
}

extension SignUpSetKeywordViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyword = keywords[indexPath.item]
        
        if keyword.isAddButton {
            showAddKeywordBottomSheet()
            return
        }
        
        if selectedKeywords.contains(keyword.id) {
            selectedKeywords.remove(keyword.id)
        } else {
            selectedKeywords.insert(keyword.id)
        }
        
        collectionView.reloadItems(at: [indexPath])
        updateNextButtonState()
    }
}
