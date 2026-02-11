//
//  FourCutViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxCocoa

class FourCutViewController: BaseViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
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
    
    private var currentYear: Int = Calendar.current.component(.year, from: Date())
    private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDateLabel()
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
    
    func bind(reactor: MemoryReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.memorySummary?.weekMemorySummaries ?? [] }
            .distinctUntilChanged()
            .bind(to: memoryCollectionView.rx.memoryData)
            .disposed(by: disposeBag)
        
        reactor.state.map { "\($0.selectedYear)년 \($0.selectedMonth)월" }
            .distinctUntilChanged()
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                isLoading ? owner.showLoading() : owner.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
        
        
        reactor.state.compactMap { $0.detailMemory }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] url in
                guard !url.isEmpty else { return }
                self?.coordinator?.showMemoryDetail(url)
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.coupleInfo }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, data in
                let myName = data.meProfile.nickname
                let partnerName = data.partnerProfile.nickname
                
                strongSelf.makeControl.configure(myName: myName, partnerName: partnerName)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateDateLabel() {
        dateLabel.text = "\(currentYear)년 \(currentMonth)월"
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func toggleTapped() {
        guard let reactor = reactor else { return }
        coordinator?.showDateSelectionBottomSheet(
            currentYear: reactor.currentState.selectedYear,
            currentMonth: reactor.currentState.selectedMonth,
            onDateSelected: { [weak self] year, month in
                self?.reactor?.action.onNext(.selectDate(year: year, month: month))
            }
        )
    }
    
    @objc private func didAddButtonTapped() {
        coordinator?.showPhotoPicker()
    }
}

// MARK: - MemoryCollectionViewDelegate
extension FourCutViewController: MemoryCollectionViewDelegate {
    func memoryCollectionView(_ view: MemoryCollectionView, didSelectItemAt index: Int) {
        guard let summary = reactor?.currentState.memorySummary?.weekMemorySummaries[index] else { return }
        
        switch summary.status {
        case .unavailable:
            break
        case .needCreate:
            showCreateMemoryScreen(summary: summary)
            
        case .created:
            if summary.memoryType == .customMemory {
                reactor?.action
                    .onNext(
                        .fetchDetailMemory(
                            memoryType: summary.memoryType,
                            weekEndDate: nil,
                            targetId: summary.customMemoryId
                        )
                    )
            } else {
                reactor?.action
                    .onNext(
                        .fetchDetailMemory(
                            memoryType: summary.memoryType,
                            weekEndDate: summary.weekEndDate,
                            targetId: nil
                        )
                    )
            }
        }
    }
    
    private func showCreateMemoryScreen(summary: WeekMemorySummary) {
        guard let imageUrls = summary.needCreateImageUrls,
              imageUrls.count == 12,
              let weekEndDate = summary.weekEndDate else { return }
        
        reactor?.action.onNext(.createWeekMemory(
            imageUrls: imageUrls,
            weekEndDate: weekEndDate
        ))
    }
}

extension Reactive where Base: MemoryCollectionView {
    var memoryData: Binder<[WeekMemorySummary]> {
        return Binder(base) { collectionView, data in
            collectionView.memoryData = data
        }
    }
}

extension FourCutViewController: TextInputViewControllerDelegate {
    func didUploadSuccess() {
        coordinator?.showUploadSuccessAndPopToRoot()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ToastView.show(message: "추억이 생성되었어요!", icon: UIImage(named: "ic_ok"))
        }
    }
}
