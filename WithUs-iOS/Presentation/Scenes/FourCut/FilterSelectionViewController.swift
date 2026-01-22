//
//  FilterSelectionViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit

enum PhotoFilterType {
    case original
    case blackAndWhite

    func apply(to image: UIImage) -> UIImage {
        switch self {
        case .original:
            return image
        case .blackAndWhite:
            return image.toGrayscale() ?? image
        }
    }
}

class FilterSelectionViewController: BaseViewController {
    
    // MARK: - Properties
    
    var selectedPhotos: [UIImage] = [] // PhotoSelectionViewController에서 받아옴
    private var selectedFilter: PhotoFilterType = .original
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "필터를 선택해 주세요"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let topBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    private let bottomBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let withusLabel = UILabel().then {
        $0.text = "WITHUS"
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 18
    }
    
    private let originalButton = UIButton().then {
        $0.setTitle("원본", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
    }
    
    private let blackWhiteButton = UIButton().then {
        $0.setTitle("흑백", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setTitleColor(.gray, for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
    }
    
    private var photoImageViews: [UIImageView] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGridWithStackView()
        displayPhotos()
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
        setRightBarButton(
            image: UIImage(systemName: "checkmark"),
            action: #selector(checkButtonTapped),
            tintColor: .black
        )
        self.navigationItem.title = "2/4"
        setLeftBarButton(image: UIImage(systemName: "xmark"))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(titleLabel)
        view.addSubview(frameContainerView)
        view.addSubview(buttonStackView)
        
        frameContainerView.addSubview(topBar)
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(withusLabel)
        
        buttonStackView.addArrangedSubview(originalButton)
        buttonStackView.addArrangedSubview(blackWhiteButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            $0.height.equalTo(50)
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-40)
        }
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        bottomBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(bottomBar.snp.top)
        }
        
        withusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func setupActions() {
        super.setupActions()
        
        originalButton.addTarget(self, action: #selector(originalButtonTapped), for: .touchUpInside)
        blackWhiteButton.addTarget(self, action: #selector(blackWhiteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Grid
    
    private func setupGridWithStackView() {
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6
            
            for col in 0..<2 {
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.layer.borderWidth = 1
                    $0.layer.borderColor = UIColor.black.cgColor
                }
                
                photoImageViews.append(imageView)
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Display Photos
    
    private func displayPhotos() {
        for (index, imageView) in photoImageViews.enumerated() {
            if index < selectedPhotos.count {
                let image = selectedPhotos[index]
                imageView.image = selectedFilter.apply(to: image)
            }
        }
    }
    
    private func updateFilterPreview() {
        displayPhotos()
    }
    
    private func updateButtonStates() {
        if selectedFilter == .original {
            // 원본 선택됨
            originalButton.backgroundColor = .black
            originalButton.setTitleColor(.white, for: .normal)
            originalButton.layer.borderWidth = 0
            
            blackWhiteButton.backgroundColor = .white
            blackWhiteButton.setTitleColor(.gray, for: .normal)
            blackWhiteButton.layer.borderWidth = 1
            blackWhiteButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        } else {
            // 흑백 선택됨
            originalButton.backgroundColor = .white
            originalButton.setTitleColor(.gray, for: .normal)
            originalButton.layer.borderWidth = 1
            originalButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
            
            blackWhiteButton.backgroundColor = .black
            blackWhiteButton.setTitleColor(.white, for: .normal)
            blackWhiteButton.layer.borderWidth = 0
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func checkButtonTapped() {
        // 텍스트 입력 화면으로 이동
        let textInputVC = TextInputViewController()
        textInputVC.selectedPhotos = selectedPhotos
        textInputVC.selectedFilter = selectedFilter
        navigationController?.pushViewController(textInputVC, animated: true)
    }
    
    @objc private func originalButtonTapped() {
        selectedFilter = .original
        updateButtonStates()
        updateFilterPreview()
    }
    
    @objc private func blackWhiteButtonTapped() {
        selectedFilter = .blackAndWhite
        updateButtonStates()
        updateFilterPreview()
    }
}

// MARK: - UIImage Extension

extension UIImage {
    func toGrayscale() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

