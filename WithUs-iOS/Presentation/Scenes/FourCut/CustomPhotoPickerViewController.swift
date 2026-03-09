//
//  CustomPhotoPickerViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation
import UIKit
import Photos
import SnapKit
import Then

class CustomPhotoPickerViewController: BaseViewController {
    weak var coordinator: FourCutCoordinator?
    
    private var allPhotos: PHFetchResult<PHAsset>?
    private var selectedAssets: [PHAsset] = []
    private let imageManager = PHCachingImageManager()
    private var selectedPhotosCollectionViewHeightConstraint: Constraint?
    private var previousCachedAssets: [PHAsset] = []

    private lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: photoCollectionViewFlowLayout).then {
        $0.backgroundColor = .white
        $0.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var photoCollectionViewFlowLayout = UICollectionViewFlowLayout().then { [weak self] in
        guard let self else { return }
        let spacing: CGFloat = 2
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow - 1)
        let itemWidth = (self.view.bounds.width - totalSpacing) / itemsPerRow
        $0.itemSize = CGSize(width: itemWidth, height: itemWidth)
        $0.minimumInteritemSpacing = spacing
        $0.minimumLineSpacing = spacing
    }
    
    private lazy var selectedPhotosCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: 60, height: 60)
        $0.minimumInteritemSpacing = 8
    }
    
    private lazy var selectedPhotosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: selectedPhotosCollectionViewFlowLayout).then {
        $0.register(SelectedPhotoCell.self, forCellWithReuseIdentifier: "SelectedPhotoCell")
        $0.delegate = self
        $0.dataSource = self
        $0.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let selectedContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let indicatorContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let selectedLabel = UILabel().then {
        $0.text = "12장의 사진을 선택해주세요."
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let doneButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard14SemiBold
        $0.setTitleColor(UIColor.gray50, for: .normal)
        $0.layer.cornerRadius = 16
        $0.backgroundColor = UIColor.gray300
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPhotoLibraryPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupUI() {
        view.addSubview(photoCollectionView)
        view.addSubview(selectedContainerView)
        selectedContainerView.addSubview(indicatorContainer)
        selectedContainerView.addSubview(selectedPhotosCollectionView)
        
        indicatorContainer.addSubview(selectedLabel)
        indicatorContainer.addSubview(doneButton)
    }
    
    override func setupConstraints() {
        selectedContainerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        indicatorContainer.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        selectedLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 66, height: 33))
        }
        
        selectedPhotosCollectionView.snp.makeConstraints {
            $0.top.equalTo(selectedLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
            self.selectedPhotosCollectionViewHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(selectedContainerView.snp.top)
        }
    }
    
    override func setupActions() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    override func setNavigation() {
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "앨범", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        setRightBarButton(image: image, action: #selector(cancelButtonTapped), tintColor: .black)
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Photo Library
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            loadPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async {
                        self?.loadPhotos()
                    }
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        photoCollectionView.reloadData()
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "앨범 권한 필요",
            message: "기기에 저장된 사진을 추억 기록 콘텐츠로 업로드하기 위해 앨범 접근이 필요합니다. 설정에서 이를 변경할 수 있습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        coordinator?.pop()
    }
    
    @objc private func doneButtonTapped() {
        guard selectedAssets.count == 12 else {
            let alert = UIAlertController(
                title: "사진을 12장 선택해주세요",
                message: "현재 \(selectedAssets.count)장이 선택되었습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        Task { [weak self] in
            guard let self = self else { return }

            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            var images: [UIImage] = []
            images.reserveCapacity(12)

            for asset in self.selectedAssets {
                if let image = await self.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 1080, height: 1080),
                    contentMode: .aspectFill,
                    options: options
                ) {
                    images.append(image)
                }
            }

            await MainActor.run {
                guard images.count == 12 else { return }
                self.coordinator?.showFilterSelection(images)
            }
        }
    }

    private func requestImage(
        for asset: PHAsset,
        targetSize: CGSize,
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions
    ) async -> UIImage? {
        await withCheckedContinuation { continuation in
            var resumed = false
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, info in
                guard !resumed else { return }
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                let isError = info?[PHImageErrorKey] != nil
                let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false

                if isError || isCancelled || !isDegraded {
                    resumed = true
                    continuation.resume(returning: image)
                }
            }
        }
    }

    private func updateSelectedContainerVisibility() {
        let newHeight: CGFloat = selectedAssets.isEmpty ? 0 : 60
        
        selectedPhotosCollectionViewHeightConstraint?.update(offset: newHeight)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func removePhotoButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < selectedAssets.count else { return }
        
        let deletedAsset = selectedAssets[index]
        selectedAssets.remove(at: index)
        
        var indexPathsToReload: [IndexPath] = []
        if let allPhotos = allPhotos {
            for i in 0..<allPhotos.count {
                let asset = allPhotos.object(at: i)
                if selectedAssets.contains(asset) || asset == deletedAsset {
                    indexPathsToReload.append(IndexPath(item: i, section: 0))
                }
            }
        }
        
        selectedPhotosCollectionView.performBatchUpdates({
            selectedPhotosCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { _ in
            self.selectedPhotosCollectionView.reloadData()
        })
        
        photoCollectionView.reloadItems(at: indexPathsToReload)
        updateSelectedContainerVisibility()
    }
}

