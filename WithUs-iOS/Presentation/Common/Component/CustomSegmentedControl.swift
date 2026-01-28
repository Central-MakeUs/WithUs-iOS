//
//  CustomSegmentedControl.swift
//  WithUs-iOS
//
//  Created on 1/27/26.
//

import UIKit
import SnapKit
import Then

protocol CustomSegmentedControlDelegate: AnyObject {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectSegmentAt index: Int)
}

class CustomSegmentedControl: UIView {
    
    weak var delegate: CustomSegmentedControlDelegate?
    
    private var segments: [String] = []
    private var buttons: [UIButton] = []
    private(set) var selectedIndex: Int = 0
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#F0F0F0")
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let selectionView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 18
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    init(segments: [String]) {
        self.segments = segments
        super.init(frame: .zero)
        setupUI()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(selectionView)
        containerView.addSubview(stackView)
        
        containerView.clipsToBounds = false
        containerView.layer.masksToBounds = false
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
    }
    
    private func setupButtons() {
        for (index, title) in segments.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.gray600, for: .normal)
            button.setTitleColor(UIColor.gray900, for: .selected)
            button.titleLabel?.font = UIFont.pretendard14Regular
            button.tag = index
            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        if !buttons.isEmpty {
            buttons[0].isSelected = true
            updateButtonFont(at: 0)
        }
    }
    
    @objc private func segmentTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        // 이전 버튼 폰트 변경
        buttons[selectedIndex].isSelected = false
        updateButtonFont(at: selectedIndex)
        
        // 새 버튼 선택 및 폰트 변경
        selectedIndex = newIndex
        buttons[selectedIndex].isSelected = true
        updateButtonFont(at: selectedIndex)
        
        updateSelectionView(animated: true)
        
        delegate?.segmentedControl(self, didSelectSegmentAt: selectedIndex)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < segments.count, index != selectedIndex else { return }
        
        buttons[selectedIndex].isSelected = false
        updateButtonFont(at: selectedIndex)
        
        selectedIndex = index
        buttons[selectedIndex].isSelected = true
        updateButtonFont(at: selectedIndex)
        
        updateSelectionView(animated: animated)
    }
    
    private func updateButtonFont(at index: Int) {
        let button = buttons[index]
        if button.isSelected {
            button.titleLabel?.font = UIFont.pretendard14SemiBold
        } else {
            button.titleLabel?.font = UIFont.pretendard14Regular
        }
    }
    
    private func updateSelectionView(animated: Bool) {
        let totalWidth = containerView.bounds.width - 12
        let spacing: CGFloat = 8
        let totalSpacing = spacing * CGFloat(segments.count - 1)
        let segmentWidth = (totalWidth - totalSpacing) / CGFloat(segments.count)
        
        let xPosition = 6 + (segmentWidth + spacing) * CGFloat(selectedIndex)
        
        selectionView.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(xPosition)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.width.equalTo(segmentWidth)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if selectionView.constraints.isEmpty {
            updateSelectionView(animated: false)
        }
    }
}
