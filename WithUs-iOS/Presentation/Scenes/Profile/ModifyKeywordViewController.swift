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
import ReactorKit

final class ModifyKeywordViewController: BaseViewController, ReactorKit.View {
    weak var coordinator: ProfileCoordinator?
    weak var homeCoordinator: HomeCoordinator?
    private let fetchKeywordsUseCase: FetchKeywordUseCaseProtocol
    private let fetchSelectedKeywordsUseCase: FetchSelectedKeywordUseCaseProtocol
    var disposeBag: DisposeBag = DisposeBag()
    
    private var keywords: [Keyword] = []
    private var selectedKeywords: Set<String> = []
    private var serverKeywordIds: Set<Int> = []
    private var customKeywords: [String] = []
    private let entryPoint: EntryPoint
    
    enum EntryPoint {
        case home
        case profile
    }
    
    private let topLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 16
    }
    
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
    
    private let setupButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
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
    
    init(
        fetchKeywordsUseCase: FetchKeywordUseCaseProtocol,
        fetchSelectedKeywordsUseCase: FetchSelectedKeywordUseCaseProtocol,
        entryPoint: EntryPoint
    ) {
        self.fetchKeywordsUseCase = fetchKeywordsUseCase
        self.fetchSelectedKeywordsUseCase = fetchSelectedKeywordsUseCase
        self.entryPoint = entryPoint
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
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(topLabelStackView)
        view.addSubview(collectionView)
        view.addSubview(setupButton)
        
        topLabelStackView.addArrangedSubview(titleLabel)
        topLabelStackView.addArrangedSubview(subTitleLabel)
    }
    
    override func setupConstraints() {
        topLabelStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(54)
            $0.horizontalEdges.equalToSuperview().inset(54)
        }
        
        setupButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topLabelStackView.snp.bottom).offset(70)
            $0.horizontalEdges.equalToSuperview().inset(24.5)
            $0.bottom.equalTo(setupButton.snp.top).offset(-12)
        }
    }
    
    override func setupActions() {
        setupButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: KeywordSettingReactor) {
        reactor.state.map { $0.isCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { strongSelf, _ in
                ToastView.show(message: "키워드 설정이 저장되었습니다.")
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { strongSelf, isLoading in
                isLoading ? strongSelf.showLoading() : strongSelf.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
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
        Task {
            do {
                switch entryPoint {
                case .home:
                    let keywords = try await fetchKeywordsUseCase.execute()
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.serverKeywordIds = Set(keywords.compactMap { Int($0.id) })
                        
                        self.keywords = keywords + [Keyword(
                            id: "add_button",
                            text: "새 키워드 추가",
                            isAddButton: true
                        )]
                        self.selectedKeywords = []
                        self.collectionView.reloadData()
                        self.updateSaveButtonState()
                    }
                    
                case .profile:
                    let selectedCellData = try await fetchSelectedKeywordsUseCase.execute()
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        
                        let keywords = selectedCellData.map { $0.keyword }
                        self.serverKeywordIds = Set(keywords.compactMap { Int($0.id) })
                        
                        self.selectedKeywords = Set(
                            selectedCellData
                                .filter { $0.isSelected }
                                .map { $0.keyword.id }
                        )
                        
                        self.keywords = keywords + [Keyword(
                            id: "add_button",
                            text: "새 키워드 추가",
                            isAddButton: true
                        )]
                        
                        self.collectionView.reloadData()
                        self.updateSaveButtonState()
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("❌ 키워드 조회 실패: \(error.localizedDescription)")
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
        reactor?.action.onNext(.updateKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords))
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
        
        setupButton.isEnabled = isValid
        setupButton.backgroundColor = isValid ? UIColor.gray900 : UIColor.gray300
        setupButton.setTitleColor(isValid ? UIColor.white : UIColor.gray500, for: .normal)
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
