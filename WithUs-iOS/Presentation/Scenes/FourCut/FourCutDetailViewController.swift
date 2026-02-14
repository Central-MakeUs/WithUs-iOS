//
//  FourCutDetailViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation
import UIKit
import Then
import SnapKit
import Kingfisher

final class FourCutDetailViewController: BaseViewController {
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = UIColor.gray900
        $0.pageIndicatorTintColor = UIColor.gray300
        $0.preferredIndicatorImage = UIImage(named: "page_control_inactive")
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 32
    }
    
    private let shareButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_share"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    private let instagramButton = UIButton().then {
        $0.setImage(UIImage(named: "insta_logo"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    private let downloadButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_downLoad"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 28
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .black.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 15
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(backgroundImageView)
        view.addSubview(blurEffectView)
        view.addSubview(mainImageView)
        view.addSubview(pageControl)
        view.addSubview(buttonStackView)
        view.addSubview(closeButton)
        
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(instagramButton)
        buttonStackView.addArrangedSubview(downloadButton)
    }
    
    override func setupConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(2)
        }
        
        [shareButton, instagramButton, downloadButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(56)
            }
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.top.right.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
        
        mainImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(pageControl.snp.top).offset(-34)
        }
    }
    
    override func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(didTapDownloadButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    @objc private func didTapDownloadButton() {
        guard let image = mainImageView.image else {
            ToastView.show(message: "저장 실패")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(image(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            ToastView.show(message: "저장 실패")
        } else {
            ToastView.show(message: "사진이 앨범에 저장되었습니다.")
        }
    }
    
    @objc private func didTapCloseButton() {
        self.dismiss(animated: true) {
        }
    }
    
    @objc private func didTapShareButton() {
        guard let image = mainImageView.image else {
            ToastView.show(message: "공유 실패")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    func configure(_ imageUrl: String) {
        if let url = URL(string: imageUrl) {
            
            backgroundImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
            
            mainImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}
