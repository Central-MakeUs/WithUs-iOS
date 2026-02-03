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
    private var keywordSettingReactor: KeywordSettingReactor?
    
    init(navigationController: UINavigationController, keywordService: KeywordEventServiceProtocol) {
        self.navigationController = navigationController
        self.keywordService = keywordService
    }
    
    func start() {
        let networkService = NetworkService.shared
        
        // Repositories
        let homeRepository = HomeRepository(networkService: networkService)
        let coupleKeywordRepository = CoupleKeywordRepository(networkService: networkService)
        let homeContentRepository = HomeContentRepository(networkService: networkService)
        let imageRepository = ImageRepository(networkService: networkService)
        let keywordRepository = KeywordRepository(networkService: networkService)
        let pokeRepository = PokePartnerRepository(networkService: networkService)
        
        // Use Cases
        let fetchUserStatusUseCase = FetchUserStatusUseCase(repository: homeRepository)
        let fetchCoupleKeywordsUseCase = FetchCoupleKeywordsUseCase(coupleKeywordRepository: coupleKeywordRepository)
        let fetchTodayQuestionUseCase = FetchTodayQuestionUseCase(repository: homeContentRepository)
        let fetchTodayKeywordUseCase = FetchTodayKeywordUseCase(repository: homeContentRepository)
        let uploadImageUseCase = UploadImageUseCase(imageRepository: imageRepository)
        
        let uploadQuestionImageUseCase = UploadQuestionImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        let uploadKeywordImageUseCase = UploadKeywordImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        
        let pokePartnerUseCase = PokePartnerUseCase(pokeRepository: pokeRepository)
        
        // Reactors
        let todayQuestionReactor = TodayQuestionReactor(
            fetchTodayQuestionUseCase: fetchTodayQuestionUseCase,
            uploadQuestionImageUseCase: uploadQuestionImageUseCase, pokePartnerUseCase: pokePartnerUseCase
        )
        
        let todayDailyReactor = TodayDailyReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase,
            fetchTodayKeywordUseCase: fetchTodayKeywordUseCase,
            uploadKeywordImageUseCase: uploadKeywordImageUseCase,
            keywordService: keywordService, pokePartnerUseCase: pokePartnerUseCase
        )
        
        let keywordSettingReactor = KeywordSettingReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase,
            keywordService: keywordService
        )
        self.keywordSettingReactor = keywordSettingReactor
        
        // HomePagerViewController 생성
        let homePagerVC = HomePagerViewController()
        homePagerVC.coordinator = self
        
        // 내부 Page VCs에 Reactor 주입
        // HomePagerViewController의 lazy page VCs가 init될 때 coordinator가 이미 설정되어야 하므로
        // coordinator 세팅 후 reactor를 직접 주입
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
        guard let keywordSettingReactor = keywordSettingReactor else { return }
        
        let networkService = NetworkService.shared
        let keywordRepository = KeywordRepository(networkService: networkService)
        let fetchKeywordsUseCase = FetchKeywordUseCase(keywordRepository: keywordRepository)
        let keywordVC = ModifyKeywordViewController(fetchKeywordsUseCase: fetchKeywordsUseCase)
        
        keywordVC.homeCoordinator = self
        keywordVC.reactor = keywordSettingReactor
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
