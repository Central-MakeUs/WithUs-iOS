//
//  FourCutCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class FourCutCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let contentUsecase: MemoryContentUseCaseProtocol
    private let coupleInfoUsecase: CoupleInfoUsecaseProtocol
    private let reactor: MemoryReactor?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        
        //Repositories
        let repository = MemoryContentRepository(networkService: networkService)
        let imageRepository = ImageRepository(networkService: networkService)
        let infoRepository = CoupleInfoRespository(networkService: networkService)
        
        //Usecases
        self.contentUsecase = MemoryContentUseCase(repository: repository, uploadImageUseCase: UploadImageUseCase(imageRepository: imageRepository))
        self.coupleInfoUsecase = CoupleInfoUsecase(repository: infoRepository)
        
        self.reactor = MemoryReactor(memoryContentUsecase: contentUsecase, coupleInfoUseCase: coupleInfoUsecase)
    }
    
    func start() {
        let fourCutViewController = FourCutViewController()
        fourCutViewController.reactor = self.reactor
        fourCutViewController.coordinator = self
        navigationController.setViewControllers([fourCutViewController], animated: false)
    }
    
    func showFrameSelection() {
        let vc = FrameSelectionViewController()
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showPhotoSelection() {
        let vc = PhotoSelectionViewController()
        vc.coordinator = self
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showFilterSelection(_ images: [UIImage]) {
        let filterVC = FilterSelectionViewController()
        filterVC.coordinator = self
        filterVC.selectedPhotos = images
        filterVC.reactor = self.reactor
        navigationController.pushViewController(filterVC, animated: true)
    }
    
    func showTextInputSelection(_ selectedPhotos: [UIImage], _ type: FrameColorType) {
        let textInputVC = TextInputViewController()
        textInputVC.selectedPhotos = selectedPhotos
        textInputVC.coordinator = self
        textInputVC.selectedFrameColor = type
        textInputVC.reactor = self.reactor
        if let fourCutVC = navigationController.viewControllers.first as? FourCutViewController {
            textInputVC.delegate = fourCutVC
        }
        navigationController.pushViewController(textInputVC, animated: true)
    }
    
    func showFourcutConfirm(_ image: UIImage) {
        let vc = FourCutConfirmViewController()
        vc.coordinator = self
        vc.fourcut = image
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDateSelectionBottomSheet(
        currentYear: Int,
        currentMonth: Int,
        onDateSelected: @escaping (Int, Int) -> Void
    ) {
        let vc = MemoryDateSelectBottomSheetViewController()
        vc.currentYear = currentYear
        vc.currentMonth = currentMonth
        vc.onDateSelected = onDateSelected
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
    }
    
    func showMemoryDetail(_ imageUrl: String) {
        let vc = FourCutDetailViewController()
        vc.configure(imageUrl)
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController.present(vc, animated: true)
    }
    
    func showPhotoPicker() {
        let picker = CustomPhotoPickerViewController()
        picker.coordinator = self
        navigationController.pushViewController(picker, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func showUploadSuccessAndPopToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func finish() {
        
    }
}
