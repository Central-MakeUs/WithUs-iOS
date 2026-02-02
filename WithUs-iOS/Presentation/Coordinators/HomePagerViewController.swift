//
//  HomePagerViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import UIKit
import Then
import SnapKit

final class HomePagerViewController: BaseViewController, UIPageViewControllerDelegate {
    
    private var fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol?
    var coordinator: HomeCoordinator?
    
    private lazy var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    private lazy var todayQuestionVC = TodayQuestionViewController()
    private lazy var todayDailyVC = TodayDailyViewController()
    private lazy var pages: [UIViewController] = [todayQuestionVC, todayDailyVC]
    
    func injectReactors(
        questionReactor: TodayQuestionReactor,
        dailyReactor: TodayDailyReactor,
        fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    ) {
        todayQuestionVC.coordinator = coordinator
        todayQuestionVC.reactor = questionReactor
        
        todayDailyVC.coordinator = coordinator
        todayDailyVC.reactor = dailyReactor
        
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
    }
    
    // MARK: - Before Setting (커플 연결 안됨)
    private let settingInviteCodeView = SettingInviteCodeView()
    
    // MARK: - Custom Segment UI
    private lazy var questionButton = UIButton().then {
        $0.setTitle("오늘의 질문", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.tag = 0
    }
    
    private lazy var dailyButton = UIButton().then {
        $0.setTitle("오늘의 일상", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.setTitleColor(UIColor.gray500, for: .normal)
        $0.tag = 1
    }
    
    private lazy var segmentStackView = UIStackView(arrangedSubviews: [questionButton, dailyButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = UIColor.gray200
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = UIColor.redWarning
    }
    
    // MARK: - Lifecycle
    override func setupUI() {
        super.setupUI()
        
        [underlineView, indicatorView, segmentStackView].forEach { view.addSubview($0) }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)
        
        view.addSubview(settingInviteCodeView)
        
        hideAllViews()
    }
    
    override func setupConstraints() {
        segmentStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        underlineView.snp.makeConstraints {
            $0.bottom.equalTo(segmentStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        indicatorView.snp.makeConstraints {
            $0.bottom.equalTo(segmentStackView.snp.bottom)
            $0.height.equalTo(2)
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.leading.equalToSuperview()
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentStackView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        settingInviteCodeView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setNavigation() {
        setRightBarButton(image: UIImage(named: "ic_bell"))
        
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "WITHUS", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    override func setupActions() {
        [questionButton, dailyButton].forEach {
            $0.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)
        }
        
        settingInviteCodeView.onTap = { [weak self] in
            self?.coordinator?.showInviteModal()
        }
    }
    
    // MARK: - Onboarding Status
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserStatus()
    }
    
    private func fetchUserStatus() {
        Task { [weak self] in
            guard let self, let useCase = self.fetchUserStatusUseCase else { return }
            
            do {
                let status = try await useCase.execute()
                await MainActor.run { self.handleOnboardingStatus(status) }
            } catch let error as NetworkError {
                print("❌ fetchUserStatus 에러: \(error.errorDescription)")
            } catch {
                print("❌ fetchUserStatus 에러: 다시 접속해주세요.")
            }
        }
    }
    
    private func handleOnboardingStatus(_ status: OnboardingStatus) {
        switch status {
        case .needUserSetup:
            coordinator?.handleNeedUserSetup()
            
        case .needCoupleConnect:
            showInviteCodeView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.coordinator?.showInviteModal()
            }
            
        case .needCoupleSetup, .completed:
            showPagerView()
        }
    }
    
    // MARK: - View State 전환
    private func hideAllViews() {
        settingInviteCodeView.isHidden = true
        segmentStackView.isHidden = true
        underlineView.isHidden = true
        indicatorView.isHidden = true
        pageViewController.view.isHidden = true
    }
    
    private func showInviteCodeView() {
        hideAllViews()
        settingInviteCodeView.isHidden = false
    }
    
    private func showPagerView() {
        hideAllViews()
        segmentStackView.isHidden = false
        underlineView.isHidden = false
        indicatorView.isHidden = false
        pageViewController.view.isHidden = false
    }
    
    // MARK: - Segment 탭
    @objc private func segmentButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        updateSegmentUI(index: index)
        
        let direction: UIPageViewController.NavigationDirection = index == 0 ? .reverse : .forward
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
    }
    
    private func updateSegmentUI(index: Int) {
        let isFirst = index == 0
        
        questionButton.setTitleColor(isFirst ? .gray900 : .gray500, for: .normal)
        dailyButton.setTitleColor(isFirst ? .gray500 : .gray900, for: .normal)
        
        indicatorView.snp.remakeConstraints {
            $0.bottom.equalTo(segmentStackView.snp.bottom)
            $0.height.equalTo(2)
            $0.width.equalToSuperview().multipliedBy(0.5)
            if isFirst {
                $0.leading.equalToSuperview()
            } else {
                $0.trailing.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let current = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: current) {
            updateSegmentUI(index: index)
        }
    }
}
