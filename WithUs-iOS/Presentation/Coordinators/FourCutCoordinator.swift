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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let fourCutViewController = FourCutViewController()
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
        navigationController.pushViewController(filterVC, animated: true)
    }
    
    func showTextInputSelection(_ selectedPhotos: [UIImage]) {
        let textInputVC = TextInputViewController()
        textInputVC.selectedPhotos = selectedPhotos
        textInputVC.coordinator = self
        navigationController.pushViewController(textInputVC, animated: true)
    }
    
    func showFourcutConfirm(_ image: UIImage) {
        let vc = FourCutConfirmViewController()
        vc.coordinator = self
        vc.fourcut = image
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDateSelectionBottomSheet() {
        let vc = MemoryDateSelectBottomSheetViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController.present(vc, animated: true)
    }
    
    func showMemoryDetail() {
        let vc = FourCutDetailViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController.present(vc, animated: true)
    }
    
    func showPhotoPicker() {
        let picker = CustomPhotoPickerViewController()
        picker.coordinator = self
        navigationController.pushViewController(picker, animated: true)
    }
    
    func finish() {
        
    }
}