extension CustomPhotoPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photoCollectionView {
            return allPhotos?.count ?? 0
        } else {
            return selectedAssets.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            
            guard let asset = allPhotos?.object(at: indexPath.item) else { return cell }
            
            let isSelected = selectedAssets.contains(asset)
            cell.configure(with: asset, isSelected: isSelected, imageManager: imageManager)
            
            if isSelected, let index = selectedAssets.firstIndex(of: asset) {
                cell.setSelectionNumber(index + 1)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedPhotoCell", for: indexPath) as! SelectedPhotoCell
            
            let asset = selectedAssets[indexPath.item]
            cell.configure(with: asset, imageManager: imageManager, index: indexPath.item)
            cell.removeButton.tag = indexPath.item
            cell.removeButton.addTarget(self, action: #selector(removePhotoButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
}

extension CustomPhotoPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == photoCollectionView {
            guard let asset = allPhotos?.object(at: indexPath.item) else { return }
            
            if let index = selectedAssets.firstIndex(of: asset) {
                selectedAssets.remove(at: index)
                var indexPathsToReload: [IndexPath] = [indexPath]
                if let allPhotos = allPhotos {
                    for i in 0..<allPhotos.count {
                        if selectedAssets.contains(allPhotos.object(at: i)) {
                            indexPathsToReload.append(IndexPath(item: i, section: 0))
                        }
                    }
                }
                
                selectedPhotosCollectionView.performBatchUpdates({
                    selectedPhotosCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }, completion: { _ in
                    self.selectedPhotosCollectionView.reloadData()
                })
                
                photoCollectionView.reloadItems(at: indexPathsToReload)
                self.updateSelectedContainerVisibility()
                
            } else {
                guard selectedAssets.count < 12 else { return }
                
                let isFirstItem = selectedAssets.isEmpty
                selectedAssets.append(asset)
                
                if isFirstItem {
                    updateSelectedContainerVisibility()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        self.selectedPhotosCollectionView.reloadData()
                        let lastIndexPath = IndexPath(item: self.selectedAssets.count - 1, section: 0)
                        self.selectedPhotosCollectionView.scrollToItem(at: lastIndexPath, at: .right, animated: true)
                    }
                } else {
                    let newIndex = selectedAssets.count - 1
                    selectedPhotosCollectionView.performBatchUpdates({
                        selectedPhotosCollectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
                    }, completion: { _ in
                        let lastIndexPath = IndexPath(item: self.selectedAssets.count - 1, section: 0)
                        self.selectedPhotosCollectionView.scrollToItem(at: lastIndexPath, at: .right, animated: true)
                    })
                }
                photoCollectionView.reloadItems(at: [indexPath])
            }
            
            doneButton.backgroundColor = selectedAssets.count == 12 ? UIColor.redWarning : UIColor.gray300
        }
    }
}

extension CustomPhotoPickerViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == photoCollectionView else { return }
        updateCachedAssets()
    }
    
    private func updateCachedAssets() {
        guard let allPhotos = allPhotos else { return }

        let visibleIndexPaths = photoCollectionView.indexPathsForVisibleItems
        guard !visibleIndexPaths.isEmpty else { return }

        let scale = UIScreen.main.scale
        let itemWidth = (view.bounds.width - 4) / 3
        let targetSize = CGSize(width: itemWidth * scale, height: itemWidth * scale)

        let cacheOptions = PHImageRequestOptions()
        cacheOptions.deliveryMode = .opportunistic
        cacheOptions.resizeMode = .exact
        cacheOptions.isNetworkAccessAllowed = true

        let newAssets = visibleIndexPaths.compactMap { allPhotos.object(at: $0.item) }

        imageManager.stopCachingImages(for: previousCachedAssets,
                                       targetSize: targetSize,
                                       contentMode: .aspectFill,
                                       options: cacheOptions)

        imageManager.startCachingImages(for: newAssets,
                                        targetSize: targetSize,
                                        contentMode: .aspectFill,
                                        options: cacheOptions)

        previousCachedAssets = newAssets
    }
}
