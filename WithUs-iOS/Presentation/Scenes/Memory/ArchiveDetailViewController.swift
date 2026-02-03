//
//  ArchiveDetailViewController.swift
//  WithUs-iOS
//

import UIKit
import Then
import SnapKit

class ArchiveDetailViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    
    
    private let questionDetail: ArchiveQuestionDetailResponse
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
    
    init(questionDetail: ArchiveQuestionDetailResponse) {
        self.questionDetail = questionDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        
        // 날짜 표시 (answeredAt 기준)
//        let dateString = formatDate(questionDetail.myInfo.answeredAt ?? questionDetail.partnerInfo.answeredAt)
        let questionNumber = questionDetail.questionNumber
        navigationItem.titleView = UILabel().then {
            $0.text = "#\(String(format: "%02d", questionNumber))"
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
            $0.bottom.equalTo(pageControl.snp.top).offset(-12)  // ← 변경: 남은 공간 전부 차지
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
        // 질문 내용
        questionLabel.text = questionDetail.questionContent
        
        // 페이지 구성
        items = []
        
        // 1. 내 사진
        if let myImageUrl = questionDetail.myInfo.answerImageUrl {
            items.append(DetailCellData(
                kind: .single,
                imageUrl: myImageUrl,
                name: questionDetail.myInfo.name,
                time: formatTime(questionDetail.myInfo.answeredAt),
                profileUrl: questionDetail.myInfo.profileThumbnailImageUrl
            ))
        }
        
        // 2. 상대방 사진
        if let partnerImageUrl = questionDetail.partnerInfo.answerImageUrl {
            items.append(DetailCellData(
                kind: .single,
                imageUrl: partnerImageUrl,
                name: questionDetail.partnerInfo.name,
                time: formatTime(questionDetail.partnerInfo.answeredAt),
                profileUrl: questionDetail.partnerInfo.profileThumbnailImageUrl
            ))
        }
        
        // 3. 합성 사진 (둘 다 있을 때만)
        if questionDetail.myInfo.answerImageUrl != nil && questionDetail.partnerInfo.answerImageUrl != nil {
            items.append(DetailCellData(
                kind: .combined,
                myImageUrl: questionDetail.myInfo.answerImageUrl,
                partnerImageUrl: questionDetail.partnerInfo.answerImageUrl,
                myName: questionDetail.myInfo.name,
                partnerName: questionDetail.partnerInfo.name,
                myTime: formatTime(questionDetail.myInfo.answeredAt),
                partnerTime: formatTime(questionDetail.partnerInfo.answeredAt),
                myProfileUrl: questionDetail.myInfo.profileThumbnailImageUrl,
                partnerProfileUrl: questionDetail.partnerInfo.profileThumbnailImageUrl
            ))
        }
        
        updateUI()
    }
    
    private func updateUI() {
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        
        // 페이지 인디케이터 설정
        for i in 0..<items.count {
            if i == 0 {
                pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: i)
            } else {
                pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
            }
        }
        
        // 페이지가 1개 이하면 pageControl 숨김
        pageControl.isHidden = items.count <= 1
        
        collectionView.reloadData()
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        
        // "2025-01-15T14:30:00" → "2025.01.15"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
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
        
        for i in 0..<items.count {
            if i == page {
                pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: i)
            } else {
                pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
            }
        }
    }
}

// MARK: - Data Models

struct DetailCellData {
    let kind: DetailKind
    
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
