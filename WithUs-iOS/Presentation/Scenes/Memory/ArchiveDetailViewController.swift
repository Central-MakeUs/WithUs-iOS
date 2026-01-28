//
//  ArchiveDetailViewController.swift
//  WithUs-iOS
//

import UIKit
import Then
import SnapKit

final class BlurredDetailCell: UICollectionViewCell {
    static let reuseId = "BlurredDetailCell"
    
    private let blurredView = BlurredDetailImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(blurredView)
        blurredView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: SinglePhotoData) {
        blurredView.configure(
            imageURL: data.imageURL,
            name: data.name,
            time: data.time
        )
    }
}

final class CombinedImageCell: UICollectionViewCell {
    static let reuseId = "CombinedImageCell"
    
    private let combinedView = CombinedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(combinedView)
        combinedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: SinglePhotoData) {
        // TODO: Adjust configure parameters if different from below
        combinedView
            .configure(
                topImageURL: data.imageURL,
                topName: data.name,
                topTime: data.date,
                topCaption: "",
                bottomImageURL: data.imageURL,
                bottomName: data.name,
                bottomTime: data.date,
                bottomCaption: ""
            )
    }
}

class ArchiveDetailViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    
    private let questionLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
        $0.numberOfLines = 2
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
        $0.numberOfPages = 3
        $0.preferredIndicatorImage = UIImage(named: "page_control_inactive")
        $0.setIndicatorImage(UIImage(named: "page_control_active"), forPage: 0)
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
    
    private var photoData: SinglePhotoData?
    private var items: [SinglePhotoData] = []
    
    init(photoData: SinglePhotoData) {
        self.photoData = photoData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Removed pageViewController dataSource/delegate setup
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
        
        let dateText = photoData?.date ?? ""
        navigationItem.titleView = UILabel().then {
            $0.text = dateText
            $0.font = UIFont.pretendard16SemiBold
            $0.textColor = UIColor.gray900
        }
        
        setRightBarButton(image: UIImage(named: "ic_delete"))
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(questionLabel)
        view.addSubview(collectionView)
        
        collectionView.register(BlurredDetailCell.self, forCellWithReuseIdentifier: BlurredDetailCell.reuseId)
        collectionView.register(CombinedImageCell.self, forCellWithReuseIdentifier: CombinedImageCell.reuseId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(pageControl)
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(instagramButton)
        buttonStackView.addArrangedSubview(downloadButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(26)
            $0.height.equalTo(collectionView.snp.width).multipliedBy(1.6)
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
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func setupActions() {
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        instagramButton.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    private func configure() {
        guard let data = photoData else { return }
        
        questionLabel.text = data.question
        
        // Build test data array of three items with kinds
        
        // 1) single kind item
        let item1 = SinglePhotoData(
            date: data.date,
            question: data.question,
            imageURL: data.imageURL,
            name: data.name,
            time: data.time,
            kind: .single
        )
        
        // 2) combined kind item 1
        let item2 = SinglePhotoData(
            date: data.date,
            question: data.question,
            imageURL: data.imageURL,
            name: data.name,
            time: data.time,
            kind: .combined,
            secondImageURL: "https://1x.com/quickimg/4bf2f73146695b7e313936b92dff691b.jpg",
            secondName: "Second Name 1",
            secondTime: "12:00 PM"
        )
        
        // 3) combined kind item 2
        let item3 = SinglePhotoData(
            date: data.date,
            question: data.question,
            imageURL: "https://example.com/image3.jpg",
            name: "Third Name",
            time: "1:00 PM",
            kind: .combined,
            secondImageURL: "https://1x.com/quickimg/4bf2f73146695b7e313936b92dff691b.jpg",
            secondName: "Fourth Name",
            secondTime: "2:00 PM"
        )
        
        items = [item1, item2, item3]
        
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        collectionView.reloadData()
    }
    
    @objc private func shareButtonTapped() {
        print("공유하기")
    }
    
    @objc private func instagramButtonTapped() {
        print("인스타그램 공유")
    }
    
    @objc private func downloadButtonTapped() {
        print("다운로드")
    }
}

extension ArchiveDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlurredDetailCell.reuseId, for: indexPath) as? BlurredDetailCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: data)
            return cell
        case .combined:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CombinedImageCell.reuseId, for: indexPath) as? CombinedImageCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: data)
            return cell
        }
    }
    
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
        if page >= 0 && page < items.count {
            pageControl.currentPage = page
            for i in 0..<items.count {
                pageControl.setIndicatorImage(UIImage(named: "page_control_inactive"), forPage: i)
            }
            pageControl.setIndicatorImage(UIImage(named: "page_control_active"), forPage: page)
        }
    }
}

struct SinglePhotoData {
    enum Kind {
        case single
        case combined
    }
    
    let date: String
    let question: String
    let imageURL: String
    let name: String
    let time: String
    let kind: Kind
    
    let secondImageURL: String?
    let secondName: String?
    let secondTime: String?
    
    init(date: String, question: String, imageURL: String, name: String, time: String, kind: Kind, secondImageURL: String? = nil, secondName: String? = nil, secondTime: String? = nil) {
        self.date = date
        self.question = question
        self.imageURL = imageURL
        self.name = name
        self.time = time
        self.kind = kind
        self.secondImageURL = secondImageURL
        self.secondName = secondName
        self.secondTime = secondTime
    }
}
