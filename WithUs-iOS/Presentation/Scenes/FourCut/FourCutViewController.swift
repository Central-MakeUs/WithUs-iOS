//
//  FourCutViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

class FourCutViewController: BaseViewController {
    weak var coordinator: FourCutCoordinator?
    
    private let makeControl = MakeMemoryControl().then {
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 16
        $0.addShadow(
            color: .black,
            opacity: 0.12,
            offset: CGSize(width: 6, height: 6),
            radius: 4
        )
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "2026년 4월"
        $0.textColor = UIColor.gray900
        $0.font = UIFont.pretendard20SemiBold
    }
    
    private let toggleButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_toggle_down"), for: .normal)
    }
    
    private let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 0
    }
    
    private lazy var memoryCollectionView = MemoryCollectionView().then {
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryCollectionView.memoryData = MemoryItem.dummyData()
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(makeControl)
        view.addSubview(dateStackView)
        view.addSubview(memoryCollectionView)
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(toggleButton)
    }
    
    override func setupConstraints() {
        makeControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        dateStackView.snp.makeConstraints {
            $0.top.equalTo(makeControl.snp.bottom).offset(20)
            $0.left.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        toggleButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        memoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateStackView.snp.bottom).offset(10)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
    }
    
    override func setupActions() {
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        makeControl.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
    }
    
    override func setNavigation() {
        let attributedText = NSAttributedString(
            string: "추억",
            attributes: [.foregroundColor: UIColor.gray900, .font: UIFont.pretendard24Bold]
        )
        setLeftBarButton(attributedTitle: attributedText)
    }
    
    @objc private func toggleTapped() {
        coordinator?.showDateSelectionBottomSheet()
    }
    
    @objc private func didAddButtonTapped() {
        coordinator?.showPhotoPicker()
    }
}

extension FourCutViewController: MemoryCollectionViewDelegate {
    func memoryCollectionView(_ view: MemoryCollectionView, didSelectItemAt index: Int) {
        coordinator?.showMemoryDetail()
    }
}
