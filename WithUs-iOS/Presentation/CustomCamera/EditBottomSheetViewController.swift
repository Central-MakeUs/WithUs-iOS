//
//  EditBottomSheetViewController.swift
//  WithUs-iOS
//
//  Created by Claude on 1/15/26.
//

import UIKit
import SnapKit
import Then

protocol EditBottomSheetDelegate: AnyObject {
    func didSelectText()
    func didSelectSticker(image: UIImage)
}

class EditBottomSheetViewController: UIViewController {
    
    weak var delegate: EditBottomSheetDelegate?
    
    struct OptionItem {
        let icon: String
        let title: String
        
        init(icon: String, title: String) {
            self.icon = icon
            self.title = title
        }
    }
    
    private let items: [OptionItem] = [
        OptionItem(icon: "text",      title: "텍스트"),
        OptionItem(icon: "location",  title: "위치"),
        OptionItem(icon: "music",     title: "음악"),
        OptionItem(icon: "delicious", title: "존맛탱"),
        OptionItem(icon: "boom_up",   title: "붐업"),
        OptionItem(icon: "boom_down", title: "붐따"),
        OptionItem(icon: "love",      title: "최고의 하루"),
        OptionItem(icon: "fire",      title: "화이팅!"),
        OptionItem(icon: "heart",     title: "사랑해")
    ]
    
    // MARK: - UI
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let bottomSheetView = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 32
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let handleBar = UIView().then {
        $0.backgroundColor = .gray500
        $0.layer.cornerRadius = 2.5
    }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.identifier)
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var bottomSheetViewBottomConstraint: Constraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(handleBar)
        bottomSheetView.addSubview(collectionView)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(300)
            self.bottomSheetViewBottomConstraint = $0.bottom.equalTo(view.snp.bottom).offset(300).constraint
        }
        
        handleBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(handleBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func setupGestures() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
    }
    
    // MARK: - Animation
    private func showBottomSheet() {
        bottomSheetViewBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideBottomSheet(completion: (() -> Void)? = nil) {
        bottomSheetViewBottomConstraint?.update(offset: 300)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    @objc private func dimmedViewTapped() {
        hideBottomSheet()
    }
    
    private func handleSelection(at index: Int) {
        let delegate = self.delegate
        
        if index == 0 {
            hideBottomSheet { delegate?.didSelectText() }
        } else {
            let item = items[index]
            guard let image = UIImage(named: item.icon) else { return }
            hideBottomSheet { delegate?.didSelectSticker(image: image) }
        }
    }
}

extension EditBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OptionCell.identifier,
            for: indexPath
        ) as? OptionCell else { return UICollectionViewCell() }
        
        cell.configure(with: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelection(at: indexPath.item)
    }
}

final class OptionCell: UICollectionViewCell {
    
    static let identifier = "OptionCell"
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .pretendard14Regular
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
        $0.isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .gray50
        contentView.layer.cornerRadius = 12
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with item: EditBottomSheetViewController.OptionItem) {
        iconImageView.image = UIImage(named: item.icon)
        titleLabel.text = item.title
    }
}
