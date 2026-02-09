//
//  MemoryDateSelectBottomSheet.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/5/26.
//

import Foundation
import UIKit
import SnapKit
import Then

final class MemoryDateSelectBottomSheetViewController: BaseViewController {
    var onDateSelected: ((Int, Int) -> Void)?
    var currentYear: Int = Calendar.current.component(.year, from: Date())
    var currentMonth: Int = Calendar.current.component(.month, from: Date())
    private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    private var viewTranslation = CGPoint(x: 0, y: 0)
    
    private let localBlackView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let barView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 3
    }
    
    private let leftArrowButton = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
    }
    
    private let rightArrowButton = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.setImage(UIImage(named: "ic_right_arrow"), for: .normal)
    }
    
    private let selectedLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.text = "2026년"
        $0.textColor = UIColor.gray900
    }
    
    private let selectedDateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    
    private lazy var monthCollectionView = MonthCollectionView().then {
        $0.delegate = self
    }
    
    private let selectButton = UIButton().then {
        $0.setTitle("날짜 선택", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedYear = currentYear
        selectedMonth = currentMonth
        updateSelectedLabel()
        updateMonthAvailability()
        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        localBlackView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.localBlackView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    override func setupUI() {
        view.addSubview(localBlackView)
        
        localBlackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.addSubview(barView)
        containerView.addSubview(selectedDateStackView)
        containerView.addSubview(monthCollectionView)
        containerView.addSubview(selectButton)
        
        selectedDateStackView.addArrangedSubview(leftArrowButton)
        selectedDateStackView.addArrangedSubview(selectedLabel)
        selectedDateStackView.addArrangedSubview(rightArrowButton)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        barView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 34, height: 5))
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        selectedDateStackView.snp.makeConstraints {
            $0.top.equalTo(barView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        monthCollectionView.snp.makeConstraints {
            $0.top.equalTo(selectedDateStackView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(selectButton.snp.top).offset(-36)
            $0.height.equalTo(208)
        }
        
        selectButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(confirmBtnTapped))
        localBlackView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        leftArrowButton.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
    }
    
    @objc private func leftArrowTapped() {
        selectedYear -= 1
        updateSelectedLabel()
        updateMonthAvailability()
        
        if selectedYear != currentYear || selectedMonth > 12 {
            selectedMonth = 0
            monthCollectionView.selectedMonth = nil
        }
    }

    
    @objc private func rightArrowTapped() {
        selectedYear += 1
        updateSelectedLabel()
        updateMonthAvailability()
        
        if selectedYear != currentYear {
            selectedMonth = 0
            monthCollectionView.selectedMonth = nil
        }
    }
    
    @objc private func selectButtonTapped() {
        guard selectedMonth > 0, selectedMonth <= 12 else {
            return
        }
        
        onDateSelected?(selectedYear, selectedMonth)
        dismissWithAnimation()
    }
    
    @objc private func backgroundTapped() {
        dismissWithAnimation()
    }
    
    private func updateSelectedLabel() {
        selectedLabel.text = "\(selectedYear)년"
    }
    
    private func updateMonthAvailability() {
        let maxMonth = calculateMaxSelectableMonth(for: selectedYear)
        
        if selectedYear == currentYear {
            monthCollectionView.selectedMonth = selectedMonth
        } else {
            monthCollectionView.selectedMonth = nil
        }
        
        monthCollectionView.updateMonthAvailability(for: selectedYear, maxMonth: maxMonth)
    }
    
    private func calculateMaxSelectableMonth(for year: Int) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        if year > currentYear {
            return 0
        }
        if year < currentYear {
            return 12
        }
        
        let lastDayOfCurrentMonth = getLastDayOfMonth(year: currentYear, month: currentMonth)
        
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = lastDayOfCurrentMonth
        
        guard let lastDate = calendar.date(from: dateComponents) else {
            return currentMonth
        }
        
        let weekday = calendar.component(.weekday, from: lastDate)
        if weekday == 7 {
            return currentMonth
        } else {
            return min(currentMonth + 1, 12)
        }
    }
    
    private func getLastDayOfMonth(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month + 1
        dateComponents.day = 0
        
        guard let date = calendar.date(from: dateComponents) else {
            return 31
        }
        
        return calendar.component(.day, from: date)
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.localBlackView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .changed:
            viewTranslation = translation
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if viewTranslation.y > 150 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                    self.localBlackView.alpha = 0
                }) { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = .identity
                    self.localBlackView.alpha = 1
                }
            }
        default:
            break
        }
    }
    
    
    @objc private func confirmBtnTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.localBlackView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
}

extension MemoryDateSelectBottomSheetViewController: MonthCollectionViewDelegate {
    func monthCollectionView(_ view: MonthCollectionView, didSelectMonth month: Int) {
        selectedMonth = month
        print("Selected: \(selectedYear)년 \(selectedMonth)월")
    }
}

