//
//  ModifyKeywordViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import RxSwift

final class ModifyKeywordViewController: BaseViewController {
    weak var coordinator: ProfileCoordinator?
    private let fetchKeywordsUseCase: FetchKeywordUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    private var keywords: [Keyword] = []
    private var selectedKeywords: Set<String> = []
    private var serverKeywordIds: Set<Int> = []
    private var customKeywords: [String] = []
    
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
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }
    
    private var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, KeywordCellData> { cell, indexPath, item in
        cell.contentConfiguration = UIHostingConfiguration {
            KeywordCellView(
                keyword: item.keyword.text,
                isSelected: item.isSelected,
                isAddButton: item.keyword.isAddButton
            )
        }
        .margins(.all, 0)
        .background(Color.clear)
    }
    
    init(fetchKeywordsUseCase: FetchKeywordUseCaseProtocol) {
        self.fetchKeywordsUseCase = fetchKeywordsUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchKeywords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        
        let attributed = NSAttributedString(
            string: "키워드 수정",
            attributes: [
                .foregroundColor: UIColor.gray900,
                .font: UIFont.pretendard18SemiBold
            ]
        )
        navigationItem.titleView = UILabel().then {
            $0.attributedText = attributed
        }
        
        let saveButton = UIBarButtonItem(
            title: "저장",
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        saveButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray300,
            .font: UIFont.pretendard16SemiBold
        ], for: .disabled)
        saveButton.setTitleTextAttributes([
            .foregroundColor: UIColor.redWarning,
            .font: UIFont.pretendard16SemiBold
        ], for: .normal)
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }
    
    private func fetchKeywords() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let keywords = try await fetchKeywordsUseCase.execute()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.serverKeywordIds = Set(keywords.compactMap { Int($0.id) })
                    
                    self.keywords = keywords + [Keyword(
                        id: "add_button",
                        text: "새 키워드 추가",
                        isAddButton: true
                    )]
                    self.collectionView.reloadData()
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    print("❌ 키워드 조회 실패: \(error.localizedDescription)")
                    // TODO: 에러 처리 (예: 알럿 표시)
                }
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        let defaultKeywordIds = keywords
            .filter { selectedKeywords.contains($0.id) && !$0.isAddButton && !$0.id.hasPrefix("custom_") }
            .compactMap { Int($0.id) }
        
        print("📤 서버 전송 데이터:")
        print("defaultKeywordIds: \(defaultKeywordIds)")
        print("customKeywords: \(customKeywords)")
        
        // TODO: Reactor action 호출
        // reactor.action.onNext(.updateKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords))
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showAddKeywordBottomSheet() {
        let bottomSheet = AddKeywordBottomSheet()
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        bottomSheet.onAddKeyword = { [weak self] newKeyword in
            guard let self = self else { return }
            
            let addButtonIndex = self.keywords.firstIndex(where: { $0.isAddButton }) ?? self.keywords.count
            let newKeywordItem = Keyword(
                id: "custom_\(UUID().uuidString)",
                text: newKeyword
            )
            self.keywords.insert(newKeywordItem, at: addButtonIndex)
            
            self.customKeywords.append(newKeyword)
            
            self.collectionView.reloadData()
            self.updateSaveButtonState()
        }
        
        present(bottomSheet, animated: true)
    }
    
    private func updateSaveButtonState() {
        let selectedCount = selectedKeywords.count
        let isValid = selectedCount == 3
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
}

extension ModifyKeywordViewController: UICollectionViewDataSource {
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

extension ModifyKeywordViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyword = keywords[indexPath.item]
        
        if keyword.isAddButton {
            showAddKeywordBottomSheet()
            return
        }
        
        if selectedKeywords.contains(keyword.id) {
            selectedKeywords.remove(keyword.id)
        } else {
            guard selectedKeywords.count < 3 else { return }
            selectedKeywords.insert(keyword.id)
        }
        
        collectionView.reloadItems(at: [indexPath])
        updateSaveButtonState()
    }
}
