//
//  ArchiveDetailViewController.swift
//  WithUs-iOS
//

import UIKit
import Then
import SnapKit

// MARK: - Detail Type

enum ArchiveDetailType {
    case question(ArchiveQuestionDetailResponse)
    case photo(ArchivePhotoDetailResponse)
}

class ArchiveDetailViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    
    private let detailType: ArchiveDetailType
    private var items: [DetailCellData] = []
    
    private let questionLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = UIColor.gray900
        $0.pageIndicatorTintColor = UIColor.gray300
        $0.preferredIndicatorImage = UIImage(named: "page_control_inactive")
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 32
    }
    
    private let shareButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_share"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    private let instagramButton = UIButton().then {
        $0.setImage(UIImage(named: "insta_logo"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    private let downloadButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_downLoad"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    // MARK: - Initialization
    
    init(detailType: ArchiveDetailType) {
        self.detailType = detailType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        
        let titleText: String
        switch detailType {
        case .question(let response):
            titleText = "#\(String(format: "%02d", response.questionNumber))"
            
        case .photo(let response):
            titleText = formatDateForNavigation(response.date)
        }
        
        navigationItem.titleView = UILabel().then {
            $0.text = titleText
            $0.font = UIFont.pretendard14SemiBold
            $0.textColor = UIColor.gray900
        }
        
        setRightBarButton(image: UIImage(named: "ic_delete"))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(questionLabel)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(buttonStackView)
        
        collectionView.register(BlurredDetailCell.self, forCellWithReuseIdentifier: BlurredDetailCell.reuseId)
        collectionView.register(CombinedImageCell.self, forCellWithReuseIdentifier: CombinedImageCell.reuseId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(instagramButton)
        buttonStackView.addArrangedSubview(downloadButton)
    }
    
    override func setupConstraints() {
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(80)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(26)
            $0.bottom.equalTo(pageControl.snp.top).offset(-12)
        }
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(2)
        }
        
        [shareButton, instagramButton, downloadButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(56)
            }
        }
    }
    
    override func setupActions() {
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        instagramButton.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    private func configureData() {
        switch detailType {
        case .question(let response):
            configureQuestionDetail(response)
            
        case .photo(let response):
            configurePhotoDetail(response)
        }
        
        updateUI()
    }
    
    private func configureQuestionDetail(_ response: ArchiveQuestionDetailResponse) {
        items = []
        
        let hasMyPhoto = response.myInfo.answerImageUrl != nil
        let hasPartnerPhoto = response.partnerInfo.answerImageUrl != nil
        
        // 둘 다 있으면 합성 사진만
        if hasMyPhoto && hasPartnerPhoto {
            items.append(DetailCellData(
                kind: .combined,
                question: response.questionContent,
                myImageUrl: response.myInfo.answerImageUrl,
                partnerImageUrl: response.partnerInfo.answerImageUrl,
                myName: response.myInfo.name,
                partnerName: response.partnerInfo.name,
                myTime: formatTime(response.myInfo.answeredAt),
                partnerTime: formatTime(response.partnerInfo.answeredAt),
                myProfileUrl: response.myInfo.profileThumbnailImageUrl,
                partnerProfileUrl: response.partnerInfo.profileThumbnailImageUrl
            ))
        }
        // 내 사진만
        else if let myImageUrl = response.myInfo.answerImageUrl {
            items.append(DetailCellData(
                kind: .single,
                question: response.questionContent,
                imageUrl: myImageUrl,
                name: response.myInfo.name,
                time: formatTime(response.myInfo.answeredAt),
                profileUrl: response.myInfo.profileThumbnailImageUrl
            ))
        }
        // 상대방 사진만
        else if let partnerImageUrl = response.partnerInfo.answerImageUrl {
            items.append(DetailCellData(
                kind: .single,
                question: response.questionContent,
                imageUrl: partnerImageUrl,
                name: response.partnerInfo.name,
                time: formatTime(response.partnerInfo.answeredAt),
                profileUrl: response.partnerInfo.profileThumbnailImageUrl
            ))
        }
    }
    
    private func configurePhotoDetail(_ response: ArchivePhotoDetailResponse) {
        items = []
        
        for archiveInfo in response.archiveInfoList {
            let currentQuestion = archiveInfo.question
            
            let hasMyPhoto = archiveInfo.myInfo.answerImageUrl != nil
            let hasPartnerPhoto = archiveInfo.partnerInfo.answerImageUrl != nil
            
            // 둘 다 있으면 합성 사진만
            if hasMyPhoto && hasPartnerPhoto {
                items.append(DetailCellData(
                    kind: .combined,
                    question: currentQuestion,
                    isSelected: archiveInfo.selected,
                    myImageUrl: archiveInfo.myInfo.answerImageUrl,
                    partnerImageUrl: archiveInfo.partnerInfo.answerImageUrl,
                    myName: archiveInfo.myInfo.name,
                    partnerName: archiveInfo.partnerInfo.name,
                    myTime: formatTime(archiveInfo.myInfo.answeredAt),
                    partnerTime: formatTime(archiveInfo.partnerInfo.answeredAt),
                    myProfileUrl: archiveInfo.myInfo.profileThumbnailImageUrl,
                    partnerProfileUrl: archiveInfo.partnerInfo.profileThumbnailImageUrl
                ))
            }
            // 내 사진만 있음
            else if let myImageUrl = archiveInfo.myInfo.answerImageUrl {
                items.append(DetailCellData(
                    kind: .single,
                    question: currentQuestion,
                    isSelected: archiveInfo.selected,
                    imageUrl: myImageUrl,
                    name: archiveInfo.myInfo.name,
                    time: formatTime(archiveInfo.myInfo.answeredAt),
                    profileUrl: archiveInfo.myInfo.profileThumbnailImageUrl
                ))
            }
            // 상대방 사진만 있음
            else if let partnerImageUrl = archiveInfo.partnerInfo.answerImageUrl {
                items.append(DetailCellData(
                    kind: .single,
                    question: currentQuestion,
                    isSelected: archiveInfo.selected,
                    imageUrl: partnerImageUrl,
                    name: archiveInfo.partnerInfo.name,
                    time: formatTime(archiveInfo.partnerInfo.answeredAt),
                    profileUrl: archiveInfo.partnerInfo.profileThumbnailImageUrl
                ))
            }
        }
    }
    
    private func updateUI() {
        pageControl.numberOfPages = items.count
        var initialIndex = 0
        
        switch detailType {
        case .photo:
            if let selectedIdx = items.firstIndex(where: { $0.isSelected }) {
                initialIndex = selectedIdx
            }
        case .question:
            initialIndex = 0
        }
        
        pageControl.currentPage = initialIndex
        
        for i in 0..<items.count {
            if i == initialIndex {
                pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: i)
            } else {
                pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
            }
        }
        pageControl.isHidden = items.count <= 1
        collectionView.reloadData()
        
        // selected 인덱스로 스크롤 (0이 아닐 때만)
        if initialIndex > 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let indexPath = IndexPath(item: initialIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
        
        // 초기 질문 설정
        if initialIndex < items.count {
            questionLabel.text = items[initialIndex].question
            questionLabel.isHidden = items[initialIndex].question?.isEmpty ?? true
        }
    }
    
    // MARK: - Helpers
    
    private func formatDateForNavigation(_ dateString: String) -> String {
        // "2025-01-15" → "2025.01.15"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func formatTime(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        // "2025-01-15T14:30:00" → "PM 02:30"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "a hh:mm"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    // MARK: - Actions
    
    @objc private func shareButtonTapped() {
        print("공유하기")
        // TODO: 공유 기능 구현
    }
    
    @objc private func instagramButtonTapped() {
        print("인스타그램 공유")
        // TODO: 인스타그램 공유 구현
    }
    
    @objc private func downloadButtonTapped() {
        print("다운로드")
        // TODO: 다운로드 기능 구현
    }
}

// MARK: - UICollectionViewDataSource

extension ArchiveDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let data = items[indexPath.item]
        
        switch data.kind {
        case .single:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BlurredDetailCell.reuseId,
                for: indexPath
            ) as? BlurredDetailCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: data)
            return cell
            
        case .combined:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CombinedImageCell.reuseId,
                for: indexPath
            ) as? CombinedImageCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: data)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArchiveDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        guard pageWidth > 0 else { return }
        
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = Int(round(fractionalPage))
        
        guard page >= 0 && page < items.count else { return }
        
        pageControl.currentPage = page
        
        // 페이지 인디케이터 업데이트
        for i in 0..<items.count {
            if i == page {
                pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: i)
            } else {
                pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
            }
        }
        
        // 현재 페이지의 질문으로 업데이트
        let currentItem = items[page]
        if let question = currentItem.question, !question.isEmpty {
            questionLabel.text = question
            questionLabel.isHidden = false
        } else {
            questionLabel.isHidden = true
        }
    }
}

// MARK: - Data Models

struct DetailCellData {
    let kind: DetailKind
    
    // 공통
    var question: String?  // 추가
    var isSelected: Bool = false

    // Single 용
    var imageUrl: String?
    var name: String?
    var time: String?
    var profileUrl: String?
    
    // Combined 용
    var myImageUrl: String?
    var partnerImageUrl: String?
    var myName: String?
    var partnerName: String?
    var myTime: String?
    var partnerTime: String?
    var myProfileUrl: String?
    var partnerProfileUrl: String?
}

enum DetailKind {
    case single
    case combined
}
