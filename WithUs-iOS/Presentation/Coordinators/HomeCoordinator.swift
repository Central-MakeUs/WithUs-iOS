//
//  HomeCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var inviteCoordinator: InviteCoordinator?
    weak var mainCoordinator: MainCoordinator?
    private weak var homeReactor: HomeReactor?
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
        
        // Use Cases
        let fetchUserStatusUseCase = FetchUserStatusUseCase(repository: homeRepository)
        let fetchCoupleKeywordsUseCase = FetchCoupleKeywordsUseCase(coupleKeywordRepository: coupleKeywordRepository)
        let fetchTodayQuestionUseCase = FetchTodayQuestionUseCase(repository: homeContentRepository)
        let fetchTodayKeywordUseCase = FetchTodayKeywordUseCase(repository: homeContentRepository)
        
        // ✅ 기존 UploadImageUseCase 생성
        let uploadImageUseCase = UploadImageUseCase(imageRepository: imageRepository)
        
        // ✅ UploadImageUseCase를 주입
        let uploadQuestionImageUseCase = UploadQuestionImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        let uploadKeywordImageUseCase = UploadKeywordImageUseCase(
            repository: homeContentRepository,
            uploadImageUseCase: uploadImageUseCase
        )
        
        // Reactor
        let homeReactor = HomeReactor(
            fetchUserStatusUseCase: fetchUserStatusUseCase,
            fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase,
            fetchTodayQuestionUseCase: fetchTodayQuestionUseCase,
            uploadQuestionImageUseCase: uploadQuestionImageUseCase,
            fetchTodayKeywordUseCase: fetchTodayKeywordUseCase,
            uploadKeywordImageUseCase: uploadKeywordImageUseCase, keywordService: keywordService
        )
        
        let keywordSettingReactor = KeywordSettingReactor(fetchCoupleKeywordsUseCase: fetchCoupleKeywordsUseCase, keywordService: keywordService)
        
        self.homeReactor = homeReactor
        self.keywordSettingReactor = keywordSettingReactor
        
        // ViewController
        let homeViewController = HomeViewController()
        homeViewController.reactor = homeReactor
        homeViewController.coordinator = self
        
        navigationController.setViewControllers([homeViewController], animated: true)
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
    
    private func showPhotoPreview(image: UIImage, uploadType: ImageUploadType, delegate: PhotoPreviewDelegate) {
        let photoPreviewVC = PhotoPreviewViewController(image: image)
        photoPreviewVC.modalPresentationStyle = .fullScreen
        photoPreviewVC.delegate = delegate // ✅ delegate 설정
        
        navigationController.present(photoPreviewVC, animated: true)
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
