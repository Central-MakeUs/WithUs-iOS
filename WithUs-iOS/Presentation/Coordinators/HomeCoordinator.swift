//
//  HomeCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//  Updated by Hubriz iOS on 1/31/26.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var inviteCoordinator: InviteCoordinator?
    weak var mainCoordinator: MainCoordinator?
    private let keywordService: KeywordEventServiceProtocol
    
    // Repositories
    private let homeRepository: HomeRepositoryProtocol
    private let coupleKeywordRepository: CoupleKeywordRepositoryProtocol
    private let homeContentRepository: HomeContentRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let keywordRepository: KeywordRepositoryProtocol
    private let pokeRepository: PokePartnerRepositoryProtocol
    
    // Use Cases
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    private let fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol
    private let fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol
    private let fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol
    private let uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol
    private let pokePartnerUseCase: PokePartnerUseCaseProtocol
    private let fetchKeywordUseCase: FetchKeywordUseCaseProtocol
    private let selectedKeywordUseCase: FetchSelectedKeywordUseCaseProtocol
    
    init(
        navigationController: UINavigationController,
        keywordService: KeywordEventServiceProtocol,
        networkService: NetworkService = .shared
    ) {
        self.navigationController = navigationController
        self.keywordService = keywordService
        
        // Repositories 초기화
        self.homeRepository = HomeRepository(networkService: networkService)
        self.coupleKeywordRepository = CoupleKeywordRepository(networkService: networkService)
        self.homeContentRepository = HomeContentRepository(networkService: networkService)
        self.imageRepository = ImageRepository(networkService: networkService)
        self.keywordRepository = KeywordRepository(networkService: networkService)
        self.pokeRepository = PokePartnerRepository(networkService: networkService)
        
        // Use Cases 초기화
        self.fetchUserStatusUseCase = FetchUserStatusUseCase(repository: homeRepository)
        self.fetchCoupleKeywordsUseCase = FetchCoupleKeywordsUseCase(coupleKeywordRepository: coupleKeywordRepository)
        self.fetchTodayQuestionUseCase = FetchTodayQuestionUseCase(repository: homeContentRepository)
        self.fetchTodayKeywordUseCase = FetchTodayKeywordUseCase(repository: homeContentRepository)
        
        self.uploadImageUseCase = UploadImageUseCase(imageRepository: imageRepository)
        self.uploadQuestionImageUseCase = UploadQuestionImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        self.uploadKeywordImageUseCase = UploadKeywordImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        self.pokePartnerUseCase = PokePartnerUseCase(pokeRepository: pokeRepository)
        self.fetchKeywordUseCase = FetchKeywordUseCase(keywordRepository: keywordRepository)
        self.selectedKeywordUseCase = FetchSelectedKeywordUseCase(keywordRepository: keywordRepository)
    }
    
    func start() {
        // Reactors
        let todayQuestionReactor = TodayQuestionReactor(
            fetchTodayQuestionUseCase: fetchTodayQuestionUseCase,
            uploadQuestionImageUseCase: uploadQuestionImageUseCase,
            pokePartnerUseCase: pokePartnerUseCase
        )
        
        let todayDailyReactor = TodayDailyReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase,
            fetchTodayKeywordUseCase: fetchTodayKeywordUseCase,
            uploadKeywordImageUseCase: uploadKeywordImageUseCase,
            keywordService: keywordService,
            pokePartnerUseCase: pokePartnerUseCase
        )
        // HomePagerViewController 생성
        let homePagerVC = HomePagerViewController()
        homePagerVC.coordinator = self
        
        // 내부 Page VCs에 Reactor 주입
        homePagerVC.injectReactors(
            questionReactor: todayQuestionReactor,
            dailyReactor: todayDailyReactor,
            fetchUserStatusUseCase: fetchUserStatusUseCase
        )
        
        navigationController.setViewControllers([homePagerVC], animated: true)
    }
    
    func handleNeedUserSetup() {
        mainCoordinator?.handleNeedUserSetup()
    }
    
    func showCamera(for uploadType: ImageUploadType, delegate: PhotoPreviewDelegate) {
        let customCameraVC = CustomCameraViewController()
        customCameraVC.modalPresentationStyle = .fullScreen
        
        customCameraVC.onImageCaptured = { [weak self] image in
            let photoPreviewVC = PhotoPreviewViewController(image: image)
            photoPreviewVC.modalPresentationStyle = .fullScreen
            photoPreviewVC.delegate = delegate
            photoPreviewVC.dismissCamera = {
                customCameraVC.dismiss(animated: true)
            }
            
            customCameraVC.present(photoPreviewVC, animated: true)
        }
        
        navigationController.present(customCameraVC, animated: true)
    }
    
    func showInviteModal() {
        let inviteModalVC = InviteViewController()
        inviteModalVC.coordinator = self
        inviteModalVC.view.backgroundColor = .white
        inviteModalVC.modalPresentationStyle = .overFullScreen
        navigationController.present(inviteModalVC, animated: true)
    }

    func startInviteFlow(_ type: CodeType) {
        let inviteCoord = InviteCoordinator(navigationController: navigationController, type: type)
        inviteCoord.delegate = self
        self.inviteCoordinator = inviteCoord
        childCoordinators.append(inviteCoord)
        inviteCoord.start()
    }
    
    func showKeywordModification() {
        let reactor = KeywordSettingReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase,
            keywordService: keywordService
        )
        
        let keywordVC = ModifyKeywordViewController(
            fetchKeywordsUseCase: fetchKeywordUseCase,
            fetchSelectedKeywordsUseCase: selectedKeywordUseCase,
            entryPoint: .home
        )
        
        keywordVC.homeCoordinator = self
        keywordVC.reactor = reactor
        navigationController.pushViewController(keywordVC, animated: true)
    }
     
    func finish() {
        childCoordinators.removeAll()
        inviteCoordinator = nil
    }
}

extension HomeCoordinator: InviteCoordinatorDelegate {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        inviteCoordinator = nil
        coordinator.finish()
    }
}
